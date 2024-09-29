from aws_cdk import (
    Stack,
    aws_ec2 as ec2,
    aws_s3 as s3,
    aws_iam as iam,
    CfnOutput,
)
from constructs import Construct
import aws_cdk as cdk
from worker_node.helpers.helpers import test_keypair_exists

class KubernetesWorkerStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, vpc: ec2.IVpc, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Use the provided VPC
        self.vpc = vpc

        # Define the security group to allow all ssh and http
        security_group = ec2.SecurityGroup(
            self, "WorkerAppSecurityGroup",
            vpc=vpc,
            description="Allow SSH and HTTP traffic",
            allow_all_outbound=True
        )
        
        security_group.add_ingress_rule(
            ec2.Peer.any_ipv4(),  # Allow from any IPv4 address
            ec2.Port.tcp_range(0, 65535),  # Allow all TCP ports
            "Allow access to all ports from any IP"
        )
        
        key_name = "kubernetes-app-keypair"
        key_exists = test_keypair_exists(name=key_name)

        if key_exists:
            # If key exists, the function returns the key id as the second object
            ssh_key_id = key_exists[1]
            ec2_ssh_key_pair = ec2.KeyPair.from_key_pair_name(self, id=ssh_key_id, key_pair_name=key_name)
        else:
            ec2_ssh_key_pair = ec2.KeyPair(self, 
                f"{key_name}",
                key_pair_name=key_name,
                physical_name=key_name,
                format=ec2.KeyPairFormat.PEM
            )
            ec2_ssh_key_pair.apply_removal_policy(cdk.RemovalPolicy.RETAIN)            

        # user data script to bootstrap worker
        with open("worker_node/scripts/user_data.sh", "r") as user_data_file:
            user_data_script = user_data_file.read()

        # Define User Data
        user_data = ec2.UserData.for_linux()
        user_data.add_commands(user_data_script)

        # Create an IAM role for the EC2 instance
        role = iam.Role(self, "EC2AccessRole",
            assumed_by=iam.ServicePrincipal("ec2.amazonaws.com")
        )

        # Add CloudFormation DescribeStacks permission
        role.add_to_policy(iam.PolicyStatement(
            actions=["cloudformation:DescribeStacks"],
            resources=["*"]  # Grant access to all stacks
        ))
        
        # Attach the role to the EC2 instance
        instance = ec2.Instance(
            self, "KubWorkerEC2Instance",
            instance_type=ec2.InstanceType("t2.medium"),
            machine_image=ec2.MachineImage.generic_linux({
                "eu-west-1": "ami-03cc8375791cb8bcf"
            }),
            vpc=vpc,
            security_group=security_group,
            key_pair=ec2_ssh_key_pair,
            vpc_subnets={
                "subnet_type": ec2.SubnetType.PUBLIC
            },
            user_data=user_data,
            role=role,
            block_devices=[
                   ec2.BlockDevice(
                       device_name="/dev/xvda",
                       volume=ec2.BlockDeviceVolume.ebs(
                           volume_size=8,
                           volume_type=ec2.EbsDeviceVolumeType.GP3, 
                           delete_on_termination=True
                       )
                   )
               ],         
        )

        # Output the public IP of the instance
        CfnOutput(
            self, "WorkerInstancePublicIp",
            value=instance.instance_public_ip,
            description="The public IP address of the Worker EC2 instance"
        )
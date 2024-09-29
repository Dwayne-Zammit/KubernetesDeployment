from aws_cdk import (
    Stack,
    aws_ec2 as ec2,
    CfnOutput
)
from constructs import Construct  # Use the constructs library for defining constructs

class VpcStack(Stack):
    def __init__(self, scope: Construct, id: str, **kwargs) -> None:
        super().__init__(scope, id, **kwargs)

        # Create a VPC with only public subnets
        self.vpc = ec2.Vpc(self, "KubernetesVpc",
                           max_azs=1,  # Maximum number of Availability Zones
                           nat_gateways=0,  # No NAT Gateways to avoid charges
                           subnet_configuration=[
                               ec2.SubnetConfiguration(
                                   name="Public",
                                   subnet_type=ec2.SubnetType.PUBLIC,  # Public subnet
                                   cidr_mask=24  # Size of the subnet
                               ),
                           ])

        # Output the VPC ID for reference
        CfnOutput(self, "VpcId", value=self.vpc.vpc_id)

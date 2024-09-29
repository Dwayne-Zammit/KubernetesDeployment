#!/usr/bin/env python3
import os
import aws_cdk as cdk
from vpc_stack.vpc_stack import VpcStack
from master_node.master_stack import KubernetesMasterStack
from worker_node.worker_stack import KubernetesWorkerStack

account = os.getenv('CDK_DEFAULT_ACCOUNT')
region = 'eu-west-1'

if not account:
    raise ValueError("Environment variable 'CDK_DEFAULT_ACCOUNT' is not set.")

app = cdk.App()
print(f"Deploying app to region {region}")

# Create the VPC stack
vpc_stack = VpcStack(app, "VpcStack", env=cdk.Environment(account=account, region=region))

# Pass the VPC from VpcStack to KubernetesMasterStack
KubernetesMasterStack(app, "KubernetesMasterStack",
    env=cdk.Environment(account=account, region=region),
    vpc=vpc_stack.vpc
)

KubernetesWorkerStack(app, "KubernetesWorkerStack",
    env=cdk.Environment(account=account, region=region),
    vpc=vpc_stack.vpc
)
app.synth()

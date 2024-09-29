import aws_cdk as core
import aws_cdk.assertions as assertions

from master_node import master_stack

# example tests. To run these tests, uncomment this file along with the example
# resource in master_cdk_app/master_cdk_app_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = master_stack(app, "master-cdk-app")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })

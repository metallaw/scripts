# Deletes all permissions on cloudwatch loggroups 
# and adds a wildcard permission instead. 
# Useful when you run into the permission limits 
# when having a lot of log-groups to subscribe 

import json
import boto3

# Basic parameters
region = "<region to specify e.g. eu-central-1>"
lambda_function = "<Name of your Lambda Function>"
client = boto3.client('lambda', region_name=region)
account_id = boto3.client('sts').get_caller_identity().get('Account')

# Get current policies
response = client.get_policy(
    FunctionName=lambda_function
)

# Delete all current policies
response_values = json.loads(response['Policy'])
sid_list = []
for policy_content in response_values['Statement']:
    sid = policy_content['Sid']
    sid_list.append(sid)

for sids in sid_list:
    client.remove_permission(
        FunctionName=lambda_function,
        StatementId=sids
    )

# Create wildcard policy
client.add_permission(
    FunctionName=lambda_function,
    StatementId='WildCard',
    Action='lambda:InvokeFunction',
    Principal=f'logs.{region}.amazonaws.com',
    SourceArn=f'arn:aws:logs:{region}:{account_id}:log-group:*',
    SourceAccount=f'{account_id}'
)

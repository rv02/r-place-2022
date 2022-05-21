
###  SEND MESSAGES TO SQS MESSAGE QUEUE WITH AWS LAMBDA

import boto3
import os

#  direct to sqs queue
sqs = boto3.client('sqs',region_name=os.environ['queue_region'])
queue_url = os.environ['queue_url']
    
#  lambda function to send messages to sqs queue
def lambda_handler(event, context):
    
    #  one message for each file url
    for i in range(20):
        
        file_no = '0'+ str(i) if i < 10 else str(i)
        response = sqs.send_message(
            QueueUrl=queue_url,
            MessageAttributes={
                
                'file_no': {
                    'DataType': 'String',
                    'StringValue': file_no,

                }
                
            },
            
            MessageBody=(
                'Download Information for files: ' \
                'File number: ' + str(i)
            )
        )
                
    return {
        'Message Status': '200'
        
    }
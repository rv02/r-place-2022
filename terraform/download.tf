# Lambda function to send messages to SQS
resource "aws_lambda_function" "send_sqs_messages" {
  filename         = "./../send_sqs_messages.zip"
  function_name    = "send_sqs_messages"
  role             = aws_iam_role.send_sqs.arn
  handler          = "sendSqsMessages.lambda_handler"
  publish          = true
  source_code_hash = base64sha256("send_sqs_messages.zip")

  runtime = "python3.9"
  environment {
    variables = {
      queue_url    = "${aws_sqs_queue.file_queue.url}"
      queue_region = var.region
    }
  }
  timeout = 300

}

# Role for lambda function sending to SQS
resource "aws_iam_role" "send_sqs" {
  name = "send_sqs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Send SQS Policy
resource "aws_iam_policy" "send_sqs" {
  name        = "send-sqs"
  description = "A policy that allows to recieve messages from SQS"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1440529349000",
            "Effect": "Allow",
            "Action": [
                "sqs:SendMessage"
            ],
            "Resource": [
                "${aws_sqs_queue.file_queue.arn}"
            ]
        }
    ]
}
EOF
}

# Attaching send sqs policy to role
resource "aws_iam_role_policy_attachment" "send-sqs-policy-attachment" {
  role       = aws_iam_role.send_sqs.name
  policy_arn = aws_iam_policy.send_sqs.arn
}


# Creating the SQS
resource "aws_sqs_queue" "file_queue" {
  name                       = "file-number-queue"
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 900
}



resource "aws_iam_role" "download_lambda_role" {
  name = "download_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "s3-full-access-policy-attachment" {
  role       = aws_iam_role.download_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


resource "aws_lambda_function" "download_raw_data" {
  filename                       = "./../download.zip"
  function_name                  = "download_raw_data"
  role                           = aws_iam_role.download_lambda_role.arn
  handler                        = "download.lambda_handler"
  publish                        = true
  reserved_concurrent_executions = -1

  source_code_hash = base64sha256("downoad.zip")

  runtime = "python3.9"

  timeout = 900

}

resource "aws_lambda_event_source_mapping" "sqs_event" {
  event_source_arn = aws_sqs_queue.file_queue.arn
  function_name    = aws_lambda_function.download_raw_data.arn
}

resource "aws_iam_policy" "receive_sqs" {
  name        = "recieve-sqs"
  description = "A policy that allows to recieve messages from SQS"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "QueueReceive2938204939",
            "Effect": "Allow",
            "Action": [
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes"
            ],
            "Resource": [
                "${aws_sqs_queue.file_queue.arn}"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "recieve-sqs-policy-attachment" {
  role       = aws_iam_role.download_lambda_role.name
  policy_arn = aws_iam_policy.receive_sqs.arn
}


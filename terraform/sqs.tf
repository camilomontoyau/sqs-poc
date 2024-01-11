resource "aws_sqs_queue" "my_queue" {
  name                      = "${var.main_name}-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  visibility_timeout_seconds = 30
  receive_wait_time_seconds = 0
}

resource "aws_iam_policy" "custom_sqs_policy" {
  name        = "my_custom_sqs_policy"
  description = "A custom SQS policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": "sqs:GetQueueAttributes",
          "Resource": "${aws_sqs_queue.my_queue.arn}"
      },
      {
          "Effect": "Allow",
          "Action": "sqs:SendMessage",
          "Resource": "${aws_sqs_queue.my_queue.arn}"
      },
      {
          "Effect": "Allow",
          "Action": "sqs:SendMessageBatch",
          "Resource": "${aws_sqs_queue.my_queue.arn}"
      },
      {
          "Effect": "Allow",
          "Action": "sqs:ReceiveMessage",
          "Resource": "${aws_sqs_queue.my_queue.arn}"
      }
  ]
}
EOF
}

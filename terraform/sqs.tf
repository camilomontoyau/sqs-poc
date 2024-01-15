resource "aws_sqs_queue" "my_queue" {
  name                      = "${var.main_name}-queue"
  delay_seconds             = 0 # zero means messages are immediately available as soon as they are published
  max_message_size          = 262144 # 256 KiB
  message_retention_seconds = 345600 # 4 days
  visibility_timeout_seconds = 30 # 30 seconds
  receive_wait_time_seconds = 0 # zero means short polling
}

resource "aws_iam_policy" "custom_sqs_policy" {
  depends_on = [ aws_sqs_queue.my_queue ]
  name        = "sqs"
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
      },
      {
          "Effect": "Allow",
          "Action": "sqs:DeleteMessage",
          "Resource": "${aws_sqs_queue.my_queue.arn}"
      },
      {
          "Effect": "Allow",
          "Action": "sqs:DeleteMessageBatch",
          "Resource": "${aws_sqs_queue.my_queue.arn}"
      }
  ]
}
EOF
}

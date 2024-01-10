resource "aws_sqs_queue" "my_queue" {
  name                      = "${var.main_name}-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  visibility_timeout_seconds = 30
  receive_wait_time_seconds = 0
}

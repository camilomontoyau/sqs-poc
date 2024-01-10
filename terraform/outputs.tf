output "sqs_queue_arn" {
  value = aws_sqs_queue.my_queue.arn
}

output "cert_manager_irsa_role" {
  value = module.cert_manager_irsa_role.iam_role_arn
}

output "external_dns_irsa_role" {
  value = module.external_dns_irsa_role.iam_role_arn
}
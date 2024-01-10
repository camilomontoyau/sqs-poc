variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "main_name" {
  description = "The name of the cluster"
  type        = string
  default     = "my-cluster"
  
}

variable "tags" {
  description = "The tags to apply to all resources"
  type        = map(string)
  default     = {
    "Environment" = "dev"
    "ManagedBy"   = "Terraform"
  }
}

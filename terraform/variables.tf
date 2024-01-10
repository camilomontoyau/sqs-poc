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
  description = "The name to identify this infrastructure"
  type        = string
  default     = "my-infrastructure"
  
}

variable "tags" {
  description = "The tags to apply to all resources"
  type        = map(string)
  default     = {
    "Environment" = "dev"
    "ManagedBy"   = "Terraform"
  }
}

variable "hostedZoneID" {
  description = "The ID of the Route53 hosted zone"
  type        = string
}

variable "domain" {
  description = "The domain name"
  type        = string
}

variable "tld" {
  description = "The top level domain"
  type        = string
}

variable "Environment" {
  description = "The environment"
  type        = string
  default     = "dev"
}

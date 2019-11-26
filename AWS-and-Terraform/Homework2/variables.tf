variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

terraform {
  required_version = ">= 0.12.0"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}


resource "tls_private_key" "servers" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "servers" {
  key_name   = "servers"
  public_key = "${tls_private_key.servers.public_key_openssh}"
}

resource "local_file" "servers" {
sensitive_content = "${tls_private_key.servers.private_key_pem}"
  filename           = "servers.pem"
}


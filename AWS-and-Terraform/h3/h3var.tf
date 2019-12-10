variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}


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


variable "pub_cidr" {
  description = "CIDR from Pub"
  type = "list"
  default = ["10.0.2.0/24","10.0.3.0/24"]
}
variable "network_address_space" {
  default = "10.0.0.0/16"
}


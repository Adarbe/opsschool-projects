
######Provider#####

provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region = "us-east-1"
}




#######Resource####

resource "aws_vpc" "homework3" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "homework3"
  }
  enable_dns_hostnames = true
}


######## EC2 ########

resource "aws_instance" "web" {
  #description = "create 2 EC2 machines and install nginx"
  count = 2
  ami = "ami-024582e76075564db"
  instance_type = "t2.micro"
  key_name = aws_key_pair.servers.key_name
  iam_instance_profile = "${aws_iam_instance_profile.ec2_iam.id}"
  tags = {
    Name = "ngnix ${count.index}"
  }
  connection {
    type = "ssh"
    host = "self.public_ip"
    private_key = tls_private_key.servers.public_key_openssh
    user = "ubuntu"
  }
  user_data = <<-EOF
				#! /bin/bash
              	sudo apt-get update
              	sudo apt-get install -y nginx
              	sudo chmod +777 /var/www/html/
              	sudo service nginx start
              	sudo sed -i 's/Welcome to nginx/ OpsSchool Rules!/g' /var/www/html/index.nginx-debian.html
			  	sudo sed -i '1 i\'"$HOSTNAME" /var/www/html/index.nginx-debian.html
				sudo service nginx restart
              	EOF
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  subnet_id = "${aws_subnet.pubsub[count.index].id}"
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
}
resource "aws_instance" "DB" {
  count = 2
  ami = "ami-024582e76075564db"
  instance_type = "t2.micro"
  key_name = aws_key_pair.servers.key_name
  tags = {
    Name = "DB ${count.index}"
  }
  connection {
    type = "ssh"
    host = "self.public_ip"
    private_key = tls_private_key.servers.public_key_openssh
    user = "ubuntu"
  }
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  subnet_id = "${data.aws_subnet.private[count.index].id}"
  vpc_security_group_ids = ["${aws_security_group.nat.id}"]
}




  #####Data#######

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
      name = "name"
      values = [
        "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }

    owners = [
      "099720109477"]
    # Canonical
  }


resource "aws_iam_role" "role" {
  name = "ec2_role"
  path = "/"

  assume_role_policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_iam" {
  name = "ec2"
  role = "${aws_iam_role.role.id}"
}


data "aws_subnet" "private" {
  count=2
  id = "${aws_subnet.prisub[count.index].id}"
}
data "aws_availability_zones" "available" {}










######Provider#####

provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region = "us-east-1"
}


#######Resource####

resource "aws_vpc" "homework2" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "homework2"
  }
  enable_dns_hostnames = true
}



##### Subnets ########

resource "aws_subnet" "pubsub" {
  count = 2
  vpc_id = "${aws_vpc.homework2.id}"
  cidr_block = "10.0.${2+count.index}.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "pubsub ${count.index}"
  }
}

resource "aws_subnet" "prisub" {
  count = 2
  vpc_id = "${aws_vpc.homework2.id}"
  cidr_block = "10.0.${10+count.index}.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "prisub ${count.index}"
  }
  }



#####Networking######


resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.homework2.id}"
  tags = {
    Name = "IGW"
    }
  }

resource "aws_eip" "nateip" {
  vpc = true
  count = 2
  }


resource "aws_nat_gateway" "NATGW" {
  allocation_id = "${aws_eip.nateip[count.index].id}"
  depends_on = ["aws_internet_gateway.IGW"]
  subnet_id = "${aws_subnet.pubsub[count.index].id}"
  count = 2
  tags = {
    Name = "NATGW ${count.index}"
   }
  }


##### Route tables #####

resource "aws_route_table" "pubroute" {
  vpc_id = "${aws_vpc.homework2.id}"
  count = 2
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}

resource "aws_route_table" "priroute" {
  vpc_id = "${aws_vpc.homework2.id}"
  count = 2
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.NATGW[count.index].id}"
  }
}


resource "aws_route_table_association" "pubroute" {
  subnet_id      = "${aws_subnet.pubsub[count.index].id}"
  route_table_id = "${aws_route_table.pubroute[count.index].id}"
  count=2
}

resource "aws_route_table_association" "priroute" {
  subnet_id      = "${aws_subnet.prisub[count.index].id}"
  route_table_id = "${aws_route_table.priroute[count.index].id}"
  count = 2
}

######## Security groups ######

resource "aws_security_group" "nginx" {
  name = "nginx"
  vpc_id = "${aws_vpc.homework2.id}"
  description = "Allow ssh traffic"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nat" {
  name = "nat"
  vpc_id = "${aws_vpc.homework2.id}"
  description = "Allow nat traffic"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}





######## EC2 ########

resource "aws_instance" "web" {
  #description = "create 2 EC2 machines and install nginx"
  count = 2
  ami = "ami-024582e76075564db"
  instance_type = "t2.micro"
  key_name = aws_key_pair.servers.key_name
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
              sed -i 's/Welcome to nginx/ OpsSchool Rules!/g' /var/www/html/index.nginx-debian.html
              sudo service nginx restart

              EOF
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  subnet_id = "${aws_subnet.pubsub[count.index].id}"
  vpc_security_group_ids = [aws_security_group.nginx.id]
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



data "aws_subnet" "private" {
  count=2
  id = "${aws_subnet.prisub[count.index].id}"
}

data "aws_availability_zones" "available" {}

#######Output######
output "web_server_public_ip" {
    value = aws_instance.web.*.public_ip
}
output "DB_server_private_ip" {
    value = aws_instance.DB.*.private_ip
}


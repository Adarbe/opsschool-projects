######## Security groups ######
resource "aws_security_group" "elb_sg" {
  name = "elb_sg"
  vpc_id = "${aws_vpc.homework3.id}"
  #Allow HTTP from everywhere
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Allow all outbound
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "nginx_sg" {
  name = "nginx_sg"
  vpc_id = "${aws_vpc.homework3.id}"
  description = "Allow ssh traffic"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = [var.network_address_space]
  }
  #HTTP trafic from VPC
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
  vpc_id = "${aws_vpc.homework3.id}"
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

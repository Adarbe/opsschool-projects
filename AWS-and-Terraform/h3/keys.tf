resource "aws_security_group" "allow_ssh_web" {
  name = "web_servers"
  description = "allow ports from web servers"
  vpc_id = "${aws_vpc.homework3.id}"
  #Allow SSH from everywhere
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "allow_ssh_DB" {
  name = "DB_servers"
  description = "allow ports from DB servers"
  vpc_id = "${aws_vpc.homework3.id}"
  #Allow SSH from everywhere
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
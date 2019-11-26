###### Provider ######
provider "aws" {
    access_key = var.AWS_ACCESS_KEY_ID
    secret_key = var.AWS_SECRET_ACCESS_KEY
    region = "us-east-1"

}



####### Resource ######
resource "aws_vpc" "VPC3" {
  cidr_block = "10.0.0.0/16"
  tags {
    Name = "VPC3"
  }
}



## Network ##
resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.VPC3.id}"
  tags {
    Name = "IGW"
  }
}


resource "aws_eip" "nateip" {
  vpc = true
  count = 2
  }

resource "aws_nat_gateway" "NATGW" {
  allocation_id = "${aws_eip.nateip[count.index].id}"
  subnet_id = "${aws_subnet.pubsub[count.index].id}"
  count = 2
  tags = {
    Name = "NATGW ${count.index}"
   }
  }




## Subnets ##

resource "aws_subnet" "pubsub" {
  count = 2
  vpc_id = "${aws_vpc.VPC3.id}"
  cidr_block = "10.0.${2+count.index}.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "pubsub ${count.index}"
  }
}

resource "aws_subnet" "prisub" {
  count = 2
  vpc_id = "${aws_vpc.VPC3.id}"
  cidr_block = "10.0.${10+count.index}.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "prisub ${count.index}"
    }
  }




## Route ##

resource "aws_route_table" "pubroute" {
  vpc_id = "${aws_vpc.VPC3.id}"
  route {
    cidr_block = "10.0.${2+count.index}.0/24"
    gateway_id = "${aws_internet_gateway.IGW.id}"
  }
  tags = {
    Name = "pubroute"
  }
}

resource "aws_route_table" "priroute" {
  vpc_id = "${aws_vpc.VPC3.id}"
  count = 2
  route {
    cidr_block = "0.0.0.0/0"§
    nat_gateway_id = "${aws_nat_gateway.NATGW[count.index].id}"
  }
}






## EC2 ##


####### Data ########
data "aws_availability_zones" "available" {}






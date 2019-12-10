#####Networking######


resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.homework3.id}"
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

##### Subnets ########

resource "aws_subnet" "pubsub" {
  count = 2
  vpc_id = "${aws_vpc.homework3.id}"
  cidr_block = "10.0.${2+count.index}.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "pubsub ${count.index}"
  }
}

resource "aws_subnet" "prisub" {
  count = 2
  vpc_id = "${aws_vpc.homework3.id}"
  cidr_block = "10.0.${10+count.index}.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "prisub ${count.index}"
  }
}



##### Route tables #####

resource "aws_route_table" "pubroute" {
  vpc_id = "${aws_vpc.homework3.id}"
  count = 2
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}

resource "aws_route_table" "priroute" {
  vpc_id = "${aws_vpc.homework3.id}"
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

#####Load Balancer #####
resource "aws_elb" "web" {
  subnets = [aws_subnet.pubsub[0].id, aws_subnet.prisub[1].id]
  security_groups = [aws_security_group.elb_sg.id]
  instances = [aws_instance.web[0].id,aws_instance.web[1].id]
  access_logs {
	bucket = "${aws_s3_bucket.elb-bk.id}"
	bucket_prefix = "elb"
	interval = 60
  }
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
}


resource "aws_lb_cookie_stickiness_policy" "stickness" {
  name                     = "stickness-policy"
  load_balancer            = "${aws_elb.web.id}"
  lb_port                  = 80
  cookie_expiration_period = 60
}

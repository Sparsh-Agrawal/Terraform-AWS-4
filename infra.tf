provider "aws" {
  region  = "us-east-1"
  profile = "sparsh"
}

resource "aws_vpc" "infra2308-vpc" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "infra2308-vpc"
  }
}

resource "aws_subnet" "infra2308-public-subnet" {
  availability_zone = "us-east-1a"
  cidr_block = "192.168.0.0/24"
  map_public_ip_on_launch = true
  vpc_id = "${aws_vpc.infra2308-vpc.id}"
  tags = {
    Name = "infra2308-public-subnet"
  }
}

resource "aws_subnet" "infra2308-private-subnet" {
  availability_zone = "us-east-1b"
  cidr_block = "192.168.1.0/24"
  vpc_id = "${aws_vpc.infra2308-vpc.id}"
  tags = {
    Name = "infra2308-private-subnet"
  }
}

resource "aws_internet_gateway" "infra2308-ig" {
  vpc_id = "${aws_vpc.infra2308-vpc.id}"
  tags = {
    Name = "infra2308-ig"
  }
}

resource "aws_eip" "infra2308-eip" {
  vpc = true
  tags = {
    Name = "infra2308-eip"
  }
}

resource "aws_nat_gateway" "infra2308-natg" {
  allocation_id = "${aws_eip.infra2308-eip.id}"
  subnet_id = "${aws_subnet.infra2308-public-subnet.id}"
  tags = {
    Name = "infra2308-natg"
  }
}

resource "aws_route_table" "infra2308-route-table-ig" {
  vpc_id = "${aws_vpc.infra2308-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.infra2308-ig.id}"
  }
  tags = {
    Name = "infra2308-route-table-ig"
  }
}

resource "aws_route_table" "infra2308-route-table-natg" {
  vpc_id = "${aws_vpc.infra2308-vpc.id}"
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.infra2308-natg.id}"
  }
  tags = {
    Name = "infra2308-route-table-natg"
  } 
}

resource "aws_route_table_association" "infra2308-route-ass-pub" {
  subnet_id = "${aws_subnet.infra2308-public-subnet.id}"
  route_table_id = "${aws_route_table.infra2308-route-table-ig.id}"
}

resource "aws_route_table_association" "infra2308-route-ass-pri" {
  subnet_id = "${aws_subnet.infra2308-private-subnet.id}"
  route_table_id = "${aws_route_table.infra2308-route-table-natg.id}"
}

resource "tls_private_key" "private-key" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "aws_key_pair" "infra2308-key" {
    key_name   = "infra2308-key"
    public_key = tls_private_key.private-key.public_key_openssh
}

resource "local_file" "localkey" {
  filename = "infra2308-key"
  content = "${tls_private_key.private-key.private_key_pem}"
}

resource "aws_security_group" "infra2308-sg-wp" {
  depends_on = [aws_vpc.infra2308-vpc]
  name        = "infra2308-sg-wp"
  description = "Allow HTTP inbound traffic"
  vpc_id = "${aws_vpc.infra2308-vpc.id}"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "infra2308-sg-wp"
  }
}

resource "aws_security_group" "infra2308-sg-bh" {
  depends_on = [aws_vpc.infra2308-vpc]
  name        = "infra2308-sg-bh"
  description = "Allow HTTP inbound traffic"
  vpc_id = "${aws_vpc.infra2308-vpc.id}"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "infra2308-sg-bh"
  }
}

resource "aws_security_group" "infra2308-sg-sql" {
  depends_on = [aws_vpc.infra2308-vpc]
  name        = "infra2308-sg-sql"
  description = "Allow MySQL inbound traffic"
  vpc_id = "${aws_vpc.infra2308-vpc.id}"

  ingress {
    description = "HTTP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.infra2308-sg-wp.id}"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.infra2308-sg-bh.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "infra2308-sg-sql"
  }
}

resource "aws_instance" "infra2308-instance-wp" {
  ami = "ami-0992aa883aea2dbb2"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.infra2308-public-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.infra2308-sg-wp.id}"] 
  key_name = "${aws_key_pair.infra2308-key.key_name}"
  
  tags = {
    Name = "infra2308-instance-wp"
  }
}

resource "aws_instance" "infra2308-instance-sql" {
  ami = "ami-0761dd91277e34178"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.infra2308-private-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.infra2308-sg-sql.id}"] 
  key_name = "${aws_key_pair.infra2308-key.key_name}"
  
  tags = {
    Name = "infra2308-instance-sql"
  }
}

resource "aws_instance" "infra2308-instance-bh" {
  ami = "ami-02354e95b39ca8dec"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.infra2308-public-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.infra2308-sg-bh.id}"] 
  key_name = "${aws_key_pair.infra2308-key.key_name}"
  
  tags = {
    Name = "infra2308-instance-bh"
  }
}

resource "null_resource" "run" {
  depends_on = [aws_instance.infra2308-instance-wp,aws_instance.infra2308-instance-sql]  

  provisioner "local-exec" {
    command = "start chrome ${aws_instance.infra2308-instance-wp.public_ip}"
  }
}
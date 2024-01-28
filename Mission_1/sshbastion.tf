resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.subnet1["availability_zone"]

  tags = {
    Name = "TF_public_subnet"
  }

  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [aws_vpc.my_vpc.id]
  }
  depends_on = [aws_internet_gateway.my_gateway]
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.existing.id
  }

  tags = {
    Name = "public_route_table"
  }
}


resource "aws_instance" "bastion" {
  ami           = "ami-03c521b6e189dc73f"
  instance_type = "t2.micro"

  key_name  = "my-key-pair"
  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionHost"
  }
}


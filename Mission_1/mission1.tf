provider "aws" {
  region = "us-east-1"
}

# VPC and subnets
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "TF-vpc"
  }
}



resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet1["cidr_block"]
  availability_zone = var.subnet1["availability_zone"]

  tags = {
    Name = "TF_subnet1"
  }
}


resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet2["cidr_block"]
  availability_zone = var.subnet2["availability_zone"]

  tags = {
    Name = "TF_subnet2"
  }
}





# Application Load Balancer
resource "aws_lb" "my_lb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  security_groups    = [aws_security_group.lb_sg.id]

  tags = {
    Name = "TF_lb"
  }
}

# Target groups
resource "aws_lb_target_group" "nginx_tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "TF_nginx_tg"
  }
}

resource "aws_lb_target_group" "apache_tg" {
  name     = "apache-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }


  tags = {
    Name = "TF_Apache_tg"
  }

}

#default action to nginx if no rule matches
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.nginx_tg.arn
    type             = "forward"
  }

}

resource "aws_lb_listener_rule" "apache_rule" {
  listener_arn = aws_lb_listener.lb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apache_tg.arn
  }

  condition {
    path_pattern {
      values = ["/apache*"]
    }
  }
}

resource "aws_lb_listener_rule" "nginx_rule" {
  listener_arn = aws_lb_listener.lb_listener.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }

  condition {
    path_pattern {
      values = ["/nginx*"]
    }
  }
}


# Launch Template
resource "aws_launch_template" "nginx_template" {
  image_id      = "ami-03c521b6e189dc73f"
  instance_type = "t2.micro"
  

  network_interfaces {
    subnet_id = aws_subnet.subnet1.id
    security_groups   = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo adduser --disabled-password --gecos "" myuser
              echo 'myuser:password' | sudo chpasswd
              sudo usermod -aG sudo myuser
              sudo mkdir /home/myuser/.ssh
              sudo chown myuser:myuser /home/myuser/.ssh
              sudo chmod 700 /home/myuser/.ssh
              sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
              sudo systemctl restart sshd
              sudo apt-get update
              sudo apt-get install -y nginx openssh-server net-tools lsof
              sudo systemctl start nginx

              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "NginxInstance"
    }
  }
  tags = {
    Name = "TF_nginx_template"
  }
}

resource "aws_launch_template" "apache_template" {
  image_id      = "ami-03c521b6e189dc73f"
  instance_type = "t2.micro"
  
  

  network_interfaces {
    subnet_id = aws_subnet.subnet2.id
    security_groups   = [aws_security_group.ec2_sg.id]

  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo adduser --disabled-password --gecos "" myuser
              echo 'myuser:password' | sudo chpasswd
              sudo usermod -aG sudo myuser
              sudo mkdir /home/myuser/.ssh
              sudo chown myuser:myuser /home/myuser/.ssh
              sudo chmod 700 /home/myuser/.ssh
              sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
              sudo systemctl restart sshd
              sudo apt-get update
              sudo apt-get install -y apache2 openssh-server net-tools lsof
              sudo systemctl start apache2
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ApacheInstance"
    }
  }
  tags = {
    Name = "TF_apache_template"
  }
}

#--------------


# Spot Fleet for Nginx
resource "aws_spot_fleet_request" "nginx_fleet" {
  iam_fleet_role                      = "arn:aws:iam::118490528453:role/aws-ec2-spot-fleet-tagging-role"
  target_capacity                     = 1
  valid_until                         = "2024-12-31T23:59:59Z"
  terminate_instances_with_expiration = true


  provisioner "local-exec" {
    command = "bash nginx_script.sh ${self.id} ${aws_lb_target_group.nginx_tg.arn}"
  }

  launch_template_config {
    launch_template_specification {
      id      = aws_launch_template.nginx_template.id
      version = "$Latest"
    }
  }
  tags = {
    Name = "TF_nginx_fleet"
  }
  depends_on = [ aws_nat_gateway.nat_gw ]
}



# Spot Fleet for Apache
resource "aws_spot_fleet_request" "apache_fleet" {
  iam_fleet_role                      = "arn:aws:iam::118490528453:role/aws-ec2-spot-fleet-tagging-role"
  target_capacity                     = 1
  valid_until                         = "2024-12-31T23:59:59Z"
  terminate_instances_with_expiration = true


  provisioner "local-exec" {
    command = "bash apache_script.sh ${self.id} ${aws_lb_target_group.apache_tg.arn}"
  }

  launch_template_config {
    launch_template_specification {
      id      = aws_launch_template.apache_template.id
      version = "$Latest"
    }
  }
  tags = {
    Name = "TF_nginx_fleet"
  }

  depends_on = [ aws_nat_gateway.nat_gw ]
}




# RDS PostgreSQL
resource "aws_db_subnet_group" "postgresql_subnet_group" {
  name       = "postgresql-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  depends_on = [aws_subnet.subnet1, aws_subnet.subnet2]
}

resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      aws_security_group.ec2_sg.id,
      
    ]
  }
}

resource "aws_db_instance" "postgresql_rds" {
  identifier                = "postgresql-rds"
  engine                    = "postgres"
  engine_version            = "11.22"
  instance_class            = "db.t2.micro"
  allocated_storage         = 10
  storage_type              = "gp2"
  publicly_accessible       = false
  db_subnet_group_name      = aws_db_subnet_group.postgresql_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.rds_security_group.id]
  multi_az                  = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "final-snapshot-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  username                  = "master"
  password                  = "of_puppets"

  timeouts {
    create = "60m"
    delete = "2h"
  }
}




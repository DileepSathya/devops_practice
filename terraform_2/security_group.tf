


resource "aws_security_group" "web_rds" {
  name        = "web-server-rds"
  description = "security_group_for_rds"

  tags = {
    Name = "webserver-sg"
  }
}


resource "aws_security_group" "web_ec2_sg" {
  name        = "web-server-ec2"
  description = "security_group_for_ec2"

  tags = {
    Name = "webserver-ec2-sg"
  }
}


resource "aws_vpc_security_group_ingress_rule" "ec2_https" {
  security_group_id = aws_security_group.web_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "ec2_http" {
  security_group_id = aws_security_group.web_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {
  security_group_id = aws_security_group.web_ec2_sg.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "ec2_tcp" {
  security_group_id = aws_security_group.web_ec2_sg.id
  cidr_ipv4         = var.my_ip
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}



resource "aws_vpc_security_group_ingress_rule" "rds_https" {
  security_group_id = aws_security_group.web_rds.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "rds_http" {
  security_group_id = aws_security_group.web_rds.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "rds_postgresql" {
  security_group_id            = aws_security_group.web_rds.id
  referenced_security_group_id = aws_security_group.web_ec2_sg.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}
provider "aws" {
  region = "ap-south-1"

}
#-------------------------------------------------------
#  EC2 IAM user
#-------------------------------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "terraform-ec2-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "EC2_full_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "RDS_full_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "secret_manager" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}


resource "aws_iam_role_policy_attachment" "EC2_ECR_power_user" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

#-------------------------------------------------------
# security groups creation
#-------------------------------------------------------




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


#-------------------------------------------------------
# database creation
#-------------------------------------------------------


resource "aws_db_instance" "postgres" {
  allocated_storage = 20

  engine         = "postgres"
  instance_class = "db.t3.micro"

  identifier = "my-postgres-db"
  db_name    = "form_db"
  username   = "postgres"

  skip_final_snapshot = true

  manage_master_user_password = true

  publicly_accessible = false
  vpc_security_group_ids = [
    aws_security_group.web_rds.id
  ]

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

#-------------------------------------------------------
# creating and using datasouce --> aws-ami instead of hard coding ami id as they change overtime based on region
#-------------------------------------------------------


data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
#-------------------------------------------------------
# Ec2 instance
#-------------------------------------------------------

resource "aws_instance" "my_web_server" {

  ami           = "ami-066c4849e6b3a1e3d"
  instance_type = "t3.micro"
  vpc_security_group_ids = [
    aws_security_group.web_ec2_sg.id
  ]
}
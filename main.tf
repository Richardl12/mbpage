data "aws_vpc" "mb_vpc" {
    filter {
      name = "tag:Name"
      values = ["mb-prod-vpc"]
    }
}

data "aws_subnet" "mb_public_sub_1a" {
    filter {
      name = "tag:Name"
      values = ["mb-prod-vpc-public-us-east-1a"]
    }
}

module "mbpage_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "mbpage-SG"
  description = "Security group para nossa instancia"
  vpc_id      = data.aws_vpc.mb_vpc.id
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Porta para minha page"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Porta SSH"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules        = ["all-all"]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "WebServer"

  ami                    = "ami-07d02ee1eeb0c996c"
  instance_type          = "t2.micro"
  key_name               = "vockey"
  monitoring             = true
  vpc_security_group_ids = [module.pointer_sg.security_group_id]
  subnet_id              = data.aws_subnet.mb_public_sub_1a.id
  user_data              = file("./dependencias.sh")

  tags = {
    Terraform = "true"
    Environment = "Production"
    CC = "10504"
    OwnerSquad = "Osa"
    OwnerSRE = "Valt"
  }
}

resource "aws_eip" "mbpage-ip" {
  instance = module.ec2_instance.id
  vpc      = true

  tags = {
    Name = "mb-Server-EIP"
  }
}

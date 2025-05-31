resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = var.public_subnet_id # 172.16.0.0/24 (ap-northeast-2a)
  associate_public_ip_address = true

  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = "${var.name_prefix}-bastion"
  }
}

resource "aws_security_group" "bastion" {
  name_prefix = "${var.name_prefix}-bastion-sg"
  vpc_id      = var.vpc_id

  ingress {
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
    Name = "${var.name_prefix}-bastion-sg"
  }
}


resource "aws_security_group" "monitoring" {
  name_prefix = "${var.name_prefix}-monitoring-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  ingress {
    from_port       = 3100
    to_port         = 3100
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-monitoring-sg"
  }
}

resource "aws_instance" "monitoring" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id # 172.16.11.0/24 (ap-northeast-2c)
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.monitoring.id]

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    delete_on_termination = false
  }

  user_data = templatefile("${path.module}/templates/user_data.tpl", {})

  tags = {
    Name = "${var.name_prefix}-monitoring"
  }
}
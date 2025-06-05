# EC2 인스턴스에 할당할 IAM 역할
resource "aws_iam_role" "ec2_role" {
  name = "${var.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM 역할에 ECR ReadOnly 정책 연결
resource "aws_iam_role_policy_attachment" "ecr_readonly_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EC2 인스턴스 프로파일 (IAM 역할을 EC2에 연결)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# 백엔드 인스턴스용 보안그룹 (8080 포트 오픈)
resource "aws_security_group" "backend" {
  name        = "${var.name_prefix}-backend-sg"
  description = "Security group for backend EC2 instance"
  vpc_id      = var.vpc_id

  # Bastion 호스트의 보안그룹에서만 SSH(22) 허용
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "${var.name_prefix}-backend-sg"
  }
}

resource "aws_launch_template" "backend" {
  name_prefix   = "${var.name_prefix}-backend-"
  image_id      = var.ami_id
  instance_type = var.instance_type
 
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.backend.id]
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.tpl", {
    ecr_repository_url = var.ecr_repository_url
    region            = var.region
    monitoring_instance_private_ip = var.monitoring_instance_private_ip
  }))

  # EC2 인스턴스에 할당할 IAM 인스턴스 프로파일 (ECR 접근 등 권한)
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  # 인스턴스에 태그 지정 (이름 등)
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name_prefix}-backend"
    }
  }
}

resource "aws_autoscaling_group" "backend" {
  name                = "${var.name_prefix}-backend-asg"
  desired_capacity    = 2
  max_size           = 4
  min_size           = 1
  target_group_arns  = [var.target_group_arn]
  vpc_zone_identifier = var.private_subnet_ids

  # 인스턴스가 남아있어도 강제 삭제 -> 안쓰면 destroy 에서 한참걸림
  force_delete        = true

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-backend"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.name_prefix}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.backend.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.name_prefix}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.backend.name
}
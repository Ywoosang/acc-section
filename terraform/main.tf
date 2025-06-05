provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source      = "./vpc"
  name_prefix = var.name_prefix
}

module "nat" {
  source = "./nat"
  vpc_id = module.vpc.vpc_id

  # ap-northeast-2a 애 nat gateway 연결
  public_subnet_id = module.vpc.public_subnet_ids[0]

  private_a_id = module.vpc.private_a_id
  private_c_id = module.vpc.private_c_id
  name_prefix  = var.name_prefix
}

module "bastion" {
  source           = "./bastion"
  instance_type    = var.bastion_instance_type
  name_prefix      = var.name_prefix
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  ami_id           = var.ami_id
  key_name         = var.key_name
}

module "ecr" {
  source              = "./ecr"
  ecr_repository_name = var.ecr_repository_name
  name_prefix         = var.name_prefix
}

module "alb" {
  source            = "./alb"
  name_prefix       = var.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "asg" {
  source                         = "./asg"
  instance_type                  = var.app_instance_type
  name_prefix                    = var.name_prefix
  ami_id                         = var.ami_id
  key_name                       = var.key_name
  vpc_id                         = module.vpc.vpc_id
  bastion_sg_id                  = module.bastion.security_group_id
  private_subnet_ids             = module.vpc.private_subnet_ids
  target_group_arn               = module.alb.target_group_arn
  ecr_repository_url             = module.ecr.repository_url
  monitoring_instance_private_ip = module.monitoring.private_ip
}

module "monitoring" {
  source            = "./monitoring"
  instance_type     = var.monitoring_instance_type
  name_prefix       = var.name_prefix
  vpc_id            = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_c_id
  bastion_sg_id     = module.bastion.security_group_id
  backend_sg_id     = module.asg.backend_sg_id
  key_name          = var.key_name
  ami_id            = var.ami_id
}
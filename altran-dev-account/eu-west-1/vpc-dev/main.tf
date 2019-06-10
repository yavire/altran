#terraform init -backend-config="variables-backend.tfbackend"
#terraform plan -var-file="user.tfvars"
#terraform apply -var-file="user.tfvars"

#Generamos la VPC, con una subred pública para el balanceador y dos subredes privadas para los microservicios
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.53.0"

  name = "${var.account}-${var.project_name}"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b"]
  public_subnets  = ["10.0.0.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
  single_nat_gateway = false 

  tags = {
    Terraform = "true"
    Project    = "${var.project_name}"
    Company    = "${var.company_name}"
    Account    = "${var.account}"
    Bucket-state = "${var.company_name}-${var.account}-${var.aws_region}-tfdbstate"
  }
}

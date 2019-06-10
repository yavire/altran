module "security_group_loadbalancer" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.20.0"

  name = "${var.project_name}-${var.account}-loadbalancer"

  description = "Security group for the load balancer"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "https-443-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags = {
    Terraform    = "true"
    Project      = "${var.project_name}"
    Company      = "${var.company_name}"
    Account      = "${var.account}"
    Bucket-state = "${var.company_name}-${var.account}-${var.aws_region}-tfdbstate"
  }
}

module "security_group_springboot" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.20.0"

  name = "${var.project_name}-${var.account}-springboot"

  description = "Security group for the spring boot nodes"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      description = "Spring boot port"
      cidr_blocks = "${data.terraform_remote_state.vpc.public_subnets_cidr}"
    }
  ]
  
  egress_rules        = ["all-all"]

  tags = {
    Terraform    = "true"
    Project      = "${var.project_name}"
    Company      = "${var.company_name}"
    Account      = "${var.account}"
    Bucket-state = "${var.company_name}-${var.account}-${var.aws_region}-tfdbstate"
  }
}

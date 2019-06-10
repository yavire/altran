data "terraform_remote_state" "vpc" {
  backend = "s3"

  #Get VPC Information from the S3 state 
  config {
    bucket  = "${var.company_name}-${var.account}-${var.aws_region}-tfstate"
    key     = "altran-web/eu-west-1/vpc-dev"
    region  = "${var.aws_region}"
    encrypt = true
  }
}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "all" {
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
}



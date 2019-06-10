
#terrafom apply -var-file="user.tfvars"

#Construye el S3 para el entorno de desarrollo
module "terraform-aws-s3-states" {
  source       = "../../modules/terraform-aws-s3-states"
  aws_region   = "${var.aws_region}"
  account      = "${var.account}"
  project_name = "${var.project_name}"
  company_name = "${var.company_name}"
}

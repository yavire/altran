//terraform init --backend-config="access_key=your_access_key" --backend-config="secret_key=your_secret_key"

#Construye es Buckey S3, que se encarga de guardar el estado de las ejecuciones de Terraform. Allí podremos 
#guardar variables que podrán ser utilizados por otras ejecuciones posteriores de terraform.

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.company_name}-${var.account}-${var.aws_region}-tfstate"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Company    = "${var.company_name}"
    Name       = "${var.company_name}-${var.account}-${var.aws_region}-tfstate"
    Account    = "${var.account}"
    Automation = "${var.company_name}-${var.account}-${var.aws_region}-tfstate"
  }
}

resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "${var.company_name}-${var.account}-${var.aws_region}-tfdbstate"
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Company    = "${var.company_name}"
    Name       = "${var.company_name}-${var.account}-${var.aws_region}-tfdbstate"
    Account    = "${var.account}"
    Automation = "${var.company_name}-${var.account}-${var.aws_region}-tfdbstate"
  }
}

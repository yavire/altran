provider "aws" {
  // Get from ./aws/configure
  profile = "development"
  region  = "${var.aws_region}"
}


output "public_ip_loadbalancer" {
  value = "${aws_instance.ec2_loadbalancer.public_ip}"
}

output "private_ip_loadbalancer" {
  value = "${aws_instance.ec2_loadbalancer.private_ip}"
}

output "private_ip_springboot1" {
  value = "${aws_instance.ec2_springboot1.private_ip}"
}

output "private_ip_springboot2" {
  value = "${aws_instance.ec2_springboot1.private_ip}"
}

output "vpc_id" {
  value = "${data.terraform_remote_state.vpc.vpc_id}"
}

output "private_key" {
  value = "${var.private_key}"
}

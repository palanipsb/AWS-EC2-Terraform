locals {
  vpc_name = "${terraform.workspace}-vpc"
  subnet_name = "${terraform.workspace}-subnet"
  iname = "${terraform.workspace}-instance"
  sg_name = "${terraform.workspace}-sg"
}
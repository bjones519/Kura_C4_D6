variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "ami" {
  default = "ami-08c40ec9ead489470"
}
variable "ami-west" {
  default = "ami-0efcece6bed30fd98"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "ami" {
    default = "ami-08c40ec9ead489470"
}
variable "instance_type" {
    default = "t2.micro"
}
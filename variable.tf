variable "access_key" {
     description = "Access key to AWS console"

}
variable "secret_key" {
     description = "Secret key to AWS console"

}

variable "region" {
  default     = "eu-east-1"
  type        = string
  description = "Region of the VPC"
}

variable "ami" {
    description = "AMIs by region"
    default = "ami-02354e95b39ca8dec"
}

variable "instance_type" {
  description = "The type of instance to start"
  default     = "t2.micro"
  type        = string
}

variable "key_name" {
  description = "key name"
  default     = "ec2key"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {Name = "tf-ec2"}
}

variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "pubsubnet_cidr_block" {
  default     = "10.0.0.0/24"
  type        = string
  description = "public subnet CIDR block"
}

variable "availability_zones" {
  default     = ["eu-west-2a", "eu-west-2b"]
  type        = list
  description = "List of availability zones"
}
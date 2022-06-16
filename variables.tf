

variable "region" {
  default = "eu-west-2"
}



variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "enable_dns_support" {
  default = "true"
}


variable "enable_dns_hostnames" {
  default = "true"
}


variable "enable_classiclink" {
  default = "false"
}

variable "enable_classiclink_dns_support" {
  default = "false"
}


# Declare a variable to store the desired number of public subnets, and set the default value
variable "preferred_number_of_public_subnets" {
  type        = number
  description = "Preferred number of public subnets"
}

# Declare a variable to store the desired number of private subnets, and set the default value
variable "preferred_number_of_private_subnets" {
  type        = number
  description = "Preferred number of private subnets"
}

variable "name" {
type = string


}

variable "environment" {
type = string

}

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
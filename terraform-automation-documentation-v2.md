### AUTOMATE INFRASTRUCTURE WITH IAC USING TERRAFORM - CONTINUATION
---

# Set up tagging for our resources

In file variables .tf, I declared the variables tag and name

```
variable "name" {
type = string
default = "Acme"

}

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}

```
Then in file terraform.tfvars, I set values for tags

```
tags = {
  name            = "Acme"
  Enviroment      = "production"
  Owner-Email     = "dare@darey.io"
  Managed-By      = "Terraform"
  Billing-Account = "1234567890"
}

```

In main.tf , I implemented tagging in the public subnets

```
# Create public subnets
resource "aws_subnet" "public" {
  count                   = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

tags = merge(
var.tags,
{
  Name = format("%s-Public-Subnet-%s", var.name, count.index)
},

)
}

```

![Tagging Public Subnets](./images/tagging1.JPG)  

### error when I ran terraform plan

```
data.aws_availability_zones.available: Reading...
data.aws_availability_zones.available: Read complete after 0s [id=eu-west-2]
╷
│ Error: Invalid index
│
│   on main.tf line 49, in resource "aws_subnet" "private":
│   49:   availability_zone       = data.aws_availability_zones.available.names[count.index]
│     ├────────────────
│     │ count.index is 3
│     │ data.aws_availability_zones.available.names is list of string with 3 elements
│
│ The given key does not identify an element in this collection value: the given index is greater than or equal to the length of the collection.

```

# SOLUTION
---
# Substitute

```
availability_zone       = data.aws_availability_zones.available.names[count.index]
```
# With

```
availability_zone       = element(data.aws_availability_zones.available.names[*], count.index)
```

### Next I tagged the resources with name and environment by declaring in variables.tf and setting in terraform.tfvars
-

### terraform.tfvars
---
```
environment = "Development"
name = "Acme"

tags = {
  Environment = "production"
  Owner-Email = "dare@darey.io"
  Managed-By = "Terraform"
  Billing-Account = "1234567890"
}
```

### Vriables.tf
---
```
variable "name" {
type = string


}

variable "environment" {
type = string

}
```
```
Test
```


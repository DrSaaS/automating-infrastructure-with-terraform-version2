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
CREATE ROUTE TABLES AND ATTACH TO GATEWAYS
```

```
# Create private route table
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.main.id

 
  }



# Create route for the private route table and attach a nat gateway to it
  resource "aws_route" "private-rtb-route" {
  route_table_id            = aws_route_table.private-rtb.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat_gw.id
}



resource "aws_route_table_association" "private-subnet-assoc" {
  count = length(aws_subnet.private[*].id)
  subnet_id = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private-rtb.id
}


# Create public route table
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.main.id

 
  }

  # Create route for the public route table and attach to internet gateway to it
  resource "aws_route" "public-rtb-route" {
  route_table_id            = aws_route_table.public-rtb.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig.id
}


resource "aws_route_table_association" "public-subnet-assoc" {
  count = length(aws_subnet.public[*].id)
  subnet_id = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public-rtb.id
}
```

### The next task is to create the load balancer , auto scaling groups, target group and launch template. We also need a certificate for the load balancer.

### Create Cert
---
I created a new file cert.tf
I requested a certificate, valdated and created records for websites wordpress and tooling

```
resource "aws_acm_certificate" "workachoo" {
  domain_name       = "*.workachoo.com"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}


# calling the hosted zone

data "aws_route53_zone" "workachoo" {
 name = "workachoo.com"
 private_zone = false

} 

# selecting validation method

resource "aws_route53_record" "workachoo"{
for_each = {

  for dvo in aws_acm_certificate.workachoo.domain_validation_options : dvo.domain_name =>{

       name = dvo.resource_record_name
       record = dvo.resource_record_value
       type = dvo.resource_record_type
       
  }
}
allow_overwrite = true
name = each.value.name
records = each.value.record
ttl = 60
type = each.value.type
zone_id = aws_route53_zone.workachoo.zone_id



}

# validate the certificate through DNS method

resource "aws_acm_certificate_validation" "workachoo" {
  certificate_arn         = aws_acm_certificate.workachoo.arn
  validation_record_fqdns = [for record in aws_route53_record.workachoo : record.fqdn]
}


# create records for tooling
resource "aws_route53_record" "tooling" {
  zone_id = data.aws_route53_zone.workachoo.zone_id
  name    = "tooling.workachoo.com"
  type    = "A"

  alias {
    name                   = aws_lb.ext-alb.dns_name
    zone_id                = aws_lb.ext-alb.zone_id
    evaluate_target_health = true
  }
}


# create records for wordpress
resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.oyindamola.zone_id
  name    = "wordpress.workachoo.com"
  type    = "A"

  alias {
    name                   = aws_lb.ext-alb.dns_name
    zone_id                = aws_lb.ext-alb.zone_id
    evaluate_target_health = true
  }
}
```
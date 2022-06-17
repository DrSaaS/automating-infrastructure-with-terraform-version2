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
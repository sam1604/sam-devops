resource "aws_vpc" "samuel-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "samuel-vpc"
  }
}

resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id     = aws_vpc.samuel-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Prod-pub-sub1"
  }
}

resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id     = aws_vpc.samuel-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Prod-pub-sub2"
  }
}

resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id     = aws_vpc.samuel-vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Prod-priv-sub1"
  }
}

resource "aws_subnet" "Prod-priv-sub2" {
  vpc_id     = aws_vpc.samuel-vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Prod-priv-sub2"
  }
}

resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id = aws_vpc.samuel-vpc.id


  tags = {
    Name = "Prod-pub-route-table"
  }
}

resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id = aws_vpc.samuel-vpc.id


  tags = {
    Name = "Prod-priv-route-table"
  }
}

resource "aws_route_table_association" "Pub-route-association-1" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "Pub-route-association-2" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "Priv-route-association-1" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

resource "aws_route_table_association" "Priv-route-association-2" {
  subnet_id      = aws_subnet.Prod-priv-sub2.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.samuel-vpc.id

  tags = {
    Name = "Prod-igw"
  }
}

resource "aws_route" "Prod-igw-association" {
  route_table_id            = aws_route_table.Prod-pub-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.Prod-igw.id
}

#EIP for nat gateway

resource "aws_eip" "nat_eip" {

  depends_on = [aws_internet_gateway.Prod-igw]

  tags = {

    name = "Nat gateway EIP"

  }

}


#nat gateway 

resource "aws_nat_gateway" "Prod-Nat-Gateway" {

  allocation_id = aws_eip.nat_eip.id

  subnet_id     = aws_subnet.Prod-pub-sub2.id


 tags = {

    Name = "Prod-Nat-Gateway"

  }

}

#route table for Nat gateway 

resource "aws_route_table" "Nat-priv-route-table" {

  vpc_id = aws_vpc.samuel-vpc.id




  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.Prod-igw.id

  }




  tags = {

    Name = "Nat-priv-route-table"

  }

}


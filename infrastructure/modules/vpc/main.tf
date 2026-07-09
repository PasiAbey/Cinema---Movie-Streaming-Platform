resource "aws_vpc" "main-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc-name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${var.vpc-name}-igw"
  }
}




resource "aws_subnet" "public_subnet-01" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = var.public-subnet-01-cidr-block
  availability_zone = var.availability-zone-01
  map_public_ip_on_launch = true

  tags = {
    Name = var.public-subnet-01-name
  }
}

resource "aws_subnet" "private_subnet-01" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = var.private-subnet-01-cidr-block
  availability_zone = var.availability-zone-01
  tags = {
    Name = var.private-subnet-01-name
  }
}



resource "aws_subnet" "public_subnet-02" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = var.public-subnet-02-cidr-block
  availability_zone = var.availability-zone-02
  map_public_ip_on_launch = true

  tags = {
    Name = var.public-subnet-02-name
  }
}

resource "aws_subnet" "private_subnet-02" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = var.private-subnet-02-cidr-block
  availability_zone = var.availability-zone-02
  tags = {
    Name = var.private-subnet-02-name
  }
}



resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc-name}-public-rt"
  }
}

#Public Route Table and Associations
resource "aws_route_table_association" "public_rt_assoc-01" {
  subnet_id      = aws_subnet.public_subnet-01.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc-02" {
  subnet_id      = aws_subnet.public_subnet-02.id
  route_table_id = aws_route_table.public_rt.id
}



#Private Route Table and Associations
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "${var.vpc-name}-private-rt"
  }
}

resource "aws_route_table_association" "private_rt_assoc-01" {
  subnet_id      = aws_subnet.private_subnet-01.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_assoc-02" {
  subnet_id      = aws_subnet.private_subnet-02.id
  route_table_id = aws_route_table.private_rt.id
}
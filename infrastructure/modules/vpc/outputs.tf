output "vpc-id" {
  value = aws_vpc.main-vpc.id
}

output "public-subnet-01-id" {
  value = aws_subnet.public_subnet-01.id
}

output "private-subnet-01-id" {
  value = aws_subnet.private_subnet-01.id
}

output "public-subnet-02-id" {
  value = aws_subnet.public_subnet-02.id
}

output "private-subnet-02-id" {
  value = aws_subnet.private_subnet-02.id
}
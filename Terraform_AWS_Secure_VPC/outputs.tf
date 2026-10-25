output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for s in aws_subnet.private : s.id]
}

output "nat_public_ip" {
  description = "Public IP that private subnets use to reach the internet"
  value       = aws_eip.nat.public_ip
}

output "app_security_group_id" {
  description = "ID of the app security group"
  value       = aws_security_group.app.id
}

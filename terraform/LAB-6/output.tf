output "security_groups_id" {
  value = aws_security_group.demo-sg.id
}


locals {
  public_dns_names = { for key, instance in aws_instance.demo : key => instance.public_dns }
}


output "public_dns_of_servers" {
  value = values(local.public_dns_names)
}
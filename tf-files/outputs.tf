# # Output the URL of the Route 53 record pointing to the application
# output "websiteurl" {
#   value = "http://${aws_route53_record.order-table.name}"  # Construct the URL using Route 53 DNS name
# }

# Output the DNS name of the Application Load Balancer (ALB)
output "dns-name" {
  value = "http://${aws_alb.app-lb.dns_name}"  # Construct the URL using ALB DNS name
}

# Output the address of the RDS database instance
output "db-addr" {
  value = aws_db_instance.db-server.address  # Retrieve the address of the RDS instance
}

# Output the endpoint of the RDS database instance
output "db-endpoint" {
  value = aws_db_instance.db-server.endpoint  # Retrieve the endpoint of the RDS instance
}

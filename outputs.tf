output "instance_id" {
  description = "LoadBalancer DNS Name"
  value       = aws_lb.load_balancer.dns_name
}

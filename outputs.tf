output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "website_url" {
  description = "Click here to see your app"
  value       = "http://${aws_instance.app_server.public_ip}:1337"
}
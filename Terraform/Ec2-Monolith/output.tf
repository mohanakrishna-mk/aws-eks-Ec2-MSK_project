
# ======================================================
# OUTPUTS
# ======================================================

output "ec2_react_frontend_public_ip" {
  value = aws_instance.ec2_react_frontend_server.public_ip
}

output "ec2_nodejs_backend_public_ip" {
  value = aws_instance.ec2_nodejs_backend_server.public_ip
}

output "ec2_java_backend_public_ip" {
  value = aws_instance.ec2_java_backend_server.public_ip
}

output "ec2_mongodb_public_ip" {
  value = aws_instance.ec2_mongodb_server.public_ip
}
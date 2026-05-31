

# =========================================================
# OUTPUTS
# =========================================================
/*
output "gitlab_public_ip" {
  value = aws_instance.ci_cd_gitlab_server.public_ip
}
*/
output "runner1_public_ip" {
  value = aws_instance.ci_cd_runner_1.public_ip
}

output "runner2_public_ip" {
  value = aws_instance.ci_cd_runner_2.public_ip
}

output "nexus_public_ip" {
  value = aws_instance.ci_cd_nexus_server.public_ip
}

output "sonarqube_public_ip" {
  value = aws_instance.ci_cd_sonarqube_server.public_ip
}
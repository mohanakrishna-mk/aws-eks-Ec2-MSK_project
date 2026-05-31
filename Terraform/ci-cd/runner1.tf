resource "aws_instance" "ci_cd_runner_1" {
  ami                         = "ami-03f4878755434977f"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.ci_cd_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ci_cd_sg.id]
  associate_public_ip_address = true
  key_name                    = "ec2-key"

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = <<-EOF
#!/bin/bash
set -eux

exec > >(tee /var/log/user-data.log)
exec 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl git jq

curl -fsSL https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash

apt-get install -y gitlab-runner

systemctl enable gitlab-runner
systemctl start gitlab-runner
EOF

  tags = {
    Name        = "ci-cd-runner-1"
    Environment = "dev"
    Project     = "ci-cd"
  }
}
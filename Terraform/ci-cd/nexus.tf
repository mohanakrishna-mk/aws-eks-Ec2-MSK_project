resource "aws_instance" "ci_cd_nexus_server" {
  ami                         = "ami-03f4878755434977f"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.ci_cd_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ci_cd_sg.id]
  associate_public_ip_address = true
  key_name                    = "ec2-key"

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  user_data = <<-EOF
#!/bin/bash
set -eux

exec > >(tee /var/log/user-data.log)
exec 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y wget tar openjdk-17-jdk

sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" >> /etc/sysctl.conf

id nexus || useradd -r -m -s /bin/bash nexus

cd /opt

wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz -O nexus.tar.gz

tar -xzf nexus.tar.gz

NEXUS_DIR=$(find /opt -maxdepth 1 -type d -name "nexus-*" | head -1)

mv "$NEXUS_DIR" /opt/nexus

mkdir -p /opt/sonatype-work

chown -R nexus:nexus /opt/nexus
chown -R nexus:nexus /opt/sonatype-work

echo 'run_as_user="nexus"' > /opt/nexus/bin/nexus.rc

cat > /etc/systemd/system/nexus.service <<SERVICE
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus

ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop

Restart=on-failure

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable nexus
systemctl start nexus
EOF

  tags = {
    Name = "ci-cd-nexus-server"
  }
}
resource "aws_instance" "ci_cd_sonarqube_server" {
  ami                         = "ami-03f4878755434977f"
  instance_type               = "t3.large"
  subnet_id                   = aws_subnet.ci_cd_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ci_cd_sg.id]
  associate_public_ip_address = true
  key_name                    = "ec2-key"

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  user_data = <<-EOF
#!/bin/bash
set -eux

exec > >(tee /var/log/user-data.log)
exec 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update -y

apt-get install -y \
  openjdk-17-jdk \
  unzip \
  wget \
  postgresql \
  postgresql-contrib

cat >> /etc/sysctl.conf <<SYSCTL
vm.max_map_count=524288
fs.file-max=131072
SYSCTL

sysctl -p

systemctl enable postgresql
systemctl start postgresql

until pg_isready; do
  sleep 5
done

sudo -u postgres psql <<SQL
CREATE USER sonar WITH ENCRYPTED PASSWORD 'Sonar@123';
CREATE DATABASE sonarqube OWNER sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;
SQL

id sonar || useradd -r -m -s /bin/bash sonar

cd /tmp

wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-25.11.0.114957.zip

unzip sonarqube-25.11.0.114957.zip

mv sonarqube-25.11.0.114957 /opt/sonarqube

chown -R sonar:sonar /opt/sonarqube

cat >> /opt/sonarqube/conf/sonar.properties <<CONF

sonar.jdbc.username=sonar
sonar.jdbc.password=Sonar@123
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
CONF

cat > /etc/systemd/system/sonarqube.service <<SERVICE
[Unit]
Description=SonarQube
After=network.target postgresql.service

[Service]
Type=forking
User=sonar
Group=sonar

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

Restart=always
LimitNOFILE=131072
LimitNPROC=8192

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube
EOF

  tags = {
    Name = "ci-cd-sonarqube-server"
  }
}
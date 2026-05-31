

# Recommended AWS Console Names

| Resource         | AWS Console Name          |
| ---------------- | ------------------------- |
| VPC              | EC2-VPC                   |
| Internet Gateway | EC2-IGW                   |
| Subnet 1         | EC2-Public-Subnet-1       |
| Subnet 2         | EC2-Public-Subnet-2       |
| Route Table      | EC2-Public-RT             |
| Security Group   | EC2-SG                    |
| React Server     | EC2-React-Frontend-Server |
| NodeJS Server    | EC2-NodeJS-Backend-Server |
| Java Server      | EC2-Java-Backend-Server   |
| MongoDB Server   | EC2-MongoDB-Server        |

# Deployment Flow

```text
GitLab CI/CD
      ↓
Build React App
      ↓
Deploy to EC2-React-Frontend-Server

Build NodeJS Backend
      ↓
Deploy to EC2-NodeJS-Backend-Server

Build Java Backend
      ↓
Deploy to EC2-Java-Backend-Server
```

# Recommended Domains

| Service        | Domain           |
| -------------- | ---------------- |
| React Frontend | app.ec2.com      |
| NodeJS API     | api.ec2.com      |
| Java API       | java-api.ec2.com |
| MongoDB        | Private Only     |

# Terraform Commands

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```
---------------------------------
# Team Structure for EC2 MERN + Java Infrastructure

## Infrastructure Overview

```text
Users
   ↓
Route53 DNS
   ↓
Load Balancer / NGINX
   ↓
------------------------------------------------
|                    |                         |
React Server     NodeJS Server           Java Server
NGINX             PM2                     Tomcat
                        ↓
                    MongoDB

CI/CD:
GitLab → Runners → SonarQube → Nexus
```

---

# Teams

| Team             | Responsibility                  |
| ---------------- | ------------------------------- |
| Linux Admin Team | OS, server, patching, security  |
| Middleware Team  | NGINX, PM2, Tomcat, deployments |
| DevOps Team      | CI/CD, GitLab, Terraform        |
| Application Team | React, NodeJS, Java code        |
| DBA Team         | MongoDB                         |
| Monitoring Team  | Alerts, dashboards              |
| Cloud Team       | AWS infra, networking           |

---

# 1. Linux Administrator Roles & Responsibilities

# Server Provisioning

Tasks:

* Create EC2 instances
* Configure hostname
* Configure EBS volumes
* Configure partitions
* Configure swap memory
* Configure SSH access

Commands:

```bash
hostnamectl

lsblk

fdisk -l
```

---

# OS Installation & Configuration

Tasks:

* Ubuntu/RHEL installation
* Configure timezone
* Configure repositories
* Install required packages
* Configure networking

Commands:

```bash
timedatectl

ip a

netstat -tulnp
```

---

# User Management

Tasks:

* Create users
* Manage groups
* Configure sudo access
* Password policies
* SSH key management

Commands:

```bash
useradd

passwd

visudo
```

---

# Security Hardening

Tasks:

* Disable root SSH login
* Configure firewall
* Install antivirus if needed
* Configure fail2ban
* SSH hardening

Commands:

```bash
ufw status

iptables -L

systemctl status ssh
```

---

# Package Management

Tasks:

* Patch updates
* Security updates
* Install NodeJS/Java
* Maintain dependencies

Commands:

```bash
apt update

apt upgrade -y
```

---

# Storage Management

Tasks:

* Disk monitoring
* Mount volumes
* Extend filesystem
* EBS management
* Cleanup logs

Commands:

```bash
df -h

du -sh *

mount

resize2fs
```

---

# Process Management

Tasks:

* Monitor services
* Restart failed services
* Monitor CPU/RAM
* Zombie process handling

Commands:

```bash
top

htop

ps -ef

kill -9 PID
```

---

# Log Management

Tasks:

* Monitor logs
* Rotate logs
* Troubleshoot issues
* Central logging

Commands:

```bash
journalctl -xe

tail -f /var/log/syslog
```

---

# Backup Management

Tasks:

* EBS snapshots
* Application backup
* MongoDB backup
* Restore testing

---

# Monitoring Responsibilities

Tasks:

* CPU alerts
* RAM alerts
* Disk alerts
* Network monitoring

Tools:

* CloudWatch
* Grafana
* Prometheus

---

# Troubleshooting Tasks

Tasks:

* Server down
* High CPU
* Memory leak
* Disk full
* SSH failure
* Boot issues

Commands:

```bash
systemctl status

reboot

free -m
```

---

# Linux Admin Daily Activities

| Activity           | Description         |
| ------------------ | ------------------- |
| Health Checks      | CPU, memory, disk   |
| Log Checks         | Errors and warnings |
| Patch Verification | Security updates    |
| User Audit         | Access validation   |
| Backup Check       | Backup validation   |
| Service Validation | NGINX, PM2, Tomcat  |

---

# 2. Middleware Team Roles & Responsibilities

Middleware team manages:

* NGINX
* PM2
* Tomcat
* Reverse proxy
* SSL
* Application runtime

---

# NGINX Responsibilities

Tasks:

* Configure reverse proxy
* SSL certificate setup
* Redirect HTTP → HTTPS
* Load balancing
* Static content serving

Files:

```bash
/etc/nginx/nginx.conf

/etc/nginx/sites-enabled/
```

Commands:

```bash
nginx -t

systemctl restart nginx
```

---

# NGINX Troubleshooting

Tasks:

* 502 Bad Gateway
* 504 Timeout
* SSL issues
* Port conflicts

Commands:

```bash
tail -f /var/log/nginx/error.log

ss -tulnp
```

---

# PM2 Responsibilities

Tasks:

* Start NodeJS app
* Restart crashed app
* Configure startup
* Log management
* Zero downtime reload

Commands:

```bash
pm2 start app.js

pm2 restart app

pm2 logs

pm2 monit
```

---

# PM2 Monitoring

Tasks:

* Memory monitoring
* Auto restart
* Process scaling

Commands:

```bash
pm2 list

pm2 status
```

---

# Tomcat Responsibilities

Tasks:

* Deploy WAR files
* Configure Tomcat
* Configure JVM memory
* Restart services
* Configure connectors

Directories:

```bash
/opt/tomcat/webapps/

/opt/tomcat/conf/server.xml
```

Commands:

```bash
systemctl restart tomcat

catalina.sh start
```

---

# Tomcat Troubleshooting

Tasks:

* App not loading
* Heap memory issue
* Port already used
* WAR deployment failure

Commands:

```bash
catalina.out

netstat -tulnp

jps

jstack
```

---

# SSL Management

Tasks:

* SSL renewal
* Install certificates
* Verify HTTPS

Commands:

```bash
openssl x509 -in cert.pem -text
```

---

# Reverse Proxy Management

Tasks:

* React → NodeJS routing
* API gateway configuration
* Header forwarding

Example:

```nginx
location /api {
    proxy_pass http://localhost:5000;
}
```

---

# Deployment Responsibilities

Tasks:

* Receive artifact from CI/CD
* Deploy build
* Restart services
* Rollback if failed

---

# Application Health Checks

Tasks:

* API validation
* Service uptime
* Port validation
* DB connectivity

Commands:

```bash
curl localhost:5000/health

curl localhost:8080
```

---

# Middleware Daily Activities

| Activity           | Description         |
| ------------------ | ------------------- |
| Check NGINX        | Errors, reloads     |
| Check PM2          | Process status      |
| Check Tomcat       | Heap, deployment    |
| SSL Check          | Expiry verification |
| Application Logs   | Runtime issues      |
| Deployment Support | Release handling    |

---

# 3. DevOps Team Responsibilities

Tasks:

* GitLab pipelines
* Terraform
* CI/CD automation
* Nexus maintenance
* SonarQube maintenance
* Docker image builds

Tools:

* GitLab
* Terraform
* Nexus
* SonarQube
* Docker

---

# 4. DBA Team Responsibilities

Tasks:

* MongoDB backup
* Performance tuning
* Replication
* Index optimization
* Query tuning

Commands:

```bash
mongosh

db.stats()
```

---

# 5. Cloud/AWS Team Responsibilities

Tasks:

* VPC management
* Security groups
* IAM roles
* Route53
* ALB/NLB
* Auto scaling

Services:

* EC2
* VPC
* CloudWatch
* Route53
* IAM

---

# Real Production Workflow

```text
Developer
   ↓
Git Push
   ↓
GitLab Pipeline
   ↓
Code Build
   ↓
SonarQube Scan
   ↓
Artifact Upload to Nexus
   ↓
Deployment Team
   ↓
Middleware Team Deploys
   ↓
Linux Team Validates Server
   ↓
Monitoring Team Monitors
```

---

# Important Real-Time Issues Teams Handle

| Issue             | Team       |
| ----------------- | ---------- |
| Server Down       | Linux      |
| SSL Expired       | Middleware |
| API 502 Error     | Middleware |
| EC2 Stopped       | Cloud      |
| High CPU          | Linux      |
| Deployment Failed | DevOps     |
| Mongo Slow        | DBA        |
| PM2 Crash         | Middleware |
| Tomcat Heap Full  | Middleware |
| Route53 Issue     | Cloud      |

---

# Production Skills Needed

## Linux Admin

* Linux
* Shell scripting
* Networking
* Monitoring
* Security
* Storage

---

## Middleware Engineer

* NGINX
* PM2
* Tomcat
* Java runtime
* SSL
* Reverse proxy

---

## DevOps Engineer

* Terraform
* Docker
* Kubernetes
* GitLab
* CI/CD
* AWS

---

# Common Interview Questions

## Linux Admin

* Difference between soft and hard link
* Top vs htop
* How to troubleshoot high CPU
* Explain inode
* Explain swap memory

---

## Middleware

* What is reverse proxy
* Explain PM2 cluster mode
* Difference between Apache and NGINX
* Tomcat deployment process
* How SSL works

---

## DevOps

* Explain CI/CD
* Terraform state
* Docker networking
* Kubernetes ingress
* GitLab runner types

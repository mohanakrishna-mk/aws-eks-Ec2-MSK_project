# How Teams Work Together in Real Production

You do not “configure teams” technically.
You configure:

* responsibilities
* access
* environments
* workflows
* approvals
* ownership

---

# Real Enterprise Structure

```text id="q4f9f7"
                    COMPANY INFRA
                           |
 -------------------------------------------------
 |               |              |                |
Linux Team   Middleware     DevOps Team      Cloud Team
                 Team
                                  |
                           Application Teams
```

---

# 1. Linux Team Configuration

Linux team manages:

* OS
* EC2 health
* patches
* storage
* users
* monitoring

---

# Access Given

| Access      | Type          |
| ----------- | ------------- |
| SSH Access  | EC2           |
| sudo access | Linux servers |
| CloudWatch  | Read          |
| Logs        | Read          |
| AWS EC2     | Limited       |

---

# Linux Team Responsibilities Mapping

| Server         | Linux Team Responsibility |
| -------------- | ------------------------- |
| React Server   | OS + NGINX                |
| NodeJS Server  | OS + PM2                  |
| Java Server    | OS + Tomcat               |
| MongoDB Server | OS + storage              |

---

# Example Linux Team User Creation

```bash id="g3wp7s"
sudo adduser linuxadmin

sudo usermod -aG sudo linuxadmin
```

---

# SSH Key Setup

```bash id="k8fxup"
mkdir ~/.ssh

chmod 700 ~/.ssh

nano ~/.ssh/authorized_keys
```

---

# 2. Middleware Team Configuration

Middleware team manages:

* NGINX
* PM2
* Tomcat
* deployments
* SSL

---

# Middleware Access

| Access        | Type                |
| ------------- | ------------------- |
| SSH           | Application servers |
| sudo          | Limited             |
| NGINX configs | Full                |
| PM2           | Full                |
| Tomcat        | Full                |

---

# Middleware User

```bash id="7xg3n7"
sudo adduser middleware

sudo usermod -aG sudo middleware
```

---

# Folder Permissions

## NodeJS App

```bash id="qmgvha"
sudo chown -R middleware:middleware /opt/node-app
```

---

## Tomcat

```bash id="h3vqwg"
sudo chown -R middleware:middleware /opt/tomcat
```

---

# Middleware Responsibilities

| Component  | Responsibility |
| ---------- | -------------- |
| NGINX      | Reverse proxy  |
| PM2        | NodeJS runtime |
| Tomcat     | Java runtime   |
| SSL        | HTTPS          |
| Deployment | App deployment |

---

# 3. DevOps Team Configuration

DevOps manages:

* GitLab
* CI/CD
* Terraform
* Nexus
* SonarQube

---

# DevOps Access

| Access       | Type  |
| ------------ | ----- |
| GitLab Admin | Full  |
| Terraform    | Full  |
| AWS IAM      | Infra |
| Runners      | Full  |
| Nexus        | Full  |

---

# IAM Policy Example

```json id="5qg9mt"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "iam:*"
      ],
      "Resource": "*"
    }
  ]
}
```

---

# 4. Cloud Team Configuration

Cloud team manages:

* VPC
* subnet
* IAM
* ALB
* Route53
* security groups

---

# Cloud Team Access

| Access      | Type      |
| ----------- | --------- |
| AWS Console | Full      |
| Networking  | Full      |
| Billing     | Sometimes |
| IAM         | Full      |

---

# 5. Application Team Configuration

Application teams:

* React developers
* NodeJS developers
* Java developers

---

# Access Given

| Access      | Type         |
| ----------- | ------------ |
| GitLab repo | Full         |
| EC2         | Usually none |
| Logs        | Limited      |
| CI/CD       | Read         |

---

# GitLab Project Structure

```text id="6b7msv"
gitlab
   |
   |--- react-frontend
   |
   |--- node-backend
   |
   |--- java-backend
```

---

# Branch Strategy

```text id="ttkh98"
main
  |
develop
  |
feature/*
```

---

# Team Workflow

# Step 1 — Developer Pushes Code

```text id="m6gjqk"
Developer
   ↓
Git Push
```

---

# Step 2 — GitLab CI Runs

```text id="o5s2vz"
GitLab Runner
   ↓
npm install
mvn clean install
npm build
```

---

# Step 3 — SonarQube Scan

```text id="txnhkh"
Code Quality Check
```

---

# Step 4 — Artifact Upload

```text id="cjlwm2"
Nexus Repository
```

---

# Step 5 — Middleware Deployment

Middleware team:

* copies artifact
* restarts PM2
* deploys WAR to Tomcat

---

# Step 6 — Linux Team Validation

Linux team checks:

* CPU
* memory
* logs
* services

---

# Example Responsibilities Matrix (RACI)

| Task           | Linux | Middleware | DevOps | Cloud | App |
| -------------- | ----- | ---------- | ------ | ----- | --- |
| EC2 Creation   |       |            |        | ✔     |     |
| OS Patch       | ✔     |            |        |       |     |
| NGINX Config   |       | ✔          |        |       |     |
| PM2 Restart    |       | ✔          |        |       |     |
| CI/CD Pipeline |       |            | ✔      |       |     |
| React Code     |       |            |        |       | ✔   |
| Terraform      |       |            | ✔      | ✔     |     |
| SSL Renewal    |       | ✔          |        |       |     |
| MongoDB Backup | ✔     |            |        |       |     |

---

# Folder Ownership Strategy

## React

```bash id="6tfcjv"
/var/www/react-app
```

Owner:

```bash id="rxnh9d"
middleware:middleware
```

---

## NodeJS

```bash id="w8o6eo"
/opt/node-backend
```

---

## Java

```bash id="vdbjlwm"
/opt/tomcat/webapps
```

---

# Service Ownership

| Service | Team       |
| ------- | ---------- |
| NGINX   | Middleware |
| PM2     | Middleware |
| Tomcat  | Middleware |
| EC2 OS  | Linux      |
| IAM     | Cloud      |
| GitLab  | DevOps     |

---

# Monitoring Ownership

| Monitoring     | Team       |
| -------------- | ---------- |
| EC2 CPU        | Linux      |
| App Health     | Middleware |
| CI/CD Failures | DevOps     |
| Network Issues | Cloud      |

---

# Alerting Setup

## CloudWatch

Alerts:

* CPU > 80%
* Disk > 85%
* Memory > 90%

---

# Middleware Alerts

Alerts:

* PM2 stopped
* Tomcat stopped
* NGINX 502 errors

---

# Security Setup

# Linux Team

* SSH hardening
* firewall
* fail2ban

---

# Cloud Team

* IAM least privilege
* security groups
* VPC isolation

---

# Middleware Team

* SSL certificates
* reverse proxy security
* app headers

---

# Real Production Deployment Model

```text id="sn3rgo"
DEV Environment
      ↓
QA Environment
      ↓
UAT Environment
      ↓
PROD Environment
```

Each environment:

* separate VPC
* separate EC2
* separate DB
* separate CI/CD

---

# Real Company Daily Operations

## Linux Team Daily

* patching
* server health
* backups
* storage cleanup

---

## Middleware Team Daily

* deployments
* PM2 checks
* Tomcat heap checks
* SSL validation

---

## DevOps Team Daily

* pipeline fixes
* runner issues
* Terraform changes
* deployment automation

---

# Real Escalation Flow

```text id="y38bq3"
Application Down
      ↓
Middleware Team Checks
      ↓
If OS issue → Linux Team
      ↓
If Infra issue → Cloud Team
      ↓
If Pipeline issue → DevOps Team
```

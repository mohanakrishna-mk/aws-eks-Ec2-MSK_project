sudo apt update -y 
sudo apt install ca-certificates curl openssh-server tzdata perl

cd /tmp
curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh


sudo bash /tmp/script.deb.sh

sudo apt install gitlab-ce

sudo sed -i "s|^external_url .*|external_url 'http://gitlab.99cloudtest.com'|" /etc/gitlab/gitlab.rb

sudo gitlab-ctl reconfigure

#!/bin/bash
set -e

apt-get update -y
apt-get install -y ca-certificates curl openssh-server tzdata perl

curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash

EXTERNAL_URL="https://gitlab.99cloudtest.com" apt-get install -y gitlab-ce
#!/bin/bash
set -euo pipefail

sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1) 
sudo apt update
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-${VERSION_CODENAME}}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
VERSION_STRING=(apt list --all-versions docker-ce | grep docker-ce | head -1 | awk '{print $2}')
echo "Installing Docker version: $VERSION_STRING"
sudo apt install -y docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin

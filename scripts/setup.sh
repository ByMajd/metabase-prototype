#!/bin/bash

set -e

echo "Updating system packages..."
sudo apt-get update

echo "Installing required packages..."
sudo apt-get install -y ca-certificates curl git

echo "Adding Docker repository..."
sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

echo "Installing Docker..."
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "Adding azureuser to Docker group..."
sudo usermod -aG docker azureuser

echo "Enabling Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Docker installation complete."
docker --version
docker compose version
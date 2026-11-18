#!/usr/bin/env bash
set -e

apt-get update -y
apt-get install -y curl ca-certificates
curl -fsSL https://get.docker.com | sh
usermod -aG docker vagrant
systemctl enable docker
systemctl start docker

docker --version
docker compose version
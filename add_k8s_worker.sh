#!/bin/bash

set -e

# Variables
ip="*.*.*.*"
hostname="****"
token="****"  # Основной токен для соединения
discovery_token_ca_cert_hash="sha256:****"  # CA Cert Hash

# Update and upgrade
apt-get update && apt-get upgrade -y

# Install necessary packages
apt install -y curl apt-transport-https vim git wget software-properties-common lsb-release ca-certificates

# Disable swap
swapoff -a
sed -i '/\/swap.img/s/^/#/' /etc/fstab

# Load required kernel modules
modprobe overlay
modprobe br_netfilter

# Configure sysctl settings
cat <<EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

# Add Docker repository and install containerd
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update && apt-get install -y containerd.io

# Configure containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd

# Add Kubernetes repository and install kubelet, kubeadm, and kubectl
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
apt update && apt -y install kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Update /etc/hosts
echo "$ip $hostname" >> /etc/hosts

# Join the Kubernetes cluster
kubeadm join \
--token $token \
$hostname:6443 \
--discovery-token-ca-cert-hash $discovery_token_ca_cert_hash

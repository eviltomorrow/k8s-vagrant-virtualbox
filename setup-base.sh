#!/bin/bash

echo "Setup base env"

sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

swapoff -a && sed -ri 's/.*swap.*/#&/' /etc/fstab
systemctl stop firewalld.service && systemctl disable --now firewalld.service
setenforce 0; sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
timedatectl set-timezone Asia/Shanghai
systemctl enable --now chronyd
timedatectl set-local-rtc 0
systemctl restart rsyslog && systemctl restart crond

cat >> /etc/hosts <<EOF
192.168.33.10 master
192.168.33.11 node01
192.168.33.12 node02
EOF

cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sysctl --system

yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install containerd.io -y

mkdir -p /etc/containerd; cp /vagrant/config.toml /etc/containerd/config.toml
systemctl restart containerd && systemctl enable --now containerd

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# export KUBE_VERSION=1.22.0
# yum install -y kubelet-${KUBE_VERSION} kubeadm-${KUBE_VERSION} kubectl-${KUBE_VERSION} --disableexcludes=kubernetes
systemctl enable --now kubelet

cat <<EOF > /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF
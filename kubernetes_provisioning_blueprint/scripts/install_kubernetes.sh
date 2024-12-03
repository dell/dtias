#!/bin/bash

set -e

# Update system and install required packages
yum update -y
yum install -y yum-utils device-mapper-persistent-data lvm2
yum install -y docker kubelet kubeadm kubectl --disableexcludes=kubernetes

# Enable and start Docker and kubelet services
systemctl enable docker.service
systemctl start docker.service
systemctl enable kubelet.service
systemctl start kubelet.service


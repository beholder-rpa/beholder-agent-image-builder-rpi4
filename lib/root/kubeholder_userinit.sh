#!/bin/bash

git clone --depth=1 https://github.com/beholder-rpa/beholder-iot ~/beholder

# Install kubectl
arkade get kubectl
sudo mv /home/beholder/.arkade/bin/kubectl /usr/local/bin/

# Install helm
arkade get helm
sudo mv /home/beholder/.arkade/bin/helm /usr/local/bin/

# Install k3s
curl -sfL https://get.k3s.io | sh -

sudo chown beholder:beholder /etc/rancher/k3s/k3s.yaml
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
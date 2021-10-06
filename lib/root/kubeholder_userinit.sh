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

# Add KUBECONFIG to the environment
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc

# If an init script exists in the cloned beholder folder, run it
if [ -f ~/beholder/init.sh ]; then
  ~/beholder/init.sh
fi
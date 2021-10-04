#!/bin/bash

git clone --depth=1 https://github.com/beholder-rpa/beholder-iot ~/beholder

# Install kubectl
arkade get kubectl
sudo mv /home/beholder/.arkade/bin/kubectl /usr/local/bin/

# Install k3sup
arkade get k3sup
sudo mv /home/beholder/.arkade/bin/k3sup /usr/local/bin/

# Install k3s
echo "# Installing k3s..."
export IP=$(ifconfig wlan0 | grep -i netmask | awk '{print $2}' | cut -f 2)
mkdir ~/.kube/
k3sup install --local --user beholder --local-path ~/.kube/config --context beholder
echo "# k3s installed."
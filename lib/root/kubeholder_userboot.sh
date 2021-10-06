#!/bin/bash

git clone --depth=1 https://github.com/beholder-rpa/beholder-iot ~/beholder

# If a boot script exists in the cloned beholder folder, run it
if [ -f ~/beholder/boot.sh ]; then
  ~/beholder/boot.sh
fi

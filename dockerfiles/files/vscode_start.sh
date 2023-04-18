#!/bin/bash -e

echo "Starting VS code session"
echo "HOME: ${HOME}"
echo "USER: $(whoami)"
export ENTRYPOINTD=${HOME}/entrypoint.d

mkdir -p ~/.config/code-server

echo "bind-addr: 127.0.0.1:8080" > ${HOME}/.config/code-server/config.yaml
echo "auth: none" >> ${HOME}/.config/code-server/config.yaml
echo "cert: false" >> ${HOME}/.config/code-server/config.yaml

entrypoint.sh --bind-addr 0.0.0.0:5000 ~

echo "Exiting"

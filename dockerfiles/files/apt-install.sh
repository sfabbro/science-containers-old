#!/bin/bash

if [[ -e ${1} ]]; then
    pkgs=$1
else
    echo $@ > apt.list
    pkgs=apt.list
fi

export DEBIAN_FRONTEND=noninteractive

# update, install and cleanup
apt-get update --yes --quiet --fix-missing
apt-get install --yes --quiet $(cat ${pkgs})
apt-get clean --yes
apt-get autoremove --purge --quiet --yes
rm -rf /var/lib/apt/lists/* /var/tmp/*

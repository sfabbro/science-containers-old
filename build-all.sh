#!/bin/bash -eux

source containers.sh

for c in "${CONTAINERS[@]}"; do
    echo
    echo " >---- BUILDING ${c} ------<"
    echo
    build_container ${c}
done

#!/bin/bash -eux

source containers.sh

for c in "${CONTAINERS[@]}"; do
    echo
    echo " >---- PUSHING ${c} ------<"
    echo
    push_container ${c}
done

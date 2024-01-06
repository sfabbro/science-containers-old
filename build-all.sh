#!/bin/bash -eux

source build.sh

BASE_CONTAINERS=(
    base
    astroml
    base-gpu
    astroml-gpu
)

CONTAINERS=(
    astroml-notebook
    base-terminal
    astroflow
    astroml-vscode
    astroflow-vscode
    astroflow-notebook
    astroml-gpu-notebook
    astroml-gpu-vscode
    astroflow-gpu
    astroflow-gpu-notebook
    astroflow-gpu-vscode
    automl
    automl-notebook
    automl-gpu
    automl-gpu-notebook
    pycaret-notebook
    pycaret-gpu-notebook
    astrapids-gpu
    astrapids-gpu-notebook
    astrapids-gpu-vscode
)

for c in "${BASE_CONTAINERS[@]}"; do
    echo
    echo " >---- BUILDING ${c} ------<"
    echo
    build_container ${c}
done

for c in "${CONTAINERS[@]}"; do
    echo
    echo " >---- BUILDING ${c} ------<"
    echo
    build_container ${c}
done

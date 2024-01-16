#!/bin/bash -eux

source build.sh

BASE_CONTAINERS=(
    base
    astroml
    astroml-notebook
    base-gpu
    astroml-gpu
    astroml-gpu-notebook
)

CONTAINERS=(
    ${BASE_CONTAINERS[@]}
    base-terminal
    astroml-vscode
    astroml-gpu-vscode
    astroflow
    astroflow-notebook
    astroflow-vscode
    astroflow-gpu
    astroflow-gpu-notebook
    astroflow-gpu-vscode
    automl
    automl-notebook
    automl-gpu
    automl-gpu-notebook
    astrapids-gpu
    astrapids-gpu-notebook
    astrapids-gpu-vscode
)

for c in "${CONTAINERS[@]}"; do
    echo
    echo " >---- BUILDING ${c} ------<"
    echo
    build_container ${c}
done

#!/bin/bash -eux

source build.sh

push_container base
push_container base-gpu

push_container astroml
push_container astroml-vscode
push_container astroml-notebook

push_container astroml-gpu
push_container astroml-gpu-vscode
push_container astroml-gpu-notebook

push_container automl
push_container automl-notebook

push_container automl-gpu
push_container automl-gpu-notebook

#push_container astrapids-gpu
#push_container astrapids-gpu-notebook
#push_container astrapids-gpu-vscode

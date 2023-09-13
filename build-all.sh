#!/bin/bash -eux

source build.sh

build_container base
build_container astroml base
build_container astroml-notebook astroml
build_container astroml-vscode astroml

build_container base-gpu
build_container astroml-gpu base-gpu
build_container astroml-gpu-notebook astroml-gpu
build_container astroml-gpu-vscode astroml-gpu

build_container automl base
build_container automl-notebook automl
build_container automl-gpu base-gpu
build_container automl-gpu-notebook automl-gpu

build_container astroflow base
build_container astrapids-gpu base

#build_container astrapids-gpu base-gpu
#build_container astrapids-gpu-notebook astrapids-gpu
#build_container astrapids-gpu-vscode astrapids-gpu



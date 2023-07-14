#!/bin/bash -eux

source build.sh

build_container base
build_container base-gpu

build_container astroml base
build_container astroml-notebook astroml
build_container astroml-vscode astroml

build_container astroml-gpu base-gpu
build_container astroml-gpu-notebook astroml-gpu
build_container astroml-gpu-vscode astroml-gpu

build_container astrapids-gpu base-gpu
build_container astrapids-gpu-notebook astrapids-gpu
build_container astrapids-gpu-vscode astrapids-gpu



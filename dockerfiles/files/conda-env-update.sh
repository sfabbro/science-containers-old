#!/bin/bash

yml=$1

mamba update --all --yes
if [[ $(diff /build-info/env.yml ${yml} &> /dev/null) != 0 ]]; then
    mamba env update -n base --file ${yml}
fi
mamba clean --all --quiet --force --yes

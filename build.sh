#!/bin/bash -eux

REGISTRY="images.canfar.net"
OWNER="skaha"
TAG="$(date +%y.%m)"

PYTHON_VERSION=3.10
CUDA_VERSION=11.2
BASE_CONTAINER=ubuntu:22.04

SRC_DIR=${PWD}

#TAG=${TAG}-py${PYTHON_VERSION/./}

export PYTHON_VERSION CUDA_VERSION REGISTRY OWNER TAG SRC_DIR

make_dockerfile() {
    local container=$1
    local stack=${container%-notebook}
    stack=${stack%-vscode}
    stack=${stack%-gpu}

    echo "conda-forge" > channels.list

    # construct a list of packages for conda/pip
    for p in $(cat ${SRC_DIR}/stacks/${stack}); do
	for l in apt conda pip channels; do
	    [[ -e ${SRC_DIR}/pkg/${p}.${l} ]] && \
		grep -ve '\s*#' -e '^$' ${SRC_DIR}/pkg/${p}.${l} >> ${l}.list
	done
    done

    # gpu: hack to force conda packages for their cuda versions
    if [[ ${container} =~ gpu ]]; then
	sed -i -e "s|cpu|cu|g" conda.list
	for l in apt conda pip channels; do
	    [[ -e ${SRC_DIR}/pkg/cuda.${l} ]] && \
		grep -ve '\s*#' -e '^$' ${SRC_DIR}/pkg/cuda.${l} >> ${l}.list
	done
    fi

    # notebook: add specific packages
    if [[ ${container} =~ notebook ]]; then
	for l in conda pip npm; do
	    [[ -e ${SRC_DIR}/pkg/notebook.${l} ]] && \
		grep -ve '\s*#' -e '^$' ${SRC_DIR}/pkg/notebook.${l} >> ${l}.list
	done

	# buggy extension (08/2023)
	# hack to add nvdashboard
	#if [[ ${container} =~ gpu ]]; then
	#    echo "jupyterlab-nvdashboard" >> conda.list
	#fi
    fi

    # now put together the conda environment file

    # first compile list of all channels
    echo >> env.yml "name: base"
    echo >> env.yml "channels:"
    cat channels.list \
	| uniq | awk 'NF' \
	| sed -e 's|\(.*\)|  - \1|g' \
	  >> env.yml

    # add the list of conda packages
    cat >> env.yml <<EOF
dependencies:
  - python=${PYTHON_VERSION}.*
  - pip
  - pip-tools
  - pipenv
  - conda-lock
  - poetry
EOF

    [[ -e conda.list ]] && cat conda.list \
	    | sort | uniq | awk 'NF' \
	    | sed -e 's|\(.*\)|  - \1|g' \
		  >> env.yml

    # add the list of pip packages
    if [[ -e pip.list ]] && [[ $(wc -l pip.list | awk '{print $1}') -gt 0 ]]; then
	echo "  - pip:" >> env.yml
	cat pip.list \
	    | sort | uniq | awk 'NF' \
	    | sed -e 's|\(.*\)|     - \1|g' \
		  >> env.yml
    fi

    # create the pinned packages file from the env.yml file
    awk '/=/{print $2}' env.yml |  sed 's|=| |g' > pinned

    # now compile a final Dockerfile
    echo "Dockerfile stack is ${stack}"

    cat ${SRC_DIR}/dockerfiles/Dockerfile.head > Dockerfile

    [[ -e apt.list ]] && \
	cat ${SRC_DIR}/dockerfiles/Dockerfile.apt >> Dockerfile

    [[ ${container} =~ astro ]] && \
	cat ${SRC_DIR}/dockerfiles/Dockerfile.astro >> Dockerfile

    [[ -e ${SRC_DIR}/dockerfiles/Dockerfile.${stack} ]] && \
	cat ${SRC_DIR}/dockerfiles/Dockerfile.${stack} >> Dockerfile

    [[ ${container} =~ gpu ]] && \
	cat ${SRC_DIR}/dockerfiles/Dockerfile.cuda >> Dockerfile

    cat ${SRC_DIR}/dockerfiles/Dockerfile.env >> Dockerfile

    [[ ${container} =~ notebook ]] && \
	cat ${SRC_DIR}/dockerfiles/Dockerfile.notebook >> Dockerfile

    [[ ${container} =~ vscode ]] && \
	cat ${SRC_DIR}/dockerfiles/Dockerfile.vscode >> Dockerfile

    cp ${SRC_DIR}/dockerfiles/files/* .
}

build_container() {
    local container=$1
    local build_dir=${PWD}/_build/${container}
    local base_container=${BASE_CONTAINER}
    [[ $# == 2 ]] && base_container=${OWNER}/$2:latest

    rm -rf ${build_dir}
    mkdir -p ${build_dir}

    pushd ${build_dir}
    make_dockerfile ${container}

    docker build \
	   --rm --force-rm \
	   --build-arg BASE_CONTAINER=${base_container} \
	   --tag ${OWNER}/${container}:latest \
	   . 2>&1 | tee build.log 2>&1
    popd
}

push_container() {
    local container=$1
    docker tag ${OWNER}/${container}:latest ${REGISTRY}/${OWNER}/${container}:${TAG}
    docker push ${REGISTRY}/${OWNER}/${container}:${TAG}
}

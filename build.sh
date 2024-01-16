#!/bin/bash -eux

REGISTRY="images.canfar.net"
OWNER="skaha"
TAG="$(date +%y.%m)"

: ${PYTHON_VERSION=3.10}
: ${CUDA_VERSION=11.2}
: ${BASE_CONTAINER=ubuntu:22.04}

SRC_DIR=${PWD}

#TAG=${TAG}-py${PYTHON_VERSION/./}

export PYTHON_VERSION CUDA_VERSION REGISTRY OWNER TAG SRC_DIR

make_dockerfile() {
    local name=$1
    local stack=${name}
    stack=${stack%-notebook}
    stack=${stack%-terminal}
    stack=${stack%-vscode}
    stack=${stack%-gpu}

    for p in $(cat ${SRC_DIR}/stacks/${stack}); do
	# construct a list of packages for conda/pip
	for l in apt conda pip channels; do
	    [[ -e ${SRC_DIR}/pkg/${p}.${l} ]] && \
		grep -ve '\s*#' -e '^$' ${SRC_DIR}/pkg/${p}.${l} >> ${l}.list
	done
	# add stack specific dockerfile
	[[ -e ${SRC_DIR}/dockerfiles/Dockerfile.${p} ]] &&  \
	    cat ${SRC_DIR}/dockerfiles/Dockerfile.${p} >> Dockerfile.stack
    done

    # gpu: change conda package builds from cpu for their cuda versions
    if [[ ${name} =~ gpu ]]; then
	sed -e "/arrow/ ! s/*cpu*/*cuda${CUDA_VERSION/./}/g" \
	    -e "/arrow/ s/*cpu*/*cuda/g" \
	    -i conda.list

	for l in apt conda pip channels; do
	    [[ -e ${SRC_DIR}/pkg/cuda.${l} ]] && \
		grep -ve '\s*#' -e '^$' ${SRC_DIR}/pkg/cuda.${l} >> ${l}.list
	done
	cat ${SRC_DIR}/dockerfiles/Dockerfile.cuda >> Dockerfile.stack
    fi

    # session interfaces
    # notebook: add specific notebook, lab and extensions packages
    if [[ ${name} =~ notebook ]]; then
	for l in apt conda pip npm; do
	    [[ -e ${SRC_DIR}/pkg/notebook.${l} ]] && \
		grep -ve '\s*#' -e '^$' ${SRC_DIR}/pkg/notebook.${l} >> ${l}.list
	    [[ -e ${SRC_DIR}/pkg/dev.${l} ]] && \
		grep -ve '\s*#' -e '^$' ${SRC_DIR}/pkg/dev.${l} >> ${l}.list
	done
	cat ${SRC_DIR}/dockerfiles/Dockerfile.notebook >> Dockerfile.interface
    elif [[ ${name} =~ vscode ]]; then
	for l in apt conda pip npm; do
	    [[ -e ${SRC_DIR}/pkg/vscode.${l} ]] && \
		grep -ve '\s*#' -e '^$' ${SRC_DIR}/pkg/vscode.${l} >> ${l}.list
	    [[ -e ${SRC_DIR}/pkg/dev.${l} ]] && \
		grep -ve '\s*#' -e '^$' ${SRC_DIR}/pkg/dev.${l} >> ${l}.list
	done
	cat ${SRC_DIR}/dockerfiles/Dockerfile.vscode >> Dockerfile.interface
    elif  [[ ${name} =~ terminal ]]; then
	for l in apt conda pip npm; do
	    [[ -e ${SRC_DIR}/pkg/terminal.${l} ]] && \
		grep -ve '\s*#' -e '^$' ${SRC_DIR}/pkg/terminal.${l} >> ${l}.list && \
	    [[ -e ${SRC_DIR}/pkg/dev.${l} ]] && \
		grep -ve '\s*#' -e '^$' ${SRC_DIR}/pkg/dev.${l} >> ${l}.list
	done
	cat ${SRC_DIR}/dockerfiles/Dockerfile.terminal >> Dockerfile.interface
    else
	echo "Unknown sesssion requested: ${name}" >&2
    fi

    # put together the conda environment file
    echo >> env.yml "name: base"

    # first compile list of all channels
    touch channels.list
    cat channels.list | uniq | awk 'NF' > channels.list.new
    mv channels.list.new channels.list
    if [[ $(wc -l channels.list | awk '{print $1}') -gt 0 ]]; then
        echo >> env.yml "channels:"
	cat channels.list | sed -e 's|\(.*\)|  - \1|g'  >> env.yml
    fi

    # add the list of conda packages
    echo >> env.yml "dependencies:"
    if [[ -e conda.list ]] && [[ $(wc -l conda.list | awk '{print $1}') -gt 0 ]]; then
	cat conda.list \
	    | sort | uniq | awk 'NF' \
	    | sed -e 's|\(.*\)|  - \1|g' \
		  >> env.yml
    fi

    # add the list of pip packages
#    if [[ -e pip.list ]] && [[ $(wc -l pip.list | awk '{print $1}') -gt 0 ]]; then
#	echo "  - pip:" >> env.yml
#	cat pip.list \
#	    | sort | uniq | awk 'NF' \
#	    | sed -e 's|\(.*\)|     - \1|g' \
#		  >> env.yml
    #   fi

    if [[ -e pip.list ]] && [[ $(wc -l pip.list | awk '{print $1}') -gt 0 ]]; then
	cat pip.list | sort | uniq > new.pip.list
	mv new.pip.list pip.list
    fi

    sed -i \
	-e "s|%PYTHON_VERSION%|${PYTHON_VERSION}|g" \
	-e "s|%CUDA_VERSION%|${CUDA_VERSION}|g"  \
	env.yml

    # create the pinned packages file from the env.yml file
    awk '/=/{print $2}' env.yml | awk -F'=' '{print $1" "$2" "$3}'  > pinned
    awk '/</{print $2}' env.yml | awk -F'<' '{print $1" < "$2" "$3}' >> pinned
    awk '/>/{print $2}' env.yml | awk -F'>' '{print $1" > "$2" "$3}' >> pinned

    # now compile a final Dockerfile
    echo "Dockerfile stack is ${stack}"

    cat ${SRC_DIR}/dockerfiles/Dockerfile.head > Dockerfile

    if [[ ${stack} == base ]]; then
	cat ${SRC_DIR}/dockerfiles/Dockerfile.base >> Dockerfile
    else
	[[ -e apt.list ]] && \
	    cat ${SRC_DIR}/dockerfiles/Dockerfile.apt >> Dockerfile
	[[ -e env.yml ]] && \
	    cat ${SRC_DIR}/dockerfiles/Dockerfile.conda >> Dockerfile
    fi
    [[ -e Dockerfile.stack ]] && cat Dockerfile.stack >> Dockerfile
    [[ -e Dockerfile.interface ]] && cat Dockerfile.interface >> Dockerfile

    cat ${SRC_DIR}/dockerfiles/Dockerfile.tail >> Dockerfile
    cp ${SRC_DIR}/dockerfiles/files/* .
}

build_container() {
    local name=$1
    local build_dir=${PWD}/_build/${name}
    local base_container=${BASE_CONTAINER}

    local f
    f=${name%-notebook}
    f=${f%-vscode}
    f=${f%-terminal}

    if [[ ${name:0:4} != base ]]; then
	if [[ ${name} != ${f} ]] && [[ $(docker images | grep "${OWNER}/${f} " | awk '{print$1}' | wc -l) == 1 ]]; then
	    base_container=${OWNER}/${f}:latest
	else
	    if [[ ${f%-gpu} == ${f} ]]; then
		base_container=${OWNER}/base:latest
	    else
		base_container=${OWNER}/base-gpu:latest
	    fi
	fi
    fi
    echo "BUILDING ${name} from ${base_container}"

    rm -rf ${build_dir}
    mkdir -p ${build_dir}

    pushd ${build_dir}
    make_dockerfile ${name}

    docker build \
	   --rm --force-rm \
	   --build-arg BASE_CONTAINER=${base_container} \
	   --build-arg PYTHON_VERSION=${PYTHON_VERSION} \
	   --tag ${OWNER}/${name}:latest \
	   . 2>&1 | tee build.log 2>&1
    popd
}

push_container() {
    local name=$1
    docker tag ${OWNER}/${name}:latest ${REGISTRY}/${OWNER}/${name}:${TAG}
    docker push ${REGISTRY}/${OWNER}/${name}:${TAG}
    docker tag ${OWNER}/${name}:latest ${REGISTRY}/${OWNER}/${name}:latest
    docker push ${REGISTRY}/${OWNER}/${name}:latest
}

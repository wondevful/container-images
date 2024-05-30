#!/bin/bash

function build_container() {
    local file=$1
    echo "===================================="
    echo "$file"
    echo "===================================="

    local name=docker.io/giflw/wondevful:${file##*.}
    local latest=${name}-latest
    local tag=`grep FROM $file | head -n 1`
    tag=${tag##*:}
    # remove distro qualification
    tag=${tag%%-ubuntu*}
    tag=${tag%%-alpine*}

    name=${name}-${tag}
    name=${name,,}
    echo $file: $name

    podman build . -f $file -t $name
    podman push $name
    podman tag $name $latest
    podman push $latest

    #podman image rm $name
    #podman image rm $latest
}

if [ $# -eq 0 ]; then
    for file in `ls Containerfile.*`; do
        build_container $file
    done
else
    for file in $@; do
        build_container $file
    done
fi

#podman image prune --all --force
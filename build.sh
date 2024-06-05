#!/bin/bash
set -euo pipefail

container_cmd=${CONTAINER_CMD:=podman}

_PUSH=false
POSITIONAL_ARGS=()
for arg in $@; do
    case "$1" in
        -p|--push)
            _PUSH=true ; shift ;;
        -d|--debug)
            set -x ; shift ;;
        -*|--*)
            echo "Unknown option $1" ; exit 1 ;; 
        *)
            POSITIONAL_ARGS+=("$1") ; shift ;;
    esac
done

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
    tag=${tag%%-bookworm*} # debian bookworm
    tag=${tag%%-ubuntu*}
    tag=${tag%%-alpine*}

    name=${name}-${tag}
    name=${name,,}
    echo $file: $name

    $container_cmd build . -f $file -t $name
    $container_cmd tag $name $latest
    
    if [ $_PUSH == true ]; then
        $container_cmd push $name
        grep "# NO-TAG-LATEST" $file &> /dev/null || $container_cmd push $latest
    fi

    #$container_cmd image rm $name
    #$container_cmd image rm $latest
}

if [ "$POSITIONAL_ARGS" == "" ]; then
    for file in `ls Containerfile.*`; do
        build_container $file
    done
else
    for file in $POSITIONAL_ARGS; do
        build_container $file
    done
fi

#$container_cmd image prune --all --force
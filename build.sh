#!/bin/bash
set -euo pipefail

timestamp=`date +"%y%m%d%H%M"`

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

TAGS_TIMESTAMP=""
TAGS_LATEST=""

function build_container() {
    local file=$1
    echo "===================================="
    echo "$file"
    echo "===================================="

    local name=${file##*.}
    name=docker.io/giflw/wondevful:${name##*_}
    local latest=${name}-latest
    local tag=`grep FROM $file | head -n 1`
    tag=${tag##*:}
    # remove distro qualification
    tag=${tag%%-bookworm*} # debian bookworm
    tag=${tag%%-bullseye*} # debian bullseye
    tag=${tag%%-ubuntu*}
    tag=${tag%%-alpine*}
    tag=${tag%%-minimal*}
    tag=${tag%%-almalinux*}
    tag=${tag%%-rockylinux*}
    tag=${tag%%almalinux-*}
    tag=${tag%%rockylinux-*}
    tag=${tag%%-2023*}
    tag=${tag%%-2024*}
    tag=${tag%%.2023*}
    tag=${tag%%.2024*}
    if [ -n "$tag" ]; then
        tag="-${tag}"
    fi
    name=${name}${tag}-${timestamp}
    name=${name,,}
    echo $file: $name

    TAGS_TIMESTAMP="${TAGS_TIMESTAMP} ${name}"
    TAGS_LATEST="${TAGS_LATEST} ${latest}"

    $container_cmd build . -f $file -t $name
    $container_cmd tag $name $latest

    echo "- ${file##*.}"
    echo "    - ${name}"
    echo "    - ${latest}"

    #$container_cmd image rm $name
    #$container_cmd image rm $latest
}

POSITIONAL_ARGS=${POSITIONAL_ARGS:-""}
if [ "$POSITIONAL_ARGS" == "" ]; then
    for file in `ls Containerfile.*`; do
        build_container $file
    done
else
    for file in $POSITIONAL_ARGS; do
        build_container $file
    done
fi


if [ $_PUSH == true ]; then
    for name in $TAGS_TIMESTAMP; do
        $container_cmd push $name
    done
    for name in $TAGS_LATEST; do
        $container_cmd push $name
    done
#    grep "# NO-TAG-LATEST" $file &> /dev/null || $container_cmd push $latest
fi

#$container_cmd image prune --all --force
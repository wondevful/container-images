#!/bin/bash
for file in `ls Containerfile.*`; do
    echo "===================================="
    echo "$file"
    echo "===================================="

    name=`head -n 1 $file`
    name=${name##*NAME }

    name=${name%%TAG}
    latest=${name}latest
    tag=`head -n 2 $file | tail -n 1`
    tag=${tag##*:}
    # remove distro qualification
    tag=${tag%%-ubuntu*}
    tag=${tag%%-alpine*}

    name=$name$tag
    unset tag

    name=${name,,}
    echo $file: $name

    podman build . -f $file -t $name
    podman push $name
    podman tag $name $latest
    podman push $latest

    podman image rm $name
    podman image rm $latest

    unset name
    unset latest
done

podman image prune --all --force
#!/bin/bash

set -euo pipefail
set -x

get_first_folder()
{
    echo "$1" | cut -d "/" -f1
}

get_changes()
{
    RES=()
    GIT_CHANGES=$(git diff --name-only HEAD~1)
    for c in $GIT_CHANGES
    do
      if [[ "$c" != *"VERSION" ]]
      then
        continue
      fi
      RES+=( $(get_first_folder $c) )
    done
    CHANGES=$(echo ${RES[@]} | tr ' ' '\n' | sort -u)
}

get_changes


echo $CHANGES

for image in $CHANGES
do
    echo "Trying to build $image"
    make build $image

    echo "Trying to publish $image"
    make publish $image
done

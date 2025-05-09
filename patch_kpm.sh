#!/usr/bin/bash

function check-exec() {
    if ! which $1 &> /dev/null; then
        echo "no $1! abort!"
        exit 1
    else
        echo "ok: $1 exist"
    fi
}

export TEMPORARY_DISABLE_PATH_RESTRICTIONS=true

SELF_DIR=$(dirname $0)

if ! [ -f "patch_linux" ]; then
    if ! [ -f "$SELF_DIR/patch_linux" ]; then
        echo "no patch_linux! downloading..."
    
        check-exec jq
        check-exec curl
        
        TAG=$(jq -r 'map(select(.prerelease)) | first | .tag_name' <<< $(curl --silent https://api.github.com/repos/ShirkNeko/SukiSU_KernelPatch_patch/releases))
        echo "latest tag is: $TAG"
    
        curl -Ls -o "$SELF_DIR/patch_linux" "https://github.com/ShirkNeko/SukiSU_KernelPatch_patch/releases/download/$TAG/patch_linux"
    
        if [ $? -eq 0 ]; then
            echo "download ok"
        else
            echo "download fail ($?)! abort!"
            exit 1
        fi
    
        chmod +x "$SELF_DIR/patch_linux"
        if [ $? -eq 0 ]; then
            echo "set permission ok"
        else
            echo "failed to set permission! abort!"
            exit 1
        fi
    fi

    cp "$SELF_DIR/patch_linux" .
fi

if [ "$1" = "--download" ]; then
    echo "done"
    exit 0
fi

if ! [ -f "$1" ]; then
    echo "no input! abort!"
    exit 1
fi

FILENAME=$(basename "$1")
if [ "$FILENAME" = "Image" ]; then
    mv $1 ./Image
else
    echo "wrong file! expected 'Image' but got '$FILENAME'. abort!"
    exit 1
fi

./patch_linux

if ! [ -f "oImage" ]; then
    echo "patch failed!"
    exit 1
fi

mv ./oImage $1

echo "KPM patch done"


export TEMPORARY_DISABLE_PATH_RESTRICTIONS=false


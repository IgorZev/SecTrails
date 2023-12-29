#!/bin/bash

version=$(git describe --tags)

echo "Preparing verion $version"

error() {
    ret=$(cat)
    if [ -z "$ret" ]; then printf "\033[0;32mRelease successful."; else
    printf "\033[0;31mError while building release: \n\033[0m$ret"
    rm -rf $version
    exit
    fi
}


printf "\033[1;33mCreating release files\n\033[0m"

exec 3>&1
{
    mkdir bin

    rsync -a SecTrails.sh bin/SecTrails-linux-arm64/
    rsync -a SecTrails.sh bin/SecTrails-linux-amd64/
    rsync -a jq-linux-amd64 bin/SecTrails-linux-amd64/
    rsync -a jq-linux-arm64 bin/SecTrails-linux-arm64/

    zip bin/SecTrails-linux-arm64.zip bin/SecTrails-linux-arm64 
    zip bin/SecTrails-linux-amd64.zip bin/SecTrails-linux-amd64

    rm -rf bin/SecTrails-linux-arm64
    rm -rf bin/SecTrails-linux-amd64

    sha256sum bin/SecTrails-linux-arm64.zip > bin/sha256sums
    sha256sum bin/SecTrails-linux-amd64.zip >> bin/sha256sums
} 2>&1 1>&3  | error



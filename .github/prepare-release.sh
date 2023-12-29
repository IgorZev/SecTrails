#!/bin/bash

if [ "$EUID" -ne 0 ]
  then printf "\033[0;31mPlease run as root\033[0m"
  exit
fi

version=$(git describe --tags)

error() {
    ret=$(cat)
    if [ -z "$ret" ]; then printf "\033[0;32mRelease successful."; else
    printf "\033[0;31mError while building release: \n\033[0m$ret"
    rm -rf $version
    exit
    fi
}


printf "\033[1;33mCreating release\n\033[0m"

test -d $version
if [ $? -eq 0 ]; then
    rev=$(stat $version -c %n-%W)
    mv "$version" "$rev"
fi

exec 3>&1
{
    mkdir $version

    rsync -a ../SecTrails.sh $version/SecTrails-linux-arm64/
    rsync -a ../SecTrails.sh $version/SecTrails-linux-amd64/
    rsync -a ../jq-linux-amd64 $version/SecTrails-linux-amd64/
    rsync -a ../jq-linux-arm64 $version/SecTrails-linux-arm64/

    zip $version/SecTrails-linux-arm64.zip $version/SecTrails-linux-arm64 
    zip $version/SecTrails-linux-amd64.zip $version/SecTrails-linux-amd64

    sha256sum $version/SecTrails-linux-arm64.zip > $version/sha256sums
    sha256sum $version/SecTrails-linux-amd64.zip >> $version/sha256sums
} 2>&1 1>&3  | error



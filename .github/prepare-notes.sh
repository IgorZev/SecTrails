#!/bin/bash

origin=$(git rev-parse origin/$1)

local=$(git rev-parse HEAD)

logs=$(git log $origin..$local --oneline)

   
printf "Changes:\n$logs\n\nFiltering:"

IFS=':'$'\n'; arr=($logs); unset IFS;
for i in "${arr[@]}"; do
    trimmed=$(echo "$i" | xargs)
    printf "\n$trimmed"
done


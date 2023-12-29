#!/bin/bash

origin=$(git rev-parse $1)

local=$(git rev-parse HEAD)

echo $origin
echo $local

logs_pre=$(git log $origin..$local --oneline)

printf "Changes:\n$logs_pre\n\nFiltering:\n"

delimiter=';'

logs="${logs_pre//:/:$delimiter}"

IFS="$delimiter"$'\n'; arr=($logs); unset IFS;
change=
type=
type_list=()
message=
context=
declare -A notes
for i in "${arr[@]}"; do
    trimmed=$(echo "$i" | xargs)
    if [[ $trimmed == *":"* ]]; then
        change=$(echo $trimmed | awk '{print $1}')
        type=$(echo $trimmed | awk '{print $2}')
        type=${type::-1}
        if [[ $type == *"("*")"* ]]; then
            IFS='('
            ar=($type)
            type="${ar[0]}"
            context="${ar[1]::-1}"
            unset IFS
        fi
    else
        message=$trimmed
        printf "ID: \"$change\"\nType: \"$type\"\nContext: \"$context\"\nMessage: \"$message\"\n\n"
        notes[$change]="$type,"${context:=general}",$message"
        change=
        type=
        message=
        context=
    fi
done


get_sec() {
    pos=$1
    shift
    IN=("$@")
    vals=()
    read -r val1 val2 val3 <<< "$(awk -F',' '{print $1,$2,$3}' <<< "${IN[@]}")"
    case $pos in
        0)
            vals+=("$val1") 
        ;;
        1)
            vals+=("$val2") 
        ;;
        2)
            vals+=("$val3") 
        ;;
        *) exit;;
    esac
    echo "${vals[*]}"
}


types=$(get_sec 2 "${notes[@]}")


untypes=($(printf "%s\n" "${types[@]}" | sort -u | tr '\n' ' '))

# Assembling notes

pattern="*!*"

echo "# Highlights" > tmp/notes.md
for key in "${!notes[@]}"; do
    if [[ $(get_sec 1 ${notes[$key]}) == $pattern ]]; then
        mess=$(get_sec 2 ${notes[$key]})
        echo "- $key - ${mess[*]^}" >> tmp/notes.md
    fi
done

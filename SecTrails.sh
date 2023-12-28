#!/bin/bash
: '
Copyright 2023 Igor Zevnik

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'
## TODO ##

## Fix
# Make redirects into function
# Make menus into function
# Better error handling
# Make dsleep consistent
# Rewrite the stuff that i wrote while sleep deprived cuz they are barely holding
# Display invalid option after clear
# Verbose debug is no longer verbose
# Format code
# Certain search terms dont work because they are arrays (ex. "host_provider": ["Namecheap, Inc."])

## Feat
# Add formatting options for file output
    # CSV
# Add different request types
# Option to add filter query to start of file
# Allow defaults


# Constants

VERSION=1.1


# OPTIONS

iDEBUG="false"
DEBUG=$iDEBUG

iAPI_KEY=""
API_KEY=$iAPI_KEY

iSLEEP="100"
SLEEP=$iSLEEP

# Color definitions

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
LBLUE='\033[1;36m'
NC='\033[0m'


# Prereq

# Script depends on jq, a JSON processor. See more at: https://jqlang.github.io/jq/ 
# jq executable location
ijq=""
jq=$ijq

# Figlet is reccomended but not needed. Is just prettier


# Complimentary functions

dsleep () {
    sspeed=$1*$SLEEP/100
    sleeptime=$(echo | awk '{printf "%0.2f\n", ('$sspeed');}')
    if [ "$DEBUG" = true ]; then
        printf "${YELLOW}Debug mode: Sleep command disabled${NC}\n"
    else
        sleep $sleeptime
    fi
}

fig_display () {
    if ! command -v figlet &> /dev/null; then printf "${YELLOW}Figlet not installed.\n\n$2$1${NC}\n"
    else
        printf "$2"
        figlet -p $1
        printf "${NC}"
    fi
}

get_index () {
    msg=$1
    shift
    arr=("$@")
    for i in "${!arr[@]}"; do
        if [[ "${arr[$i]}" = "$msg" ]]; then
            echo "$(($i+1))"
            return "$(($i+1))"
        fi
    done
    echo 99
}

jquery_build () {
    query="$jq -r '.. | select("
    for i in "$@"
    do
        query=$query".$i? or "
    done
    query=${query::-3}
    query=$query") // empty | "
    for i in "$@"
    do
        query=$query"\" $i: \" + .$i + "
    done
    query=${query::-2}"' res.json"
    #echo $query
    printf "$(eval $query)"
}

# Banner
init=false
banner() {
    fig_display "SecTrails Script" "${LBLUE}"

    printf "v${VERSION}\n"
    if [ "$DEBUG" = true ]; then printf "${RED}DEBUG MODE ENABLED\n${NC}"; fi
    printf "\n"

    if [ "$init" = false ]; then
        dsleep 0.7
        #printf 'Welcome to \e[31mS\e[33me\e[32mc\e[36mT\e[34mr\e[35ma\e[31mi\e[33ml\e[0m\e[34ms \e[32mS\e[36mc\e[34mr\e[35mi\e[31mp\e[33mt\e[0m!\n\n'
        printf 'Welcome to SecTrails Script!\n\n'
        dsleep 1
        
        init=true
    fi
}

###### Main Script ######



# Main menu

main() {
    while true; do
        clear
        banner
        printf 'Please select an option:\n'
        options=("Request" "Options" "Quit")

        for i in "${!options[@]}" 
        do
            if [[ ${options[$i]} = "Quit" ]]; then printf "${GREEN}0)${NC} ${options[$i]}\n"
            else
                printf "${GREEN}$(($i+1)))${NC} ${options[$i]}\n"
            fi
        done
        printf "\n"

        read -p "Selection: " -r choice
        case ${choice,,} in
            # Request
            $(get_index "Request" "${options[@]}")|request) echo "You chose Option 1"; request;;
            
            # Options
            $(get_index "Options" "${options[@]}")|options) options;;
            
            # Quit
            0|quit) fig_display "Bye!" "${LBLUE}"; exit;;
            
            # Other
            *) echo "Invalid option";;
        esac
    done
}

# Request


request () {
    while true; do
        clear
        banner
        printf 'Select request query:\n'
        options=("Search by Org" "Back")

        for i in "${!options[@]}" 
        do
            if [[ ${options[$i]} = "Back" ]]; then printf "${GREEN}0)${NC} ${options[$i]}\n"
            else
                printf "${GREEN}$(($i+1)))${NC} ${options[$i]}\n"
            fi
        done
        printf "\n"

        read -p "Selection: " -r choice
        case ${choice,,} in
            # Search by Org
            $(get_index "Search by Org" "${options[@]}")|'search by org') 
                if [[ $API_KEY = "" ]]; then 
                    printf "Please set your API key in the options\n"
                    printf "Redirecting in "
                    dsleep 2
                    printf "3"
                    for i in 2 1 0
                    do
                        for j in 1 2 3
                        do
                            printf "."
                            dsleep 0.333333
                        done
                        printf $i
                    done
                    dsleep 1
                    options
                fi
                read -p "Whois Organisation: " -r org
                send domains/list "$org"
                sleep 50
            ;;
            # Quit
            0|back) break;;
            
            # Other
            *) echo "Invalid option";;
        esac
    done
}

send() {
    # Kinda messy. Bad DIY do while loop
    
    data=$'{"filter":{"whois_organization":"'$2$'"}}'
    if [[ "$DEBUG" = "true" ]]; then 
    printf "${YELLOW}VERBOSE DEBUG${NC}\n"
    res=$(curl -s --request POST \
     --url https://api.securitytrails.com/v1/$1 \
     --header "APIKEY: $API_KEY" \
     --header "content-type: application/json" \
     --data "$data")
    else
    res=$(curl -s --request POST \
     --url https://api.securitytrails.com/v1/$1 \
     --header "APIKEY: $API_KEY" \
     --header "'content-type: application/json'" \
     --data "$data")
    fi
    echo $res > res.json
    echo "Page 1"
    
    # I should do better...
    if [[ $jq = "" ]]; then 
        printf "Please set the jq executable location\n"
        printf "Redirecting in "
        dsleep 2
        printf "3"
        for i in 2 1 0
        do
            for j in 1 2 3
            do
                printf "."
                dsleep 0.333333
            done
            printf $i
        done
        dsleep 1
        options
    fi

    stat=$(stat -L -c "%a" $jq)

    if [[ "$stat" != "755" ]]; then chmod 755 $jq; fi 

    pages=$(eval $jq '.meta.total_pages' res.json)
    if [ "$pages" = "null" ]; then
        pages="0"
    fi
    local i=2
    while [ $i -le $pages ]
    do
        echo "Page $i"
        data=$'{"filter":{"whois_organization":"'$2$'"}}'
        if [[ "$DEBUG" = "true" ]]; then 
        printf "${YELLOW}VERBOSE DEBUG${NC}\n"
        res=$(curl -v --request POST \
        --url https://api.securitytrails.com/v1/$1?page=$i \
        --header "APIKEY: $API_KEY" \
        --header "content-type: application/json" \
        --data "$data")
        else
        res=$(curl -s --request POST \
        --url https://api.securitytrails.com/v1/$1?page=$i  \
        --header "APIKEY: $API_KEY" \
        --header "'content-type: application/json'" \
        --data "$data")
        fi 
        i=$(( $i+1 ))
        echo $res >> res.json
    done

    # NO NO NO NO NO NO. PLEASE GOD HELP
    err=$(eval $jq -r '.message' res.json)
    echo $err
    if [ "$err" = "null" ]; then
        max=$(eval "$jq -r '.. | map(select(.max_page?) // 0) | max | .max_page' res.json")
        if [ "${max:0:1}" = "0" ]; then  error "0 results"
        else results $res  ; fi
    else error "$err"
    fi
}

# Error
error () {
    clear
    banner
    printf "${RED}$1${NC}\n\nRedirecting to main menu in 5"
    for i in 4 3 2 1 0
    do
        for j in 1 2 3
        do
            printf "."
            dsleep 0.333333
        done
        printf $i
    done
    dsleep 1
    main
}


# Results

results() {
    while true; do
        clear
        banner
        printf "${GREEN}QUERY SUCCESSFUL!${NC}\n"

        options=("Search" "Back")

        for i in "${!options[@]}" 
        do
            if [[ ${options[$i]} = "Back" ]]; then printf "${GREEN}0)${NC} ${options[$i]}\n"
            else
                printf "${GREEN}$(($i+1)))${NC} ${options[$i]}\n"
            fi
        done
        printf "\n"

        read -p "Selection: " -r choice
        case ${choice,,} in
            # Search
            $(get_index "Search" "${options[@]}")|search) 
                read -p "Search keys (default [hostname registrar]): " -r search
                if [ -z $search ]; then search="hostname registrar"; fi
                while true; do
                    clear
                    banner
                    search_res="$(jquery_build $search)"
                    if [ -z "$search_res" ]; then printf "${RED}No results${NC}\n"; else
                    printf "$search_res\n"; fi
                    optionss=("Save" "Back")
                    for j in "${!optionss[@]}" 
                    do
                        if [[ ${optionss[$j]} = "Back" ]]; then printf "${GREEN}0)${NC} ${optionss[$j]}\n"
                        else
                            printf "${GREEN}$(($j+1)))${NC} ${optionss[$j]}\n"
                        fi
                    done
                    read -p "Selection: " -r save
                    case ${save,,} in
                        # Save
                        $(get_index "Save" "${optionss[@]}")|save) 
                            read -p "Filename: " -r file
                            printf "$search_res" >> $file
                            printf "${GREEN}Success!${NC}"
                            printf "\n\nRedirecting to main menu in 5"
                            for x in 4 3 2 1 0
                            do
                                for y in 1 2 3
                                do
                                    printf "."
                                    dsleep 0.333333
                                done
                                printf $x
                            done
                            main
                            ;;
                        # Quit
                        0|back) break;;
            
                        # Other
                        *) echo "Invalid option";;
                    esac
                done
                ;;

            # Quit
            0|back) main;;
            
            # Other
            *) echo "Invalid option";;
        esac
    done
}

# Options

options() {
    script=$(basename "$0")
    while true; do
        clear
        banner
        printf 'Edit settings:\n'
        options=("DEBUG" "API_KEY" "jq" "SLEEP" "Back")

        for i in "${!options[@]}" 
        do
            if [[ ${options[$i]} = "Back" ]]; then printf "${GREEN}0)${NC} ${options[$i]}\n"
            else
                printf "${GREEN}$(($i+1)))${NC} ${options[$i]}=${YELLOW}${!options[$i]}\n"
            fi
        done
        printf "\n"

        read -p "Selection: " -r choice
        case ${choice,,} in
            # Debug
            $(get_index "DEBUG" "${options[@]}")|debug) 
                if [ "$DEBUG" = "true" ]; then
                    DEBUG=false
                else
                    DEBUG=true
                fi
                
                sed -i "s/iDEBUG=\".*\"/iDEBUG=\"$DEBUG\"/" "$script";;
            
            # API key
            $(get_index "API_KEY" "${options[@]}")|api_key) 
                read -p "New API key: " -r API_KEY

                sed -i "s/iAPI_KEY=\".*\"/iAPI_KEY=\"$API_KEY\"/" "$script";;
            
            # jq
            $(get_index "jq" "${options[@]}")|jq) 
                read -p "jq executable location: " -r jq
                #./jq-linux-amd64
                escaped=$(printf "%q" "$jq" | sed 's/\//\\\//g') 
                echo "$escaped"
                sed -i "s/ijq=\".*\"/ijq=\"$escaped\"/" "$script";;

            # Sleep
            $(get_index "SLEEP" "${options[@]}")|sleep) 
                read -p "Sleep speed(%): " -r SLEEP

                sed -i "s/iSLEEP=\".*\"/iSLEEP=\"$SLEEP\"/" "$script";;

            # Quit
            0|back) break;;
            
            # Other
            *) echo "Invalid option";;
        esac
    done
}

# Start

main "$@"; exit
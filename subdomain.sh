#!/bin/bash

# Check if the domain argument is provided
if [ -z $1 ]; then
    echo "Please provide a domain name as an argument."
    exit 1
fi

# Set variables for output files and domain
export domain=$1
export merged_out="subdomains.txt"

# Create a blank subdomains.txt file
touch $merged_out

# Define functions for each tool
run_amass() {
    local amass_out="amass.txt"
    if amass enum -active -d $domain -o $merged_out -silent; then
        echo "Error running Amass."
        exit 1
    fi
    echo "**********Amass successful**********"
}

run_chaos() {
    local chaos_out="chaos.txt"
    if chaos -d $domain -o $chaos_out;then
        sort -u $chaos_out $merged_out -o $merged_out
        rm $chaos_out
    else
        echo "Error running chaos"
        exit 1
    fi
    echo "**********Chaos successful**********"
}

run_crtsh() {
    local crtsh_out="crtsh.txt"
    if curl -s "https://crt.sh/?q=$domain&output=json" | jq -r ".[].name_value" | sed 's/\*//g' > $crtsh_out;then
        sort -u $crtsh_out $merged_out -o $merged_out
        rm $crtsh_out
    else    
        echo "Error calling crt.sh"
        exit 1
    fi
    echo "**********crtsh successful**********"
}

run_subfinder() {
    local subfinder_out="subfinder.txt"
    if subfinder -d $domain -o $subfinder_out -all -silent; then
        sort -u $subfinder_out $merged_out -o $merged_out
        rm $subfinder_out
        # comm -23 $subfinder_out $merged_out >> $merged_out
    else        
        echo "Error running Subfinder."
        exit 1
    fi
    echo "**********Subfinder successful**********"
}

run_findomain() {
    local findomain_out="findomain.txt"
    if findomain -q -t $domain -u $findomain_out; then
        sort -u $findomain_out $merged_out -o $merged_out
        rm $findomain_out
        # comm -23 $findomain_out $merged_out >> $merged_out
    else   
        echo "Error running Findomain."
        exit 1
    fi
    echo "**********Findomain successful**********"
}

run_go() {
    local rapid_out="rapid.txt"
    if rapidapi -u $domain -o $rapid_out; then
        sort -u $rapid_out $merged_out -o $merged_out
        # comm -23 $rapid_out $merged_out >> $merged_out
        rm $rapid_out
    else
        echo "Error running custom Go script."
        exit 1
    fi
    echo "**********Rapidapi successful**********"
}


export -f run_amass run_subfinder run_findomain run_go run_crtsh run_chaos 

# Run all tools in parallel
parallel --jobs 6 ::: run_amass run_subfinder run_findomain run_go run_crtsh run_chaos

#!/bin/bash

# Check if the domain argument is provided
if [ -z $1 ]; then
    echo "Please provide a domain name as an argument."
    exit 1
fi

# Define functions for each tool
export domain=$1
run_shuffledns() {
    local shuffledns_out="shuffledns.txt"
    if shuffledns -d $domain -w /home/thm/Documents/Recon/2m-subdomains.txt -r /home/thm/Documents/Recon/resolvers.txt -o $shuffledns_out -silent; then
        sort -u $shuffledns_out subdomains.txt -o subdomains.txt
        rm $shuffledns_out
        # comm -23 $shuffledns_out subdomains.txt >> subdomains.txt
    else
        echo "Error running ShuffleDNS."
        exit 1
    fi
    echo "***************Shuffledns ran successful***************"
}

run_subbrute() {
    local subbrute_out="subbrute.txt"
    if subbrute -p $domain -r /home/thm/Documents/Recon/resolvers.txt -o $subbrute_out;then
        sort -u $subbrute_out subdomains.txt -o subdomains.txt
        rm $subbrute_out
    else
        echo "Error running subbrute"
        exit 1
    fi
    echo "***************Subbrute ran successful***************"
}

run_dnsgen() {
    local dnsgen_out="dnsgen.txt"
    # if ! cat "subdomains.txt" | dnsgen - | massdns -r ~/Documents/Recon/resolvers.txt -q -t A -o J --flush 2>/dev/null;then
    if cat "subdomains.txt" | dnsgen - > $dnsgen_out ;then
        sort -u $dnsgen_out subdomains.txt -o subdomains.txt
        rm $dnsgen_out
    else
        echo "Error running dnsgen"
        exit 1
    fi
    echo "***************DNSGen ran successful***************"
}

run_ripgen() {
    local ripgen_out="ripgen.txt"
    if cat subdomains.txt | ripgen > $ripgen_out;then
        sort -u $ripgen_out subdomains.txt -o subdomains.txt
        rm $ripgen_out
    else
        echo "Error running ripgen"
        exit 1
    fi
    echo "***************RIPGen ran successful***************"
}

# run_dnsrecon(){
#     if ! dnsrecon -d $domain -D 
# }

# Export functions to use in parallel
export -f  run_shuffledns  run_dnsgen run_ripgen run_subbrute  

# Run all tools in parallel
parallel --jobs 4 ::: run_shuffledns run_dnsgen run_ripgen run_subbrute 

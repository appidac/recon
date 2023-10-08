# recon
automate the process of subdomain enumeration and DNSBrutforce

you can create a wordlist with this command to make dnsbruteforcing the domain
first find subdomains of the target with any way that you want then pass it to sed and awk to retrive each word taht used in subdomains
`cat subdomains.txt | sed 's/\.[^.]*\.[^.]*$//' | awk -F '.' '{ for(i=1; i<=NF-2; i++) printf "%s.", $i; print $NF }' | sort -u`

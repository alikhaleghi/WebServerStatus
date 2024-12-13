#!/bin/bash

# Path to the DirectAdmin domain list
DA_DOMAIN_PATH="/usr/local/directadmin/data/users"

# Output files
ACCESSIBLE_DOMAINS="../../Status/accessible_domains.txt"
UNREACHABLE_DOMAINS="../../Status/unreachable_domains.txt"

# Initialize counters
total_domains=0
accessible_count=0
unreachable_count=0

# Check if the DirectAdmin domain directory exists
if [[ ! -d "$DA_DOMAIN_PATH" ]]; then
    echo "Error: DirectAdmin domain path not found at $DA_DOMAIN_PATH"
    exit 1
fi

# Function to validate domain accessibility
validate_domain_accessibility() {
    local domain=$1
    if curl -s --head --connect-timeout 5 "$domain" | grep -q "200 OK"; then
        echo "$domain is accessible"
        echo "$domain" >> "$ACCESSIBLE_DOMAINS"
        ((accessible_count++))
    else
        echo "$domain is unreachable"
        echo "$domain" >> "$UNREACHABLE_DOMAINS"
        ((unreachable_count++))
    fi
}

# Function to check nameservers
check_nameservers() {
    local domain=$1
    echo "Checking nameservers for $domain"
    nslookup -type=NS "$domain" | awk '/nameserver/ {print $2}'
}

# Cleanup output files
rm -f "$ACCESSIBLE_DOMAINS" "$UNREACHABLE_DOMAINS"

# Loop through each user in DirectAdmin
for user_dir in "$DA_DOMAIN_PATH"/*; do
    if [[ -d "$user_dir" ]]; then
        domain_list="$user_dir/domains.list"
        if [[ -f "$domain_list" ]]; then
            while read -r domain; do
                ((total_domains++))
                echo "Processing domain: $domain"

                # Validate domain accessibility
                validate_domain_accessibility "$domain"

                # Check nameservers
                echo "Active Nameservers for $domain:" $(check_nameservers "$domain")
            done < "$domain_list"
        fi
    fi
done

# Display summary
echo "\nSummary:"
echo "Total domains processed: $total_domains"
echo "Accessible domains: $accessible_count"
echo "Unreachable domains: $unreachable_count"

#!/bin/bash

# Base directory of the script
BASE_DIR="$(dirname "$(realpath "$0")")"

# Define the Status directory
STATUS_DIR="$BASE_DIR/../../Status"

# Output files
ACCESSIBLE_DOMAINS="$STATUS_DIR/accessible_domains.txt"
UNREACHABLE_DOMAINS="$STATUS_DIR/unreachable_domains.txt"

# Initialize counters
total_domains=0
accessible_count=0
unreachable_count=0

# Ensure the Status directory exists
if ! mkdir -p "$STATUS_DIR"; then
    echo "Error: Unable to create directory $STATUS_DIR"
    exit 1
fi

# Function to validate domain accessibility
validate_domain_accessibility() {
    local domain=$1

    # Check if the domain resolves to an IP
    if ! nslookup "$domain" > /dev/null 2>&1; then
        echo "$domain is unreachable (DNS resolution failed)"
        echo "$domain" >> "$UNREACHABLE_DOMAINS"
        ((unreachable_count++))
        return
    fi

    # Check HTTP response
    if curl -s -L --head --connect-timeout 5 "$domain" | grep -E "HTTP/[0-9.]+ [23].." > /dev/null; then
        echo "$domain is accessible"
        echo "$domain" >> "$ACCESSIBLE_DOMAINS"
        ((accessible_count++))
    else
        echo "$domain is unreachable (HTTP check failed)"
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

# Path to the DirectAdmin domain list
DA_DOMAIN_PATH="/usr/local/directadmin/data/users"

# Check if the DirectAdmin domain directory exists
if [[ ! -d "$DA_DOMAIN_PATH" ]]; then
    echo "Error: DirectAdmin domain path not found at $DA_DOMAIN_PATH"
    exit 1
fi

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

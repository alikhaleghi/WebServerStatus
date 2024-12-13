#!/bin/bash

# Function to display header
function print_header() {
    echo "========================================="
    echo "$1"
    echo "========================================="
}

# Total RAM usage
print_header "RAM Usage"
total_mem=$(free -h | grep Mem | awk '{print $2}')
used_mem=$(free -h | grep Mem | awk '{print $3}')
avail_mem=$(free -h | grep Mem | awk '{print $7}')
echo "Total RAM: $total_mem"
echo "Used RAM: $used_mem"
echo "Available RAM: $avail_mem"

# Disk usage
print_header "Disk Usage"
df -h --total | grep -E "Filesystem|total"

# Bandwidth usage (requires vnstat)
if command -v vnstat > /dev/null; then
    print_header "Bandwidth Usage"
    vnstat -d
else
    echo "vnstat is not installed. Install it to track bandwidth usage."
fi

# Max CPU usage
print_header "CPU Usage"
top -b -n 1 | grep "%Cpu" | awk '{print "User: "$2"%", "System: "$4"%", "Idle: "$8"%"}'

# Summary of highest CPU-consuming processes
echo "\nTop 5 CPU-consuming processes:"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6

# Script footer
echo "\nSystem status check completed."
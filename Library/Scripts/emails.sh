#!/bin/bash

# Define the mail log file (change path if necessary)
MAIL_LOG="/var/log/exim/mainlog"

# Define the output file for counts
OUTPUT_FILE="/var/log/email_counts.log"

# Check if the log file exists
if [ ! -f "$MAIL_LOG" ]; then
    echo "Mail log file not found: $MAIL_LOG"
    exit 1
fi

# Function to count outgoing emails
count_outgoing_emails() {
    grep -i "<= " "$MAIL_LOG" | grep -i "P=local" | wc -l
}

# Function to count incoming emails
count_incoming_emails() {
    grep -i "=> " "$MAIL_LOG" | grep -i "P=local" | wc -l
}

# Get counts
OUTGOING=$(count_outgoing_emails)
INCOMING=$(count_incoming_emails)

# Get the current date
CURRENT_DATE=$(date "+%Y-%m-%d")

# Write daily and total counts to the output file
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "Date,Outgoing Emails,Incoming Emails,Total Outgoing,Total Incoming" > "$OUTPUT_FILE"
    TOTAL_OUTGOING=0
    TOTAL_INCOMING=0
else
    TOTAL_OUTGOING=$(awk -F',' 'NR>1 {sum += $4} END {print sum}' "$OUTPUT_FILE")
    TOTAL_INCOMING=$(awk -F',' 'NR>1 {sum += $5} END {print sum}' "$OUTPUT_FILE")
fi

TOTAL_OUTGOING=$((TOTAL_OUTGOING + OUTGOING))
TOTAL_INCOMING=$((TOTAL_INCOMING + INCOMING))

echo "$CURRENT_DATE,$OUTGOING,$INCOMING,$TOTAL_OUTGOING,$TOTAL_INCOMING" >> "$OUTPUT_FILE"

# Display results
echo "Outgoing Emails (Today): $OUTGOING"
echo "Incoming Emails (Today): $INCOMING"
echo "Total Outgoing Emails: $TOTAL_OUTGOING"
echo "Total Incoming Emails: $TOTAL_INCOMING"

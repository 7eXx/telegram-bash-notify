#!/bin/bash
# Example script that sends a Telegram message on exit

set -xe

# === Load environment variables ===
[ -f .env ] && . ./.env
[ -f .env.local ] && . ./.env.local

# === Check environment variables ===
if [ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ]; then
    echo "Missing required environment variables: BOT_TOKEN, CHAT_ID"
    exit 1
fi

# === Helper function ===
send_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
         -d chat_id="${CHAT_ID}" \
         -d text="${message}" \
         -d parse_mode="Markdown" > /dev/null
}

# === Trap exit (runs regardless of success/failure) ===
on_exit() {
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        send_telegram "✅ *Script finished successfully* on $(hostname)"
    else
        send_telegram "❌ *Script failed* on $(hostname), Exit code: ${exit_code}"
    fi
}

trap on_exit EXIT

# generate a random number
random_number=$(shuf -i 1-100 -n 1)
# check if the random number is even
if [ $((random_number % 2)) -eq 0 ]; then
    # exit with success
    exit 0
else
    # exit with failure
    exit 1
fi

exit 0

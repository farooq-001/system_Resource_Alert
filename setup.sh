#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

# Define paths
TARGET_PATH="/opt"
APP_PATH="$TARGET_PATH/alpha-smtp"
VENV_PATH="$TARGET_PATH/venu"

# Create the target directory
mkdir -p "$TARGET_PATH"

# Unzip the Alpha-Smtp.zip to the target path
if ! unzip Alpha-Smtp.zip -d "$TARGET_PATH"; then
    echo "Failed to unzip Alpha-Smtp.zip" >&2
    exit 1
fi

# Navigate to the application directory
cd "$APP_PATH" || { echo "Application directory not found at $APP_PATH"; exit 1; }

# Set up Python virtual environment
python3 -m venv "$VENV_PATH"
source "$VENV_PATH/bin/activate"

# Install necessary Python packages
pip install --upgrade pip
pip install flask gunicorn requests psutil

# Add the cron job if it's not already present
CRON_JOB="* * * * * $VENV_PATH/bin/python3 $APP_PATH/Resource_Alert.py"
(crontab -l 2>/dev/null | grep -Fv "$CRON_JOB"; echo "$CRON_JOB") | crontab -

echo "Setup complete."

#!/bin/bash

# Script to completely remove all Python installations on macOS Silicon and reinstall a fresh Python vX.
# Includes enhanced error handling, logging with timestamps, and improvements in clarity.

LOGFILE="python_cleanup.log"
PYTHON_VERSION="3.13" # change with desired version X
BREW_PATH="/opt/homebrew/bin/brew"

# Function to log messages with a timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

# Error handling function with timestamp and additional error message context
handle_error() {
    log_message "ERROR: Step '$2' failed on line $1. Exiting script."
    exit 1
}

# Set up trap for error handling
trap 'handle_error $LINENO "$STEP"' ERR

# Start logging with timestamp
log_message "Python Cleanup Script Started."

# Step-by-step actions with error handling and logging

STEP="Removing Python from /Library/Frameworks"
log_message "$STEP..."
if [ -d "/Library/Frameworks/Python.framework" ]; then
    sudo rm -rf /Library/Frameworks/Python.framework 2>&1 | tee -a $LOGFILE || handle_error $LINENO "$STEP"
else
    log_message "Python not found in /Library/Frameworks. Skipping..."
fi

STEP="Removing Python from /usr/local/bin"
log_message "$STEP..."
if [ -d "/usr/local/bin/python*" ]; then
    sudo rm -rf /usr/local/bin/python* 2>&1 | tee -a $LOGFILE || handle_error $LINENO "$STEP"
else
    log_message "Python not found in /usr/local/bin. Skipping..."
fi

STEP="Uninstalling Python via Homebrew"
if command -v brew &> /dev/null; then
    log_message "$STEP..."
    $BREW_PATH uninstall --force python 2>&1 | tee -a $LOGFILE || handle_error $LINENO "$STEP"
    $BREW_PATH autoremove 2>&1 | tee -a $LOGFILE
    $BREW_PATH cleanup 2>&1 | tee -a $LOGFILE
else
    log_message "Homebrew not found. Skipping Homebrew Python removal..."
fi

STEP="Removing user-installed Python packages"
log_message "$STEP..."
if [ -d "~/Library/Python" ]; then
    rm -rf ~/Library/Python 2>&1 | tee -a $LOGFILE || handle_error $LINENO "$STEP"
fi
if [ -d "~/.local/lib/python*" ]; then
    rm -rf ~/.local/lib/python* 2>&1 | tee -a $LOGFILE || handle_error $LINENO "$STEP"
fi

STEP="Removing Python from /opt/homebrew"
log_message "$STEP..."
if [ -d "/opt/homebrew/Cellar/python*" ]; then
    sudo rm -rf /opt/homebrew/Cellar/python* /opt/homebrew/bin/python* 2>&1 | tee -a $LOGFILE || handle_error $LINENO "$STEP"
else
    log_message "No Python found in /opt/homebrew. Skipping..."
fi

# Safer targeted cleanup for Python files in specific directories
STEP="Performing additional targeted cleanup for Python files in known directories"
log_message "$STEP..."

# Array of directories to target specifically
TARGET_DIRECTORIES=(
    "/usr/local/lib"
    "/usr/local/share"
    "/usr/local/include"
    "/opt/homebrew/lib"
    "/opt/homebrew/share"
)

for DIR in "${TARGET_DIRECTORIES[@]}"; do
    log_message "Cleaning Python files in $DIR"
    if [ -d "$DIR" ]; then
        # List the files to be removed without executing rm -rf immediately
        log_message "Files to be cleaned in $DIR:"
        find "$DIR" -maxdepth 1 -name 'python*' | tee -a $LOGFILE
    else
        log_message "$DIR not found. Skipping..."
    fi
done

# Verify removal
STEP="Verifying removal of Python installations"
log_message "$STEP..."
if command -v python3 &> /dev/null || command -v python &> /dev/null; then
    log_message "Python still detected. Some residual files may require manual cleanup."
else
    log_message "Python successfully removed from the system."
fi

# Install Homebrew if not installed, then install Python 3.13
STEP="Checking Homebrew installation and installing Python 3.13"
if ! command -v brew &> /dev/null; then
    log_message "Homebrew not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" | tee -a $LOGFILE || handle_error $LINENO "$STEP"
fi

$BREW_PATH update 2>&1 | tee -a $LOGFILE || handle_error $LINENO "Updating Homebrew"
log_message "Installing Python $PYTHON_VERSION via Homebrew..."
$BREW_PATH install python@$PYTHON_VERSION 2>&1 | tee -a $LOGFILE || handle_error $LINENO "$STEP"

# Verify Python installation
STEP="Verifying Python installation"
log_message "$STEP..."
if python3 --version | grep -q "$PYTHON_VERSION"; then
    log_message "Python $PYTHON_VERSION successfully installed."
else
    log_message "Failed to install Python $PYTHON_VERSION. Please check Homebrew installation."
    exit 1
fi

# Update pip and create an alias for Python
STEP="Updating pip and setting up virtual environment"
log_message "$STEP..."
python3 -m pip install --upgrade pip 2>&1 | tee -a $LOGFILE || handle_error $LINENO "$STEP"

# Set alias in shell profile
STEP="Setting up alias for Python $PYTHON_VERSION as default 'python' command"
log_message "$STEP..."
echo "alias python='/opt/homebrew/bin/python3'" >> ~/.zshrc
source ~/.zshrc

log_message "Python environment setup completed successfully."
log_message "Script completed."

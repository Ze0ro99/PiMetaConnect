#!/bin/bash

# Script Name: git-clone-pimetaconnect.sh
# Purpose: Automate cloning of PiMetaConnect repository

# Configuration Section - Pre-filled with provided values
REPO_NAME="PiMetaConnect"
USERNAME="Ze0ro99"
HTTPS_URL="https://github.com/Ze0ro99/PiMetaConnect.git"
SSH_URL="git@github.com:Ze0ro99/PiMetaConnect.git"
DEFAULT_CLONE_DIR="./PiMetaConnect"

# Colors for better output
GREEN='\033[0;32m'
RED='\033[0;33m'
NC='\033[0m' # No Color

# Function to check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: Git is not installed. Please install Git first.${NC}"
        exit 1
    fi
}

# Function to perform clone operation
clone_repo() {
    local url=$1
    local destination=$2
    
    echo -e "${GREEN}Cloning repository from: $url${NC}"
    if [ -d "$destination" ]; then
        echo "Directory $destination already exists. Pulling latest changes instead..."
        cd "$destination" && git pull
    else
        git clone "$url" "$destination"
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully cloned/updated repository to $destination${NC}"
    else
        echo -e "${RED}Failed to clone/update repository${NC}"
        exit 1
    fi
}

# Main execution
echo "=== Git Repository Cloning Automation ==="
echo "Repository: $REPO_NAME"
echo "Username: $USERNAME"
echo "========================================"

# Check prerequisites
check_git

# Prompt user for clone method
echo "Select clone method:"
echo "1) HTTPS (${HTTPS_URL})"
echo "2) SSH (${SSH_URL})"
read -p "Enter your choice (1 or 2): " choice

# Process user choice
case $choice in
    1)
        clone_repo "$HTTPS_URL" "$DEFAULT_CLONE_DIR"
        ;;
    2)
        clone_repo "$SSH_URL" "$DEFAULT_CLONE_DIR"
        ;;
    *)
        echo -e "${RED}Invalid choice. Please run again and select 1 or 2.${NC}"
        exit 1
        ;;
esac
chmod +x git-clone-pimetaconnect.sh

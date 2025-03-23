#!/bin/bash

# Script Name: pimetaconnect-manager.sh
# Purpose: Fully automate PiMetaConnect repository management

# Pre-filled Configuration
REPO_NAME="PiMetaConnect"
USERNAME="Ze0ro99"
HTTPS_URL="https://github.com/Ze0ro99/PiMetaConnect.git"
SSH_URL="git@github.com:Ze0ro99/PiMetaConnect.git"
DEFAULT_CLONE_DIR="./PiMetaConnect"
DEFAULT_BRANCH="main"

# Colors for better output
GREEN='\033[0;32m'
RED='\033[0;33m'
NC='\033[0m' # No Color

# Function to check prerequisites
check_prerequisites() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: Git is not installed. Please install Git first.${NC}"
        exit 1
    fi
}

# Function to clone repository if not exists
clone_repo() {
    local url=$1
    if [ -d "$DEFAULT_CLONE_DIR" ]; then
        echo "Repository already exists locally. Skipping clone..."
    else
        echo -e "${GREEN}Cloning repository from: $url${NC}"
        git clone "$url" "$DEFAULT_CLONE_DIR"
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to clone repository${NC}"
            exit 1
        fi
    fi
    cd "$DEFAULT_CLONE_DIR" || exit 1
}

# Function to pull latest changes
pull_changes() {
    echo -e "${GREEN}Pulling latest changes from $DEFAULT_BRANCH...${NC}"
    git pull origin "$DEFAULT_BRANCH"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to pull changes${NC}"
        exit 1
    fi
}

# Function to commit and push changes
commit_and_push() {
    echo "Checking for changes..."
    git add .
    if git status | grep -q "nothing to commit"; then
        echo "No changes to commit."
    else
        read -p "Enter commit message: " commit_message
        git commit -m "$commit_message"
        echo -e "${GREEN}Pushing changes to $DEFAULT_BRANCH...${NC}"
        git push origin "$DEFAULT_BRANCH"
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to push changes${NC}"
            exit 1
        fi
        echo -e "${GREEN}Changes successfully pushed!${NC}"
    fi
}

# Main automation function
automate_workflow() {
    local url=$1
    clone_repo "$url"
    pull_changes
    commit_and_push
}

# Main execution
echo "=== PiMetaConnect Repository Manager ==="
echo "Repository: $REPO_NAME"
echo "Username: $USERNAME"
echo "========================================"

# Check prerequisites
check_prerequisites

# Prompt user for clone method
echo "Select clone method:"
echo "1) HTTPS (${HTTPS_URL})"
echo "2) SSH (${SSH_URL})"
read -p "Enter your choice (1 or 2): " choice

# Process user choice and execute workflow
case $choice in
    1)
        automate_workflow "$HTTPS_URL"
        ;;
    2)
        automate_workflow "$SSH_URL"
        ;;
    *)
        echo -e "${RED}Invalid choice. Please run again and select 1 or 2.${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}Repository management completed successfully!${NC}"
chmod +x pimetaconnect-manager.sh

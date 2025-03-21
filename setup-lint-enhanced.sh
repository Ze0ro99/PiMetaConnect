#!/bin/bash

# Meta-Connect Setup Script
# This script automates the setup of the Meta-Connect project.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print messages
print_message() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

print_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 is required but not installed. Please install it and try again."
    fi
}

# Step 1: Check for required tools
print_message "Checking for required tools..."
check_command node
check_command npm
check_command python3
check_command pip3
check_command git

# Step 2: Verify project structure
print_message "Verifying project structure..."
if [ ! -d "frontend" ] || [ ! -d "backend" ] || [ ! -d "scripts" ]; then
    print_error "Project structure is incorrect. Please ensure 'frontend', 'backend', and 'scripts' directories exist."
fi

# Step 3: Set up environment variables
print_message "Setting up environment variables..."
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_message "Created .env file from .env.example. Please fill in the required values."
    else
        print_warning ".env.example not found. Please create a .env file with the required environment variables."
    fi
else
    print_message ".env file already exists."
fi

# Step 4: Install Frontend dependencies
print_message "Installing Frontend dependencies..."
cd frontend || print_error "Failed to navigate to frontend directory."
npm install || print_error "Failed to install Frontend dependencies."
cd ..

# Step 5: Install Backend dependencies (Node.js)
print_message "Installing Backend (Node.js) dependencies..."
cd backend || print_error "Failed to navigate to backend directory."
npm install || print_error "Failed to install Backend (Node.js) dependencies."
cd ..

# Step 6: Install Backend dependencies (Python)
print_message "Installing Backend (Python) dependencies..."
if [ -f "scripts/requirements.txt" ]; then
    pip3 install -r scripts/requirements.txt || print_error "Failed to install Python dependencies."
else
    print_warning "requirements.txt not found in scripts directory. Skipping Python dependencies installation."
fi

# Step 7: Set up linting tools
print_message "Setting up linting tools..."
# Frontend: ESLint
cd frontend
if ! npm list eslint &> /dev/null; then
    npm install --save-dev eslint || print_warning "Failed to install ESLint."
    npx eslint --init || print_warning "Failed to initialize ESLint."
else
    print_message "ESLint is already installed."
fi
cd ..

# Backend: Flake8 for Python
if ! pip3 list | grep flake8 &> /dev/null; then
    pip3 install flake8 || print_warning "Failed to install Flake8."
else
    print_message "Flake8 is already installed."
fi

# Step 8: Run tests (if available)
print_message "Running tests..."
if [ -d "tests" ]; then
    # Frontend tests
    cd frontend
    if npm test -- --silent; then
        print_message "Frontend tests passed."
    else
        print_warning "Frontend tests failed. Please check the test output."
    fi
    cd ..

    # Backend tests (Python)
    if pytest tests/; then
        print_message "Backend tests passed."
    else
        print_warning "Backend tests failed. Please check the test output."
    fi
else
    print_warning "Tests directory not found. Skipping tests."
fi

# Step 9: Start the application
print_message "Starting the application..."
# Start Backend
cd backend
npm start &
BACKEND_PID=$!
cd ..

# Start Frontend
cd frontend
npm start &
FRONTEND_PID=$!

# Wait for both processes to complete
wait $BACKEND_PID $FRONTEND_PID

print_message "Meta-Connect setup completed successfully!"
print_message "Frontend should be running at http://localhost:3000"
print_message "Backend should be running at http://localhost:5000 (or your configured port)."

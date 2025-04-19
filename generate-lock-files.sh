#!/bin/bash

# Script to generate lock files for both frontend and backend directories

# Generate lock file for frontend
if [ -d "frontend" ]; then
  echo "Generating package-lock.json for frontend..."
  cd frontend
  if [ -f "package.json" ]; then
    npm install --package-lock-only
    echo "package-lock.json generated for frontend."
  else
    echo "Error: package.json not found in frontend directory!"
  fi
  cd ..
else
  echo "Frontend directory does not exist!"
fi

# Generate lock file for backend
if [ -d "backend" ]; then
  echo "Generating package-lock.json for backend..."
  cd backend
  if [ -f "package.json" ]; then
    npm install --package-lock-only
    echo "package-lock.json generated for backend."
  else
    echo "Error: package.json not found in backend directory!"
  fi
  cd ..
else
  echo "Backend directory does not exist!"
fi

# Commit the generated lock files
if [ -f "frontend/package-lock.json" ] || [ -f "backend/package-lock.json" ]; then
  git add frontend/package-lock.json backend/package-lock.json
  git commit -m "Add generated lock files for frontend and backend"
  git push origin main
else
  echo "No lock files to commit."
fi

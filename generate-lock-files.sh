#!/bin/bash

# Navigate to frontend directory and generate package-lock.json
if [ -d "frontend" ]; then
  echo "Generating package-lock.json for frontend..."
  cd frontend
  npm install --package-lock-only
  cd ..
else
  echo "Frontend directory not found!"
fi

# Navigate to backend directory and generate package-lock.json
if [ -d "backend" ]; then
  echo "Generating package-lock.json for backend..."
  cd backend
  npm install --package-lock-only
  cd ..
else
  echo "Backend directory not found!"
fi

# Commit the lock files
git add frontend/package-lock.json backend/package-lock.json
git commit -m "Add lock files for frontend and backend"
git push origin main

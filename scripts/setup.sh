#!/bin/bash
echo "Installing client dependencies..."
cd client && npm install
cd ..
echo "Installing server dependencies..."
cd server && npm install
echo "All dependencies installed. Setup complete!"

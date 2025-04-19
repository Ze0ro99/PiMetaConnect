#!/bin/bash

# Enhanced Script for Managing App Icons and README Update

# Function to create a directory if it doesn't exist
create_directory() {
  local dir_path=$1
  if [ ! -d "$dir_path" ]; then
    echo "Creating directory: $dir_path"
    mkdir -p "$dir_path" || { echo "Error: Failed to create directory $dir_path"; exit 1; }
  else
    echo "Directory $dir_path already exists."
  fi
}

# Function to move app icons to the target directory
move_app_icons() {
  local target_dir=$1
  echo "Moving app icons to $target_dir..."
  for icon in app_icon_*.png; do
    if [ -f "$icon" ]; then
      mv "$icon" "$target_dir" || { echo "Error: Failed to move $icon"; exit 1; }
    else
      echo "Warning: Icon $icon not found in the current directory."
    fi
  done
}

# Function to update the README file with an App Icons section
update_readme() {
  local readme_file="README.md"
  echo "Updating $readme_file with App Icons section..."
  
  # Create README file if it doesn't exist
  if [ ! -f "$readme_file" ]; then
    echo "$readme_file not found. Creating a new one."
    touch "$readme_file"
  fi

  # Backup the existing README file
  cp "$readme_file" "${readme_file}.bak"

  # Append App Icons section to the README file
  cat >> "$readme_file" << 'EOF'

---

## 📱 App Icons

Below are the app icons for **PiMetaConnect** in various sizes, ready for use in different environments (e.g., app stores or devices):

| Size          | Icon                                                                   |
|---------------|------------------------------------------------------------------------|
| 48x48         | <img src="assets/icons/app_icon_48x48.png" alt="App Icon 48x48" width="48"/> |
| 72x72         | <img src="assets/icons/app_icon_72x72.png" alt="App Icon 72x72" width="72"/> |
| 96x96         | <img src="assets/icons/app_icon_96x96.png" alt="App Icon 96x96" width="96"/> |
| 120x120       | <img src="assets/icons/app_icon_120x120.png" alt="App Icon 120x120" width="120"/> |
| 180x180       | <img src="assets/icons/app_icon_180x180.png" alt="App Icon 180x180" width="180"/> |
| 192x192       | <img src="assets/icons/app_icon_192x192.png" alt="App Icon 192x192" width="192"/> |
| 256x256       | <img src="assets/icons/app_icon_256x256.png" alt="App Icon 256x256" width="256"/> |
| 512x512       | <img src="assets/icons/app_icon_512x512.png" alt="App Icon 512x512" width="512"/> |
| 1024x1024     | <img src="assets/icons/app_icon_1024x1024.png" alt="App Icon 1024x1024" width="512"/> |

EOF
  echo "App Icons section added to $readme_file."
}

# Main execution flow
echo "Starting script execution..."
create_directory "assets/icons"
move_app_icons "assets/icons"
update_readme
echo "Script execution completed."

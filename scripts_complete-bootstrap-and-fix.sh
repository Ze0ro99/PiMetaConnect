#!/bin/bash
# PiMetaConnect: Complete Bootstrap, Fixes, and Live Start Script
# Author: Ze0ro99 (generated with Copilot)
# License: MIT

set -e

echo "=== PiMetaConnect: Complete Bootstrap, Fixes, and Live Start ==="

# --- 1. Environment Validation ---
echo "1. Checking essential tools..."
for cmd in node npm git bash; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "✖ $cmd is not installed. Please install $cmd and retry."
    exit 1
  fi
done
echo "✔ All essential tools detected."

# --- 2. Directory Structure Checks & Creation ---
echo "2. Checking and creating missing directories..."
for dir in client server blockchain scripts docs public; do
  if [ ! -d "$dir" ]; then
    echo " - Missing $dir/, creating..."
    mkdir -p "$dir"
  fi
done

# --- 3. Install/Update Dependencies ---
echo "3. Installing/updating dependencies..."
if [ -f client/package.json ]; then
  cd client
  npm install
  cd ..
else
  echo " - Creating minimal client/package.json..."
  mkdir -p client
  cat <<EOL > client/package.json
{
  "name": "pimetaconnect-client",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "pi-sdk": "^2.0.0"
  }
}
EOL
  cd client
  npm install
  cd ..
fi

if [ -f server/package.json ]; then
  cd server
  npm install
  cd ..
fi

if [ -f blockchain/package.json ]; then
  cd blockchain
  npm install
  cd ..
fi

# --- 4. Ensure Pi SDK Setup in Client ---
echo "4. Ensuring Pi SDK is linked in frontend..."
PI_SDK_TAG='<script src="https://sdk.minepi.com/pi-sdk.js"></script>'
PI_INIT_TAG='<script>Pi.init({ version: "2.0" })</script>'
INDEX_HTML="client/public/index.html"
if [ -f "$INDEX_HTML" ]; then
  if ! grep -q "$PI_SDK_TAG" "$INDEX_HTML"; then
    echo " - Adding Pi SDK script tag to $INDEX_HTML..."
    sed -i "1s;^;$PI_SDK_TAG\n$PI_INIT_TAG\n;" "$INDEX_HTML"
  fi
else
  echo " - $INDEX_HTML not found, creating minimal index.html..."
  mkdir -p client/public
  cat <<EOL > $INDEX_HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>PiMetaConnect</title>
  $PI_SDK_TAG
  $PI_INIT_TAG
</head>
<body>
  <div id="root"></div>
</body>
</html>
EOL
fi

# --- 5. Pi Network Config File ---
echo "5. Ensuring Pi Network config file exists..."
PI_CONFIG="src/pi-config.js"
if [ ! -f "$PI_CONFIG" ]; then
  mkdir -p src
  cat <<EOL > $PI_CONFIG
// Pi Network SDK Configuration
const piConfig = {
    appId: 'YOUR_PI_APP_ID', // Set in Pi Developer Portal
    apiKey: 'YOUR_PI_API_KEY', // Set in Pi Developer Portal
};
module.exports = piConfig;
EOL
  echo " - Created $PI_CONFIG (please update with your App ID and API Key)."
fi

# --- 6. Documentation & Compliance Fixes ---
echo "6. Ensuring documentation and compliance files..."
declare -A DOCS=(
  ["docs/pi-network-integration.md"]="# Pi Network Integration Guide

## SDK Setup

\`\`\`html
<script src=\"https://sdk.minepi.com/pi-sdk.js\"></script>
<script>Pi.init({ version: \"2.0\" })</script>
\`\`\`

## Authentication & Payments

- Use Pi SDK methods for authenticating users and accessing wallet balances.
- Implement User-to-App and App-to-User payment flows with server-side approval/completion.
- Test with the Testnet before switching to Mainnet.

## App Registration

- Register in the Pi Developer Portal (\`pi://develop.pi\`) for both Mainnet and Testnet.
- Complete the platform’s checklist for hosting, wallet, and permissions.

## More Resources

- [Pi Platform Docs](https://github.com/pi-apps/pi-platform-docs)
- [SDK Reference](https://github.com/pi-apps/pi-platform-docs/blob/master/SDK_reference.md)
- [Payments Guide](https://github.com/pi-apps/pi-platform-docs/blob/master/payments.md)
"
  ["docs/privacy-policy.md"]="**Last Updated: $(date +%Y-%m-%d)**

PiMetaConnect (\"we\", \"our\", or \"us\") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, store, and share your information when you use our app and services, including Pi Network integration.

## What Data We Collect
- Account information (username, email) via Pi Network authentication
- Wallet address and balance (read-only)
- Usage data (for improving app functionality and security)

## How We Use Data
- To provide you access to social, metaverse, and NFT features
- To process transactions and manage your Pi wallet
- To improve our services and ensure compliance with Pi Network guidelines

## Data Sharing
- We **do not** sell or share your data with third parties except as required for Pi Network integration or by law.

## Security
- We use best practices to protect your information, including encrypted connections and secure storage.
- Sensitive keys and credentials are never stored client-side.

## Your Rights
- You may request deletion of your account or data at any time by contacting support.

## Contact
For privacy-related inquiries: ze0ro99@example.com
"
  ["docs/terms-of-service.md"]="# Terms of Service

By using PiMetaConnect, you agree to comply with all Pi Network terms and this platform’s rules. For the latest Pi Network ToS, see: https://socialchain.app/tos

- Use only for lawful purposes.
- Do not attempt to reverse-engineer or abuse Pi Network APIs.
- All NFT and metaverse assets are copyright Ze0ro99 unless otherwise noted.

See LICENSE for more.
"
)
for file in "${!DOCS[@]}"; do
  if [ ! -f "$file" ]; then
    mkdir -p "$(dirname "$file")"
    echo "${DOCS[$file]}" > "$file"
    echo " - Created $file"
  fi
done

# --- 7. Update README Quick Start ---
README="README.md"
if [ ! -f "$README" ]; then
  cat <<EOL > $README
# PiMetaConnect

## Quick Start

1. Clone the repository
   \`\`\`sh
   git clone https://github.com/Ze0ro99/PiMetaConnect.git
   cd PiMetaConnect
   \`\`\`
2. Run the bootstrap script
   \`\`\`sh
   bash scripts/complete-bootstrap-and-fix.sh
   \`\`\`
3. Register your app on the Pi Developer Portal (pi://develop.pi)
4. Start development:
   - Frontend: \`cd client && npm start\`
   - Backend: \`cd server && npm start\`
   - Blockchain: \`cd blockchain && npx hardhat node\`
5. See \`docs/pi-network-integration.md\` for integration help.

## Support

- [Open an Issue](https://github.com/Ze0ro99/PiMetaConnect/issues/new/choose)
EOL
  echo " - Created $README"
fi

# --- 8. Start Application ---
echo "7. Starting application... (frontend only by default)"
if [ -f client/package.json ]; then
  cd client
  npm start &
  cd ..
fi
if [ -f server/package.json ]; then
  cd server
  npm start &
  cd ..
fi
if [ -f blockchain/package.json ]; then
  cd blockchain
  npx hardhat node &
  cd ..
fi

echo "✔ All setup complete and services started."
echo "Visit your frontend (usually at http://localhost:3000) and PiMetaConnect is ready!"
echo "Make sure to update src/pi-config.js with your Pi Network App ID and API Key from the Pi Developer Portal."
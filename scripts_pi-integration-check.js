const fs = require('fs');
const clientPkg = require('../client/package.json');

if (clientPkg.dependencies && clientPkg.dependencies['pi-sdk']) {
  console.log('✔ Pi SDK detected in client dependencies.');
} else {
  console.error('✖ Pi SDK missing! Please add "pi-sdk" to client dependencies.');
  process.exit(1);
}
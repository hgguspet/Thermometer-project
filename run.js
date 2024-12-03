/**
 * @brief file to run all processes required for the web server
 * @details runs npm for the react website and node for the backend server.js file
 */


const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Resolve paths for Node server and React app
const serverPath = path.resolve(__dirname, 'backend/server.js');
const webPath = path.resolve(__dirname, 'web');

// Check if server.js exists
if (!fs.existsSync(serverPath)) {
  console.error(`Error: server.js not found at ${serverPath}`);
  process.exit(1);
}

// Check if web/src exists
if (!fs.existsSync(path.join(webPath, 'src'))) {
  console.error(`Error: React source directory not found at ${path.join(webPath, 'src')}`);
  process.exit(1);
}

// Start the Node server
const server = spawn('node', [serverPath], { stdio: 'inherit' });

// Start the React app
const react = spawn('npm', ['start'], { stdio: 'inherit', cwd: webPath });

// Handle server process close events
server.on('close', (code) => {
  console.log(`Server process exited with code ${code}`);
});

// Handle React process close events
react.on('close', (code) => {
  console.log(`React process exited with code ${code}`);
});


const { exec } = require('child_process');

// Read the environment variables
const WEB_PORT = process.env.WEB_PORT || 5000;  // Default to 5000 if not set
const NODE_PORT = process.env.NODE_PORT || 3000; // Default to 3000 if not set

console.log(`Starting the web servers with the following settings:
- WEB_PORT: ${WEB_PORT}
- NODE_PORT: ${NODE_PORT}`);

// Function to run the Node.js server (server.js)
const runNodeServer = () => {
    return new Promise((resolve, reject) => {
        console.log(`Starting Node.js server on port ${NODE_PORT}...`);

        // Start the Node.js server (assuming 'server.js' is in the backend folder)
        const nodeServer = exec(`node backend/server.js --port ${NODE_PORT}`, (error, stdout, stderr) => {
            if (error) {
                reject(`Node.js server failed: ${stderr}`);
                return;
            }
            console.log(stdout);
            resolve('Node.js server started successfully');
        });

        nodeServer.stdout.pipe(process.stdout);
        nodeServer.stderr.pipe(process.stderr);
    });
};



// Function to run the React app using npm start
const runReactServer = () => {
    return new Promise((resolve, reject) => {
        // Run React app server using npm start (assuming your package.json is set up for it)
        const reactServer = exec(`npm start --prefix web`, (error, stdout, stderr) => {
            if (error) {
                reject(`React app server failed: ${stderr}`);
                return;
            }
            console.log(stdout);
            resolve('React app server started successfully');
        });

        reactServer.stdout.pipe(process.stdout);
        reactServer.stderr.pipe(process.stderr);
    });
};

// Run the React server
const startServer = async () => {
    try {
        await runReactServer();
        console.log("React app is running successfully!");
    } catch (error) {
        console.error(`Error starting the React server: ${error}`);
    }
};

// Run both servers concurrently, with the React server starting first
const runServers = async () => {
    try {
        // Start React server first, then Node.js server
        const [reactResult, nodeResult] = await Promise.all([startServer(), runNodeServer()]);
        
        console.log(reactResult);
        console.log(nodeResult);
        console.log("Both servers are running successfully!");
    } catch (error) {
        console.error(`Error starting servers: ${error}`);
    }
};

// Run the servers
runServers();

//runReactServer();

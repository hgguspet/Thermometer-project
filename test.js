const { exec } = require('child_process');

// Read the environment variable for the React app port, or default to 5000
const WEB_PORT = process.env.WEB_PORT || 5000;  // Default to 5000 if not set

console.log(`Starting React app using npm start on port ${WEB_PORT}...`);

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

// Start the server
startServer();


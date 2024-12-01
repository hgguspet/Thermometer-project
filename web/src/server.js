/// @TODO: move the sensitive data in this file to a file incluede in a .gitignore asap

/* includes */
const express = require('express');
const mysql = require('mysql');
const cors = require('cors');

const app = express();

// allow requests from react
app.use(cors());
// parse json
app.use(express.json());

// mysql connection
const db = mysql.createPool({
    connectionLimit : 10,
    host :'localhost',
    user : 'fireproof',
    password : 'safepass',
    database : 'tData',
});
app.get('/data', (req, res) => {
    const query = 'SELECT * FROM bufferTable ORDER BY id DESC LIMIT 10';
    db.query(query, (err, results) => {
    if (err) {
        res.status(500).send(err);
    } else {
        // Transform RowDataPacket objects into plain objects
        const plainResults = results.map((row) => ({ ...row }));
        res.json(plainResults); // Send transformed data to the client    
        }
    });
});



// Start the server

const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});

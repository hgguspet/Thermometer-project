/// @TODO: move the sensitive data in this file to a file incluede in a .gitignore asap

/* includes */
const crypto = require('crypto');
const express = require('express');
const mysql = require('mysql');
const cors = require('cors');

const app = express();
const secretKey = "key";


// mysql connection
const db = mysql.createPool({
    connectionLimit : 10,
    host :'localhost',
    user : 'fireproof',

    password : 'safepass',
    database : 'tData',
});


// allow requests from react
app.use(cors());
// parse json
app.use(express.json());

app.get('/data', (req, res) => {
    // Fetch data from MySQL
    const query = 'SELECT * FROM bufferTable ORDER BY id DESC LIMIT 10';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send(err);
        } else {
            res.json(results);
        }
    });
});

// pushing data
app.get('/push_data.js', (req, res) => {
    const { temp, hum, key } = req.query;

    if (!temp || !hum || !key) {
        return res.status(400).json({ status: 'error', message: 'Missing parameters' });
    }

    const dataToHash = `temp=${temp}&hum=${hum}`;
    const calculatedHash = crypto
        .createHmac('sha256', secretKey)
        .update(dataToHash)
        .digest('hex');

    if (calculatedHash !== key) {
        return res.status(401).json({ status: 'error', message: 'Invalid HMAC' });
    }

    const query = 'INSERT INTO bufferTable (temperature, humidity) VALUES (?, ?)';
    db.query(query, [parseFloat(temp), parseFloat(hum)], (err, result) => {
        if (err) {
            console.error('Error inserting data', err);
            return res.status(500).json({ status: 'error', message: 'Database error' });
        }

        // Send response after successful insertion
        res.json({ status: 'success', message: 'Data inserted', temp, hum });
    });
});




// Start the server

const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});

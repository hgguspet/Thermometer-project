<?php

require 'sensitive_data.php';

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Create connection
$conn = mysqli_connect($servername, $username, $mysqlpwd, $database);

// Check connection
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error() . "<br>");
}
echo "Connected successfully<br>";

// Drop the procedure if it exists
$sqlDrop = "DROP PROCEDURE IF EXISTS InsertHourlyData;";
if ($conn->query($sqlDrop) === TRUE) {
    echo "Procedure dropped successfully (if it existed).<br>";
} else {
    echo "Error dropping procedure: " . $conn->error . "<br>";
}

// Create the procedure
$sqlCreate = "
CREATE PROCEDURE InsertHourlyData()
BEGIN
    -- Check if there is data for the last hour
    IF EXISTS (
        SELECT 1
        FROM bufferTable
        WHERE created_at >= NOW() - INTERVAL 1 HOUR
    ) THEN
        -- Perform the insertion
        INSERT INTO hourTable (temperature, humidity, created_at)
        SELECT
            AVG(temperature),
            AVG(humidity),
            NOW()
        FROM bufferTable
        WHERE created_at >= NOW() - INTERVAL 1 HOUR;
    ELSE
        -- Print a message if no data is found
        SELECT 'No data available in bufferTable for the last hour.' AS Message;
    END IF;
END;
";

if ($conn->query($sqlCreate) === TRUE) {
    echo "Procedure created successfully.<br>";
} else {
    echo "Error creating procedure: " . $conn->error . "<br>";
}

// Call the procedure
$sqlCall = "CALL InsertHourlyData();";
if ($conn->query($sqlCall) === TRUE) {
    echo "Procedure executed successfully.<br>";
} else {
    echo "Error calling procedure: " . $conn->error . "<br>";
}

// Close the connection
$conn->close();

?>


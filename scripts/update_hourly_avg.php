<?php

require 'db_connect.php';
require 'sensitive_data.php';

// Die in case of connection error
if (!$conn) {
    die("Database connection failed: " . $conn->connect_error);
}

$sql = "
INSERT INTO $hourlyTable (avg_temp, avg_hum, reading_time)
SELECT 
    AVG(temp) AS avg_temp,
    AVG(hum) AS avg_hum,
    -- Construct reading_time from date and hour for unique hourly entries
    TIMESTAMP(DATE(date), MAKETIME(HOUR(date), 0, 0)) AS reading_time
FROM 
    $bufferTable 
WHERE 
    date >= NOW() - INTERVAL 1 DAY  -- Last 24 hours
GROUP BY 
    DATE(date), HOUR(date)
ON DUPLICATE KEY UPDATE
    avg_temp = VALUES(avg_temp),
    avg_hum = VALUES(avg_hum),
    reading_time = VALUES(reading_time);  -- Updates the timestamp if an entry exists
";

if ($conn->query($sql) === TRUE) {
    echo "Hourly averages update success<br>";
} else {
    echo "Error: " . $conn->error;
}

$conn->close();

?>


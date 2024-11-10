<?php

require 'db_connect.php';
require 'sensitive_data.php';

// Die in case of connection error
if (!$conn) {
    die("Database connection failed: " . $conn->connect_error);
}

$sql = "
  INSERT INTO $hourlyTable (`date`, `hour`, avg_temp, avg_hum)
  SELECT
    DATE(date_of_creation) AS `date`,
    HOUR(date_of_creation) AS `hour`,
    AVG(temp) AS avg_temp,
    AVG(hum) AS avg_hum
  FROM $bufferTable
  WHERE date_of_creation >= NOW() - INTERVAL 1 DAY
  GROUP BY DATE(date_of_creation), HOUR(date_of_creation)
  ON DUPLICATE KEY UPDATE
    avg_temp = VALUES(avg_temp),
    avg_hum = VALUES(avg_hum);
";

if ($conn->query($sql) === TRUE) {
    echo "Hourly averages update success<br>";
} else {
    echo "Error: " . $conn->error;
}

$conn->close();

?>


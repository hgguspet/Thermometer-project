<?php

REQUIRE "db_connect.php";
REQUIRE 'sensitive_data.php';

// Die in case of connection error
if(!$conn) {
  die("Database connection failed " . $conn->connection_error);
}

// Get values from the URL
if (isset($_GET['temp'], $_GET['hum'], $_GET['key']) && is_numeric($_GET['temp']) && is_numeric($_GET['hum'])) {
    $temp = round((float)$_GET['temp'], 2);  // Ensure temp is a float with 2 decimal places
    $hum = round((float)$_GET['hum'], 2);    // Ensure hum is a float with 2 decimal places
    $key = $_GET['key'];
} else {
    echo "Temperature or humidity data not provided or non-numeric.";
    exit();
}

// Calculate the sum and format to two decimal places
$sum = round($temp + $hum, 2);
$message = number_format($sum, 2, '.', '');  // Format as float with 2 decimal places
// Generate the HMAC hash
$hash = hash_hmac('sha256', $message, $postpwd);

echo "hello world!";
// Check the provided key
if (hash_equals($hash, $key)) {
  echo "Authentic request<br>";
} else {
  die("Request unauthorized<br>");
}

// Insert into the buffer table
$sql = "INSERT INTO $bufferTable (temp, hum) VALUES (?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("dd", $temp, $hum);

if ($stmt->execute()) {
  echo "Upload success<br>";
} else {
  echo "Error: " . $stmt->error . "<br>";
}

$conn->close();
$stmt->close();
?>


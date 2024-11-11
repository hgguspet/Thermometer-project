<?php

REQUIRE "db_connect.php";
REQUIRE 'sensitive_data.php';






// die in case of connection error
if(!$conn) {
  die("Database connection failed " . $conn ->connection_error);
}



// Get values from the URL
if (isset($_GET['temp'], $_GET['hum'], $_GET['key']) && is_numeric($_GET['temp']) && is_numeric($_GET['hum'])) {
    $temp = $_GET['temp'];
    $hum = $_GET['hum'];
    $key = $_GET['key'];
} else {
    echo "Temperature or humidity data not provided or non-numeric.";
    exit();
}


$sum = $temp + $hum;
$message = mb_convert_encoding((string)$sum, 'UTF-8', 'auto');

$hash = hash_hmac('sha256', $message, $postpwd);


if (hash_equals($hash, $key)) {
  echo "Authentic request";
}
else {
  echo "Request unauthorized";
}



// update the bufferTable with the new data
$sql = "INSERT INTO $bufferTable (temp, hum) VALUES (?,?)";

$stmt = $conn->prepare($sql);

$stmt->bind_param("dd", $temp, $hum);

if($stmt->execute()) {
  echo "upload success<br>";
}
else {
  echo "Error " . $stmt->error . "<br>";
}

$conn->close();
$stmt->close();

?>


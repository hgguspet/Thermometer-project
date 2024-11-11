<?php
REQUIRE 'db_connect.php';

// Die in case of connection error
if (!$conn) {
    die("Database connection failed: " . $conn->connect_error);
}

$sql = "SELECT * FROM $bufferTable ORDERED BY date_of_creation DESC LIMIT 1;";

$result = $conn->query($sql);

$conn->close();
?>

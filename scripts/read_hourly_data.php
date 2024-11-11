<?php
REQUIRE "db_connect.php";
REQUIRE 'sensitive_data.php';


// Die in case of connection error
if (!$conn) {
    die("Database connection failed: " . $conn->connect_error);
}


$sql = "SELECT * FROM $hourlyTable ORDER BY reading_time DESC LIMIT 24"; 

$result = $conn->query($sql);


$data = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

}


// Close the connection
$conn->close();


echo json_encode(array_reverse($data))
?>


<?php
REQUIRE "db_connect.php";
REQUIRE 'sensitive_data.php';


// Die in case of connection error
if (!$conn) {
    die("Database connection failed: " . $conn->connect_error);
}

$sql = "SELECT * FROM $bufferTable ORDER BY date DESC LIMIT 15"; 

$result = $conn->query($sql);


$data = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

}

//reverse the arrray to make it go the correct way on the graph
$reversedData = array_reverse($data);


// Close the connection
$conn->close();


echo json_encode($reversedData)
?>


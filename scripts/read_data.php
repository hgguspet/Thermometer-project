<?php
REQUIRE "db_connect.php";
REQUIRE 'sensitive_data.php';
$read_ammout = 3;



$table = $bufferTable;
$sql = "SELECT * FROM $table ORDER BY date_of_creation DESC LIMIT 10"; 

$result = $conn->query($sql);


$data = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

}


// Close the connection
$conn->close();


echo json_encode($data)
?>


<?php

REQUIRE 'sensitive_data.php';


ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);



// Create connection
$conn = mysqli_connect($servername, $username, $mysqlpwd, $database);

// Check connection (disabled since the extra echos interfer with returning a json)
//if (!$conn) {
//    die("Connection failed: " . mysqli_connect_error() . "<br>");
//}
//echo "Connected successfully<br>";
?>

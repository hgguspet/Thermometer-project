<?php

REQUIRE "db_connect.php";

//read values from url
if (isset($_GET['temp']) && isset($_GET['hum'])) {
  echo "Read from URL: " . $_GET['temp'] . " " . $_GET['hum'] . "<br>";
  $temp = $_GET['temp'];
  $hum = $_GET['hum'];
} else {
  echo "Temperature or humidity data not provided.";
  exit();
}


$sql = "INSERT INTO readings (temp, hum) VALUES (?,?)";

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


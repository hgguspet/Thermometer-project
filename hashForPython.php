<?php
// fetch plain text key from the hash file
REQUIRE 'scripts/sensitive_data.php';

// Hash the key
//$hashedKey = password_hash($postpwd, PASSWORD_DEFAULT);

//echo the hash
echo $hashedPostpwd;
?>


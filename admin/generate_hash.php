<?php
$password = 'admin123'; // Change this to your desired password
$hash = password_hash($password, PASSWORD_DEFAULT);
echo "Password: $password<br>";
echo "Hash: $hash";
?>
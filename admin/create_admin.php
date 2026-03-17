<?php
require_once '../api/config/database.php';
$db = (new Database())->getConnection();

$username = 'kef';
$password = 'kef123';
$hash = password_hash($password, PASSWORD_DEFAULT);

$stmt = $db->prepare("INSERT INTO ugims_users (username, password_hash, full_name, email, role) VALUES (?, ?, ?, ?, ?)");
if ($stmt->execute([$username, $hash, 'Administrator', 'admin@example.com', 'admin'])) {
    echo "Admin user created successfully!";
} else {
    echo "Failed to create user.";
}
?>
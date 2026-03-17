<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

$user_id = $_GET['id'] ?? 0;
if ($user_id && $user_id != $_SESSION['user_id']) { // prevent self-deletion
    $stmt = $db->prepare("DELETE FROM ugims_users WHERE user_id = :id");
    $stmt->execute([':id' => $user_id]);
}

header('Location: users.php');
exit;
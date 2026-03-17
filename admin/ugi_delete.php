<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

$ugi_id = $_GET['id'] ?? 0;
if ($ugi_id) {
    $stmt = $db->prepare("DELETE FROM ugims_ugi WHERE ugi_id = :id");
    $stmt->execute([':id' => $ugi_id]);
}
header('Location: ugi_list.php');
exit;
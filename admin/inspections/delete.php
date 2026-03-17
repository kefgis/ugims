<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$inspection_id = $_GET['id'] ?? null;
if ($inspection_id) {
    // First delete associated findings
    $del = $db->prepare("DELETE FROM ugims_inspection_finding WHERE inspection_id = :id");
    $del->execute([':id' => $inspection_id]);
    
    $stmt = $db->prepare("DELETE FROM ugims_inspection WHERE inspection_id = :id");
    $stmt->execute([':id' => $inspection_id]);
}
header('Location: list.php');
exit;
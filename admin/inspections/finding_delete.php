<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$finding_id = $_GET['id'] ?? null;
$inspection_id = $_GET['inspection_id'] ?? null;
if ($finding_id) {
    $stmt = $db->prepare("DELETE FROM ugims_inspection_finding WHERE finding_id = :id");
    $stmt->execute([':id' => $finding_id]);
}
if ($inspection_id) {
    header('Location: findings.php?inspection_id=' . $inspection_id);
} else {
    header('Location: list.php');
}
exit;
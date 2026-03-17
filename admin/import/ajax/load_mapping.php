<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized']);
    exit;
}

require_once '../../../api/config/database.php';
$db = (new Database())->getConnection();

$mapping_id = $_GET['id'] ?? 0;

$stmt = $db->prepare("SELECT field_mapping FROM ugims_import_mapping WHERE mapping_id = ?");
$stmt->execute([$mapping_id]);
$mapping = $stmt->fetch();

if ($mapping) {
    echo json_encode([
        'success' => true,
        'mapping' => json_decode($mapping['field_mapping'], true)
    ]);
} else {
    echo json_encode(['success' => false, 'error' => 'Mapping not found']);
}
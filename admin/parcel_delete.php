<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

$parcel_id = $_GET['id'] ?? 0;
if ($parcel_id) {
    // Check if any UGI assets reference this parcel
    $check = $db->prepare("SELECT COUNT(*) FROM ugims_ugi WHERE parcel_id = :id");
    $check->execute([':id' => $parcel_id]);
    $count = $check->fetchColumn();
    if ($count > 0) {
        $_SESSION['error'] = "Cannot delete parcel: it has $count associated UGI assets.";
    } else {
        $stmt = $db->prepare("DELETE FROM ugims_parcel WHERE parcel_id = :id");
        $stmt->execute([':id' => $parcel_id]);
    }
}
header('Location: parcel_list.php');
exit;
<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$expense_id = $_GET['id'] ?? null;
if ($expense_id) {
    $stmt = $db->prepare("DELETE FROM ugims_expense WHERE expense_id = ?");
    $stmt->execute([$expense_id]);
}
header('Location: expenses.php');
exit;
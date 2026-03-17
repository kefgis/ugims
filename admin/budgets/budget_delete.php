<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$budget_id = $_GET['id'] ?? null;
if ($budget_id) {
    // Check if there are expenses linked to this budget
    $check = $db->prepare("SELECT COUNT(*) FROM ugims_expense WHERE budget_id = ?");
    $check->execute([$budget_id]);
    $count = $check->fetchColumn();
    
    if ($count > 0) {
        // Option A: Prevent deletion if expenses exist
        $_SESSION['error'] = "Cannot delete budget: it has $count expense records.";
        header('Location: index.php');
        exit;
        
        // Option B: If you want to cascade delete expenses, uncomment the next line:
        // $db->prepare("DELETE FROM ugims_expense WHERE budget_id = ?")->execute([$budget_id]);
    }
    
    $stmt = $db->prepare("DELETE FROM ugims_budget WHERE budget_id = ?");
    $stmt->execute([$budget_id]);
}
header('Location: index.php');
exit;
<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$plan_id = $_GET['id'] ?? null;
if ($plan_id) {
    // Optional: Check if there are any activities linked to this plan
    $check = $db->prepare("SELECT COUNT(*) FROM ugims_plan_activity WHERE plan_id = :id");
    $check->execute([':id' => $plan_id]);
    $count = $check->fetchColumn();
    if ($count > 0) {
        // If you want to prevent deletion when activities exist, uncomment the next lines
        // $_SESSION['error'] = "Cannot delete plan: it has $count associated activities.";
        // header('Location: plan_list.php');
        // exit;
        
        // Or, if you want to delete activities first (cascade), you'd need to handle that.
        // For simplicity, we'll just delete the plan (foreign key constraints may fail if activities exist)
        // Make sure your database cascades or you delete activities first.
        // To avoid errors, we'll delete activities first.
        $del = $db->prepare("DELETE FROM ugims_plan_activity WHERE plan_id = :id");
        $del->execute([':id' => $plan_id]);
    }
    
    $stmt = $db->prepare("DELETE FROM ugims_management_plan WHERE plan_id = :id");
    $stmt->execute([':id' => $plan_id]);
}

header('Location: plan_list.php');
exit;
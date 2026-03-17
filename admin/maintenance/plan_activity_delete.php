<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$activity_id = $_GET['id'] ?? null;
$plan_id = $_GET['plan_id'] ?? null; // optional, for redirect

if ($activity_id) {
    // Check if there are any executions for this activity
    $check = $db->prepare("SELECT COUNT(*) FROM ugims_activity_execution WHERE plan_activity_id = :id");
    $check->execute([':id' => $activity_id]);
    $count = $check->fetchColumn();
    if ($count > 0) {
        // Optionally delete executions first, or prevent deletion
        $del = $db->prepare("DELETE FROM ugims_activity_execution WHERE plan_activity_id = :id");
        $del->execute([':id' => $activity_id]);
    }
    
    $stmt = $db->prepare("DELETE FROM ugims_plan_activity WHERE plan_activity_id = :id");
    $stmt->execute([':id' => $activity_id]);
}

if ($plan_id) {
    header('Location: plan_activities.php?plan_id=' . $plan_id);
} else {
    header('Location: plan_list.php');
}
exit;
<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$plan_id = $_GET['plan_id'] ?? null;
if (!$plan_id) {
    header('Location: plan_list.php');
    exit;
}

// Fetch plan details
$stmt = $db->prepare("SELECT plan_name FROM ugims_management_plan WHERE plan_id = :id");
$stmt->execute([':id' => $plan_id]);
$plan = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$plan) {
    header('Location: plan_list.php');
    exit;
}

// Fetch activities for this plan
$stmt = $db->prepare("
    SELECT pa.*, at.activity_name, u.name as ugi_name, 
           ts.team_name, fs.status_name
    FROM ugims_plan_activity pa
    LEFT JOIN lkp_activity_type at ON pa.activity_type_id = at.activity_type_id
    LEFT JOIN ugims_ugi u ON pa.ugi_id = u.ugi_id
    LEFT JOIN ugims_team ts ON pa.assigned_team_id = ts.team_id
    LEFT JOIN lkp_activity_status fs ON pa.activity_status_id = fs.status_id
    WHERE pa.plan_id = :plan_id
    ORDER BY pa.scheduled_start_date
");
$stmt->execute([':plan_id' => $plan_id]);
$activities = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html>
<head>
    <title>Activities for <?= htmlspecialchars($plan['plan_name']) ?></title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Activities: <?= htmlspecialchars($plan['plan_name']) ?></h2>
        <div>
            <a href="plan_list.php">← Back to Plans</a>
        </div>
    </div>
    <div class="container">
        <a href="plan_activity_edit.php?plan_id=<?= $plan_id ?>" class="btn btn-add">➕ Add New Activity</a>

        <table>
            <thead>
                <tr>
                    <th>Activity</th>
                    <th>Type</th>
                    <th>UGI</th>
                    <th>Start</th>
                    <th>End</th>
                    <th>Est. Man-days</th>
                    <th>Team</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($activities)): ?>
                <tr>
                    <td colspan="9" style="text-align: center; padding: 30px;">
                        No activities have been added to this plan yet.<br>
                        <a href="plan_activity_edit.php?plan_id=<?= $plan_id ?>" style="color: #3498db; font-weight: bold;">Click here to add your first activity</a>.
                    </td>
                </tr>
                <?php else: ?>
                    <?php foreach ($activities as $a): ?>
                    <tr>
                        <td><?= htmlspecialchars($a['activity_name']) ?></td>
                        <td><?= htmlspecialchars($a['activity_name']) ?></td>
                        <td><?= htmlspecialchars($a['ugi_name']) ?></td>
                        <td><?= htmlspecialchars($a['scheduled_start_date']) ?></td>
                        <td><?= htmlspecialchars($a['scheduled_end_date']) ?></td>
                        <td><?= htmlspecialchars($a['estimated_man_days']) ?></td>
                        <td><?= htmlspecialchars($a['team_name']) ?></td>
                        <td><?= htmlspecialchars($a['status_name']) ?></td>
                        <td class="actions">
                            <a href="plan_activity_edit.php?id=<?= $a['plan_activity_id'] ?>" class="btn btn-small btn-edit">Edit</a>
                            <a href="activity_execute.php?activity_id=<?= $a['plan_activity_id'] ?>" class="btn btn-small">Log Execution</a>
                            <a href="plan_activity_delete.php?id=<?= $a['plan_activity_id'] ?>&plan_id=<?= $a['plan_id'] ?>" class="btn btn-small btn-delete" onclick="return confirm('Delete this activity?')">Delete</a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
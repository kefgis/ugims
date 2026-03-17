<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$inspection_id = $_GET['inspection_id'] ?? null;
if (!$inspection_id) {
    header('Location: list.php');
    exit;
}

// Fetch inspection details
$stmt = $db->prepare("SELECT inspection_number FROM ugims_inspection WHERE inspection_id = :id");
$stmt->execute([':id' => $inspection_id]);
$inspection = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$inspection) {
    header('Location: list.php');
    exit;
}

// Fetch findings
$stmt = $db->prepare("
    SELECT f.*, cs.status_name as condition_name, pri.priority_name
    FROM ugims_inspection_finding f
    LEFT JOIN lkp_condition_status cs ON f.condition_before_id = cs.status_id
    LEFT JOIN lkp_finding_priority pri ON f.finding_priority_id = pri.priority_id
    WHERE f.inspection_id = :id
    ORDER BY f.created_date
");
$stmt->execute([':id' => $inspection_id]);
$findings = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html>
<head>
    <title>Findings for Inspection <?= htmlspecialchars($inspection['inspection_number']) ?></title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Findings: <?= htmlspecialchars($inspection['inspection_number']) ?></h2>
        <div>
            <a href="list.php">← Back to Inspections</a>
        </div>
    </div>
    <div class="container">
        <a href="finding_edit.php?inspection_id=<?= $inspection_id ?>" class="btn btn-add">➕ Add Finding</a>

        <table>
            <thead>
                <tr>
                    <th>Description</th>
                    <th>Priority</th>
                    <th>Condition</th>
                    <th>Severity</th>
                    <th>Resolved</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($findings)): ?>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 30px;">
                        No findings recorded yet.<br>
                        <a href="finding_edit.php?inspection_id=<?= $inspection_id ?>">Add the first finding</a>.
                    </td>
                </tr>
                <?php else: ?>
                    <?php foreach ($findings as $f): ?>
                    <tr>
                        <td><?= htmlspecialchars(substr($f['finding_description'],0,50)) ?>...</td>
                        <td><?= htmlspecialchars($f['priority_name']) ?></td>
                        <td><?= htmlspecialchars($f['condition_name']) ?></td>
                        <td><?= $f['severity'] ?></td>
                        <td><?= $f['resolved'] ? 'Yes' : 'No' ?></td>
                        <td class="actions">
                            <a href="finding_edit.php?id=<?= $f['finding_id'] ?>" class="btn btn-small btn-edit">Edit</a>
                            <a href="finding_delete.php?id=<?= $f['finding_id'] ?>&inspection_id=<?= $inspection_id ?>" class="btn btn-small btn-delete" onclick="return confirm('Delete this finding?')">Delete</a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
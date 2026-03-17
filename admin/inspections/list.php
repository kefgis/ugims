<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

// Fetch inspections with related data
$query = "SELECT i.*, 
                 u.name as ugi_name,
                 it.inspection_name as type_name,
                 insp.first_name || ' ' || insp.last_name as inspector_name,
                 ist.status_name,
                 (SELECT COUNT(*) FROM ugims_inspection_finding WHERE inspection_id = i.inspection_id) as findings_count
          FROM ugims_inspection i
          LEFT JOIN ugims_ugi u ON i.ugi_id = u.ugi_id
          LEFT JOIN lkp_inspection_type it ON i.inspection_type_id = it.inspection_type_id
          LEFT JOIN ugims_workforce_user insp ON i.inspector_user_id = insp.user_id
          LEFT JOIN lkp_inspection_status ist ON i.inspection_status_id = ist.status_id
          ORDER BY i.scheduled_date DESC";
$inspections = $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html>
<head>
    <title>Inspections</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Inspections</h2>
        <div>
            <a href="../dashboard.php">Dashboard</a>
            <a href="../logout.php">Logout</a>
        </div>
    </div>
    <div class="container">
        <a href="edit.php" class="btn btn-add">➕ Schedule New Inspection</a>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>UGI</th>
                    <th>Type</th>
                    <th>Inspector</th>
                    <th>Scheduled</th>
                    <th>Completed</th>
                    <th>Status</th>
                    <th>Findings</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($inspections)): ?>
                <tr>
                    <td colspan="9" style="text-align: center; padding: 30px;">
                        No inspections scheduled.<br>
                        <a href="edit.php" style="color: #3498db;">Schedule your first inspection</a>.
                    </td>
                </tr>
                <?php else: ?>
                    <?php foreach ($inspections as $i): ?>
                    <tr>
                        <td><?= htmlspecialchars($i['inspection_number'] ?? substr($i['inspection_id'],0,8)) ?></td>
                        <td><?= htmlspecialchars($i['ugi_name']) ?></td>
                        <td><?= htmlspecialchars($i['type_name']) ?></td>
                        <td><?= htmlspecialchars($i['inspector_name']) ?></td>
                        <td><?= htmlspecialchars($i['scheduled_date']) ?></td>
                        <td><?= htmlspecialchars($i['completed_datetime'] ?? 'Pending') ?></td>
                        <td><?= htmlspecialchars($i['status_name']) ?></td>
                        <td><?= $i['findings_count'] ?></td>
                        <td class="actions">
                            <a href="edit.php?id=<?= $i['inspection_id'] ?>" class="btn btn-small btn-edit">Edit</a>
                            <a href="findings.php?inspection_id=<?= $i['inspection_id'] ?>" class="btn btn-small">Findings</a>
                            <a href="delete.php?id=<?= $i['inspection_id'] ?>" class="btn btn-small btn-delete" onclick="return confirm('Delete this inspection?')">Delete</a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
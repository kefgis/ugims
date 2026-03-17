<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$imports = $db->query("
    SELECT l.*, u.username 
    FROM ugims_import_log l
    LEFT JOIN ugims_users u ON l.imported_by_user_id = u.user_id
    ORDER BY l.import_date DESC
    LIMIT 50
")->fetchAll();
?>
<!DOCTYPE html>
<html>
<head>
    <title>Import History</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Import History</h2>
        <div>
            <a href="../dashboard.php">Dashboard</a>
        </div>
    </div>
    <div class="container">
        <table>
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Type</th>
                    <th>Filename</th>
                    <th>Records</th>
                    <th>Success</th>
                    <th>Failed</th>
                    <th>Imported By</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($imports as $imp): ?>
                <tr>
                    <td><?= $imp['import_date'] ?></td>
                    <td><?= ucfirst($imp['import_type']) ?></td>
                    <td><?= htmlspecialchars($imp['filename']) ?></td>
                    <td><?= $imp['records_processed'] ?></td>
                    <td><?= $imp['records_success'] ?></td>
                    <td><?= $imp['records_failed'] ?></td>
                    <td><?= htmlspecialchars($imp['username']) ?></td>
                    <td><?= ucfirst($imp['status']) ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
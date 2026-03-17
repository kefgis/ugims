<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

// Fetch all UGI assets with type and condition names
$query = "SELECT u.ugi_id, u.name, u.amharic_name, t.type_name, 
                 c.status_name as condition_name, 
                 ST_Area(u.geometry) as area_sq_m,
                 u.last_updated
          FROM ugims_ugi u
          LEFT JOIN lkp_ethiopia_ugi_type t ON u.ugi_type_id = t.ugi_type_id
          LEFT JOIN lkp_condition_status c ON u.condition_status_id = c.status_id
          ORDER BY u.name";
$assets = $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html>
<head>
    <title>UGI Assets</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <style>
        .actions { white-space: nowrap; }
        .btn-small { padding: 4px 8px; font-size: 0.9rem; margin-right: 4px; }
    </style>
</head>
<body>
    <div class="header">
        <h2>UGI Asset Management</h2>
        <div>
            <span>Welcome, <?= htmlspecialchars($_SESSION['username']) ?></span>
            <a href="dashboard.php">Dashboard</a>
            <a href="logout.php">Logout</a>
        </div>
    </div>
    <div class="container">
        <a href="ugi_edit.php" class="btn btn-add">➕ Add New UGI Asset</a>
        
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Amharic Name</th>
                    <th>Type</th>
                    <th>Condition</th>
                    <th>Area (m²)</th>
                    <th>Last Updated</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($assets as $a): ?>
                <tr>
                    <td><?= htmlspecialchars($a['name']) ?></td>
                    <td><?= htmlspecialchars($a['amharic_name']) ?></td>
                    <td><?= htmlspecialchars($a['type_name']) ?></td>
                    <td><?= htmlspecialchars($a['condition_name']) ?></td>
                    <td><?= number_format($a['area_sq_m'], 2) ?></td>
                    <td><?= htmlspecialchars($a['last_updated']) ?></td>
                    <td class="actions">
                        <a href="ugi_edit.php?id=<?= $a['ugi_id'] ?>" class="btn btn-small btn-edit">Edit</a>
                        <a href="ugi_delete.php?id=<?= $a['ugi_id'] ?>" class="btn btn-small btn-delete" onclick="return confirm('Delete this asset?')">Delete</a>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
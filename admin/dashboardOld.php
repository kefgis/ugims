<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

// Get counts for dashboard widgets
$reports_count = $db->query("SELECT COUNT(*) FROM ugims_citizen_report")->fetchColumn();
$pending_reports = $db->query("SELECT COUNT(*) FROM ugims_citizen_report WHERE status_id = 1")->fetchColumn();
$ugi_count = $db->query("SELECT COUNT(*) FROM ugims_ugi")->fetchColumn();
?>
<!DOCTYPE html>
<html>
<head>
    <title>UGIMS Dashboard</title>
    <link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>UGIMS Admin Panel</h2>
        <div>
            <span>Welcome, <?= htmlspecialchars($_SESSION['username']) ?></span>
            <a href="logout.php">Logout</a>
        </div>
    </div>
    <div class="container">
        <div class="cards">
            <div class="card">
                <h3>Total UGI Assets</h3>
                <div class="number"><?= $ugi_count ?></div>
            </div>
            <div class="card">
                <h3>Citizen Reports</h3>
                <div class="number"><?= $reports_count ?></div>
            </div>
            <div class="card">
                <h3>Pending Reports</h3>
                <div class="number"><?= $pending_reports ?></div>
            </div>
        </div>

        <div class="nav-links">
            <a href="reports.php">Manage Citizen Reports</a>
            <a href="parcel_list.php">Manage Parcels</a>
            <a href="ugi_list.php">Manage UGI Assets</a>
            <a href="maintenance/plan_list.php">Maintenance Plans</a>
            <a href="inspections/list.php">Inspections</a>
            <a href="budgets/index.php">Budgets & Expenses</a>
            <a href="reports/index.php">Reports</a>
            <a href="calendar.php">Maintenance Calendar</a>
            <a href="import/shapefile_upload.php?type=parcel">Import Parcels (PHP)</a>
            <a href="import/shapefile_upload.php?type=ugi">Import UGI Assets (PHP)</a>
            <a href="import/shapefile_cli_import.php">Import via Command Line</a>
            <a href="import/import_history.php">Import History</a>
            <a href="export/index.php">📤 Export Spatial Data</a>
            <?php if ($_SESSION['role'] === 'admin'): ?>
                <a href="users.php">Manage Users</a>
            <?php endif; ?>
        </div>
    </div>
</body>
</html>
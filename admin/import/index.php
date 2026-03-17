<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

// Get recent imports
$recent_imports = $db->query("
    SELECT l.*, u.username 
    FROM ugims_import_log l
    LEFT JOIN ugims_users u ON l.imported_by_user_id = u.user_id
    ORDER BY l.import_date DESC
    LIMIT 5
")->fetchAll();

// Get saved mappings
$mappings = $db->query("
    SELECT mapping_id, mapping_name, import_type 
    FROM ugims_import_mapping 
    ORDER BY is_default DESC, created_date DESC
")->fetchAll();
?>
<!DOCTYPE html>
<html>
<head>
    <title>Import/Export Dashboard</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
    <style>
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .dashboard-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .dashboard-card h3 {
            margin-top: 0;
            color: #2c3e50;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 10px;
        }
        .quick-actions {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .quick-actions a {
            display: block;
            padding: 10px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            text-align: center;
        }
        .quick-actions a:hover {
            background: #2980b9;
        }
        .mapping-list {
            list-style: none;
            padding: 0;
        }
        .mapping-list li {
            padding: 8px;
            background: #f8f9fa;
            margin-bottom: 5px;
            border-radius: 4px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .badge {
            background: #2ecc71;
            color: white;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8rem;
        }
    </style>
</head>
<body>
    <div class="header">
        <h2>Import/Export Dashboard</h2>
        <div>
            <a href="../dashboard.php">Main Dashboard</a>
            <a href="../logout.php">Logout</a>
        </div>
    </div>
    <div class="container">
        <div class="dashboard-grid">
            <!-- Quick Import Card -->
            <div class="dashboard-card">
                <h3>📤 Quick Import</h3>
                <div class="quick-actions">
                    <a href="field_mapping.php?type=parcel">Import Parcels</a>
                    <a href="field_mapping.php?type=ugi">Import UGI Assets</a>
                </div>
            </div>

            <!-- Export Templates Card -->
            <div class="dashboard-card">
                <h3>📥 Export Templates</h3>
                <div class="quick-actions">
                    <a href="export_template.php?type=parcel" target="_blank">Download Parcel Template</a>
                    <a href="export_template.php?type=ugi" target="_blank">Download UGI Template</a>
                </div>
                <p style="margin-top: 10px; font-size: 0.9rem; color: #7f8c8d;">
                    Download empty shapefiles with correct field structure
                </p>
            </div>

            <!-- Saved Mappings Card -->
            <div class="dashboard-card">
                <h3>📋 Saved Mappings</h3>
                <ul class="mapping-list">
                    <?php foreach ($mappings as $m): ?>
                    <li>
                        <span>
                            <?= htmlspecialchars($m['mapping_name']) ?>
                            (<?= ucfirst($m['import_type']) ?>)
                            <?php if ($m['is_default']): ?>
                                <span class="badge">Default</span>
                            <?php endif; ?>
                        </span>
                        <div>
                            <a href="field_mapping.php?mapping=<?= $m['mapping_id'] ?>" class="btn-small">Use</a>
                        </div>
                    </li>
                    <?php endforeach; ?>
                </ul>
                <a href="field_mapping.php?action=manage_mappings" style="display: block; text-align: center; margin-top: 10px;">Manage Mappings</a>
            </div>

            <!-- Recent Imports Card -->
            <div class="dashboard-card">
                <h3>🕒 Recent Imports</h3>
                <table style="width: 100%; font-size: 0.9rem;">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Type</th>
                            <th>Records</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($recent_imports as $imp): ?>
                        <tr>
                            <td><?= date('m/d H:i', strtotime($imp['import_date'])) ?></td>
                            <td><?= ucfirst($imp['import_type']) ?></td>
                            <td><?= $imp['records_success'] ?>/<?= $imp['records_processed'] ?></td>
                            <td>
                                <span style="color: <?= $imp['status'] == 'completed' ? '#2ecc71' : '#e74c3c' ?>">
                                    <?= ucfirst($imp['status']) ?>
                                </span>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
                <a href="import_history.php" style="display: block; text-align: center; margin-top: 10px;">View All</a>
            </div>
        </div>
    </div>
</body>
</html>
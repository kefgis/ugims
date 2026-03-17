<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

// Handle status update
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_status'])) {
    $report_id = $_POST['report_id'];
    $new_status = $_POST['status_id'];
    $stmt = $db->prepare("UPDATE ugims_citizen_report SET status_id = :status WHERE report_id = :id");
    $stmt->execute([':status' => $new_status, ':id' => $report_id]);
    $message = "Report updated.";
}

// Fetch reports with type and status names
$query = "SELECT r.*, rt.report_type_name, rs.status_name 
          FROM ugims_citizen_report r
          LEFT JOIN lkp_citizen_report_type rt ON r.report_type_id = rt.report_type_id
          LEFT JOIN lkp_citizen_report_status rs ON r.status_id = rs.status_id
          ORDER BY r.created_date DESC";
$reports = $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Citizen Reports</title>
    <style>
        body { font-family: Arial; margin: 0; background: #f4f6f9; }
        .header { background: #2c3e50; color: white; padding: 15px; }
        .container { padding: 20px; }
        table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f8f9fa; }
        .status-select { padding: 5px; }
        .btn-update { background: #3498db; color: white; border: none; padding: 5px 10px; cursor: pointer; border-radius: 3px; }
        .message { background: #d4edda; color: #155724; padding: 10px; margin-bottom: 20px; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="header">
        <h2>UGIMS – Citizen Reports</h2>
        <a href="dashboard.php" style="color:white;">← Back to Dashboard</a>
    </div>
    <div class="container">
        <?php if (isset($message)): ?><div class="message"><?= $message ?></div><?php endif; ?>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Date</th>
                    <th>Type</th>
                    <th>Description</th>
                    <th>Location</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($reports as $report): ?>
                <tr>
                    <td><?= htmlspecialchars($report['report_number']) ?></td>
                    <td><?= htmlspecialchars($report['created_date']) ?></td>
                    <td><?= htmlspecialchars($report['report_type_name']) ?></td>
                    <td><?= htmlspecialchars(substr($report['report_description'], 0, 50)) ?>...</td>
                    <td>
                        <?php
                        // You can add a link to view on map using ST_AsText(location_point) if needed
                        echo "Lat/Lng present";
                        ?>
                    </td>
                    <td><?= htmlspecialchars($report['status_name']) ?></td>
                    <td>
                        <form method="post" style="display:inline;">
                            <input type="hidden" name="report_id" value="<?= $report['report_id'] ?>">
                            <select name="status_id" class="status-select">
                                <?php
                                // Fetch all statuses for dropdown
                                $statuses = $db->query("SELECT status_id, status_name FROM lkp_citizen_report_status")->fetchAll();
                                foreach ($statuses as $s) {
                                    $selected = ($s['status_id'] == $report['status_id']) ? 'selected' : '';
                                    echo "<option value='{$s['status_id']}' $selected>{$s['status_name']}</option>";
                                }
                                ?>
                            </select>
                            <button type="submit" name="update_status" class="btn-update">Update</button>
                        </form>
                        <a href="report_detail.php?id=<?= $report['report_id'] ?>">View</a>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

// Fetch fiscal years for filter
$fiscal_years = $db->query("SELECT fiscal_year_id, fiscal_year_name FROM lkp_fiscal_year ORDER BY start_date DESC")->fetchAll();

$where = [];
$params = [];

// Filter by fiscal year
if (isset($_GET['fiscal_year']) && $_GET['fiscal_year'] != '') {
    $where[] = "p.fiscal_year_id = :fiscal_year";
    $params[':fiscal_year'] = $_GET['fiscal_year'];
}

// Build query
$sql = "SELECT p.*, fy.fiscal_year_name, pt.plan_type_name
        FROM ugims_management_plan p
        LEFT JOIN lkp_fiscal_year fy ON p.fiscal_year_id = fy.fiscal_year_id
        LEFT JOIN lkp_plan_type pt ON p.plan_type_id = pt.plan_type_id";
if (!empty($where)) {
    $sql .= " WHERE " . implode(' AND ', $where);
}
$sql .= " ORDER BY p.created_date DESC";

$stmt = $db->prepare($sql);
$stmt->execute($params);
$plans = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html>
<head>
    <title>Maintenance Plans</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Maintenance Plans</h2>
        <div>
            <a href="../dashboard.php">Dashboard</a>
            <a href="../logout.php">Logout</a>
        </div>
    </div>
    <div class="container">
        <a href="plan_edit.php" class="btn btn-add">➕ Create New Plan</a>

        <form method="get" style="margin: 20px 0;">
            <label>Filter by Fiscal Year:</label>
            <select name="fiscal_year">
                <option value="">All</option>
                <?php foreach ($fiscal_years as $fy): ?>
                <option value="<?= $fy['fiscal_year_id'] ?>" <?= (isset($_GET['fiscal_year']) && $_GET['fiscal_year'] == $fy['fiscal_year_id']) ? 'selected' : '' ?>>
                    <?= htmlspecialchars($fy['fiscal_year_name']) ?>
                </option>
                <?php endforeach; ?>
            </select>
            <button type="submit" class="btn">Filter</button>
        </form>

        <table>
            <thead>
                <tr>
                    <th>Plan Name</th>
                    <th>Type</th>
                    <th>Fiscal Year</th>
                    <th>Start Date</th>
                    <th>End Date</th>
                    <th>Budget</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($plans as $plan): ?>
                <tr>
                    <td><?= htmlspecialchars($plan['plan_name']) ?></td>
                    <td><?= htmlspecialchars($plan['plan_type_name']) ?></td>
                    <td><?= htmlspecialchars($plan['fiscal_year_name']) ?></td>
                    <td><?= htmlspecialchars($plan['planned_start_date']) ?></td>
                    <td><?= htmlspecialchars($plan['planned_end_date']) ?></td>
                    <td><?= number_format($plan['total_budget_allocated'], 2) ?></td>
                    <td><?= htmlspecialchars($plan['plan_status_id']) ?></td>
                    <td class="actions">
                        <a href="plan_edit.php?id=<?= $plan['plan_id'] ?>" class="btn btn-small btn-edit">Edit</a>
                        <a href="plan_activities.php?plan_id=<?= $plan['plan_id'] ?>" class="btn btn-small">Activities</a>
                        <a href="plan_delete.php?id=<?= $plan['plan_id'] ?>" class="btn btn-small btn-delete" onclick="return confirm('Delete this plan?')">Delete</a>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
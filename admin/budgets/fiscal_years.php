<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

// Handle add/edit/delete
$message = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['add'])) {
        $name = $_POST['fiscal_year_name'];
        $start = $_POST['start_date'];
        $end = $_POST['end_date'];
        $is_current = isset($_POST['is_current']) ? 'true' : 'false';
        $stmt = $db->prepare("INSERT INTO lkp_fiscal_year (fiscal_year_name, start_date, end_date, is_current) VALUES (?, ?, ?, ?)");
        $stmt->execute([$name, $start, $end, $is_current]);
        $message = 'Fiscal year added.';
    } elseif (isset($_POST['update'])) {
        $id = $_POST['fiscal_year_id'];
        $name = $_POST['fiscal_year_name'];
        $start = $_POST['start_date'];
        $end = $_POST['end_date'];
        $is_current = isset($_POST['is_current']) ? 'true' : 'false';
        $stmt = $db->prepare("UPDATE lkp_fiscal_year SET fiscal_year_name=?, start_date=?, end_date=?, is_current=? WHERE fiscal_year_id=?");
        $stmt->execute([$name, $start, $end, $is_current, $id]);
        $message = 'Fiscal year updated.';
    } elseif (isset($_GET['delete'])) {
        $id = $_GET['delete'];
        $stmt = $db->prepare("DELETE FROM lkp_fiscal_year WHERE fiscal_year_id=?");
        $stmt->execute([$id]);
        $message = 'Fiscal year deleted.';
        header('Location: fiscal_years.php');
        exit;
    }
}

$fiscal_years = $db->query("SELECT * FROM lkp_fiscal_year ORDER BY start_date DESC")->fetchAll();
?>
<!DOCTYPE html>
<html>
<head>
    <title>Fiscal Years</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Fiscal Years</h2>
        <div>
            <a href="index.php">Budgets Dashboard</a>
            <a href="../dashboard.php">Main Dashboard</a>
            <a href="../logout.php">Logout</a>
        </div>
    </div>
    <div class="container">
        <?php if ($message): ?><div class="message"><?= $message ?></div><?php endif; ?>

        <h3>Add New Fiscal Year</h3>
        <form method="post" style="margin-bottom:30px;">
            <div class="form-row">
                <div class="form-col">
                    <input type="text" name="fiscal_year_name" placeholder="e.g., 2024-2025" required>
                </div>
                <div class="form-col">
                    <input type="date" name="start_date" required>
                </div>
                <div class="form-col">
                    <input type="date" name="end_date" required>
                </div>
                <div class="form-col">
                    <label><input type="checkbox" name="is_current"> Set as current</label>
                </div>
                <div class="form-col">
                    <button type="submit" name="add">Add</button>
                </div>
            </div>
        </form>

        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Start</th>
                    <th>End</th>
                    <th>Current</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($fiscal_years as $fy): ?>
                <tr>
                    <td><?= htmlspecialchars($fy['fiscal_year_name']) ?></td>
                    <td><?= $fy['start_date'] ?></td>
                    <td><?= $fy['end_date'] ?></td>
                    <td><?= $fy['is_current'] ? 'Yes' : 'No' ?></td>
                    <td class="actions">
                        <a href="fiscal_year_edit.php?id=<?= $fy['fiscal_year_id'] ?>" class="btn btn-small btn-edit">Edit</a>
                        <a href="fiscal_years.php?delete=<?= $fy['fiscal_year_id'] ?>" class="btn btn-small btn-delete" onclick="return confirm('Delete?')">Delete</a>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
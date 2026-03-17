<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

// Fetch budgets with fiscal year and totals
$budgets = $db->query("
    SELECT b.*, fy.fiscal_year_name,
           COALESCE((SELECT SUM(amount) FROM ugims_expense WHERE budget_id = b.budget_id), 0) as spent
    FROM ugims_budget b
    LEFT JOIN lkp_fiscal_year fy ON b.fiscal_year_id = fy.fiscal_year_id
    ORDER BY b.created_date DESC
")->fetchAll();
?>
<!DOCTYPE html>
<html>
<head>
    <title>Budgets</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Budgets</h2>
        <div>
            <a href="fiscal_years.php">Fiscal Years</a>
            <a href="expenses.php">Expenses</a>
            <a href="requisitions.php">Requisitions</a>
            <a href="../dashboard.php">Dashboard</a>
        </div>
    </div>
    <div class="container">
        <a href="budget_edit.php" class="btn btn-add">➕ Create New Budget</a>
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Fiscal Year</th>
                    <th>Allocated</th>
                    <th>Spent</th>
                    <th>Remaining</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($budgets as $b): 
                    $remaining = $b['allocated_amount'] - $b['spent'];
                ?>
                <tr>
                    <td><?= htmlspecialchars($b['budget_name']) ?></td>
                    <td><?= htmlspecialchars($b['fiscal_year_name']) ?></td>
                    <td><?= number_format($b['allocated_amount'], 2) ?></td>
                    <td><?= number_format($b['spent'], 2) ?></td>
                    <td><?= number_format($remaining, 2) ?></td>
                    <td><?= htmlspecialchars($b['budget_status']) ?></td>
                    <td class="actions">
                        <a href="budget_edit.php?id=<?= $b['budget_id'] ?>" class="btn btn-small btn-edit">Edit</a>
                        <a href="expenses.php?budget_id=<?= $b['budget_id'] ?>" class="btn btn-small">Expenses</a>
                        <a href="budget_delete.php?id=<?= $b['budget_id'] ?>" class="btn btn-small btn-delete" onclick="return confirm('Delete budget?')">Delete</a>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
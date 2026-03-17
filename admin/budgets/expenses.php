<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$budget_id = $_GET['budget_id'] ?? null;

$sql = "SELECT e.*, b.budget_name, u.name as ugi_name, a.activity_name
        FROM ugims_expense e
        LEFT JOIN ugims_budget b ON e.budget_id = b.budget_id
        LEFT JOIN ugims_ugi u ON e.ugi_id = u.ugi_id
        LEFT JOIN lkp_activity_type a ON e.expense_type::integer = a.activity_type_id";
$params = [];
if ($budget_id) {
    $sql .= " WHERE e.budget_id = ?";
    $params[] = $budget_id;
}
$sql .= " ORDER BY e.expense_date DESC";
$stmt = $db->prepare($sql);
$stmt->execute($params);
$expenses = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html>
<head>
    <title>Expenses</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Expenses</h2>
        <div>
            <a href="index.php">Budgets</a>
            <a href="expense_edit.php" class="btn">Add Expense</a>
        </div>
    </div>
    <div class="container">
        <table>
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Budget</th>
                    <th>Description</th>
                    <th>Amount</th>
                    <th>UGI</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($expenses as $e): ?>
                <tr>
                    <td><?= $e['expense_date'] ?></td>
                    <td><?= htmlspecialchars($e['budget_name']) ?></td>
                    <td><?= htmlspecialchars($e['description']) ?></td>
                    <td><?= number_format($e['amount'], 2) ?></td>
                    <td><?= htmlspecialchars($e['ugi_name']) ?></td>
                    <td class="actions">
                        <a href="expense_edit.php?id=<?= $e['expense_id'] ?>" class="btn btn-small btn-edit">Edit</a>
                        <a href="expense_delete.php?id=<?= $e['expense_id'] ?>" class="btn btn-small btn-delete" onclick="return confirm('Delete?')">Delete</a>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$expense_id = $_GET['id'] ?? null;
$expense = null;
if ($expense_id) {
    $stmt = $db->prepare("SELECT * FROM ugims_expense WHERE expense_id = ?");
    $stmt->execute([$expense_id]);
    $expense = $stmt->fetch(PDO::FETCH_ASSOC);
}

// Fetch budgets, UGIs, activity types
$budgets = $db->query("SELECT budget_id, budget_name FROM ugims_budget ORDER BY budget_name")->fetchAll();
$ugis = $db->query("SELECT ugi_id, name FROM ugims_ugi ORDER BY name")->fetchAll();
$activity_types = $db->query("SELECT activity_type_id, activity_name FROM lkp_activity_type ORDER BY activity_name")->fetchAll();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $budget_id = $_POST['budget_id'];
    $expense_date = $_POST['expense_date'];
    $description = $_POST['description'];
    $amount = $_POST['amount'];
    $ugi_id = $_POST['ugi_id'] ?: null;
    $activity_type_id = $_POST['activity_type_id'] ?: null;
    $vendor_name = $_POST['vendor_name'];

    if (empty($budget_id) || empty($expense_date) || empty($description) || empty($amount)) {
        $error = 'Budget, date, description, and amount are required.';
    } else {
        if ($expense_id) {
            $stmt = $db->prepare("UPDATE ugims_expense SET budget_id=?, expense_date=?, description=?, amount=?, ugi_id=?, expense_type=?, vendor_name=?, last_updated=NOW() WHERE expense_id=?");
            $stmt->execute([$budget_id, $expense_date, $description, $amount, $ugi_id, $activity_type_id, $vendor_name, $expense_id]);
            $message = 'Expense updated.';
        } else {
            $stmt = $db->prepare("INSERT INTO ugims_expense (budget_id, expense_date, description, amount, ugi_id, expense_type, vendor_name, created_date) VALUES (?, ?, ?, ?, ?, ?, ?, NOW()) RETURNING expense_id");
            $stmt->execute([$budget_id, $expense_date, $description, $amount, $ugi_id, $activity_type_id, $vendor_name]);
            $new_id = $stmt->fetchColumn();
            header('Location: expenses.php');
            exit;
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title><?= $expense_id ? 'Edit' : 'Add' ?> Expense</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2><?= $expense_id ? 'Edit' : 'Add' ?> Expense</h2>
        <div><a href="expenses.php">← Back to Expenses</a></div>
    </div>
    <div class="container">
        <?php if (isset($message)): ?><div class="message"><?= $message ?></div><?php endif; ?>
        <?php if (isset($error)): ?><div class="error"><?= $error ?></div><?php endif; ?>
        <form method="post">
            <div class="form-group">
                <label>Budget</label>
                <select name="budget_id" required>
                    <option value="">-- Select --</option>
                    <?php foreach ($budgets as $b): ?>
                    <option value="<?= $b['budget_id'] ?>" <?= (($expense['budget_id'] ?? '') == $b['budget_id']) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($b['budget_name']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Expense Date</label>
                <input type="date" name="expense_date" value="<?= htmlspecialchars($expense['expense_date'] ?? date('Y-m-d')) ?>" required>
            </div>
            <div class="form-group">
                <label>Description</label>
                <input type="text" name="description" value="<?= htmlspecialchars($expense['description'] ?? '') ?>" required>
            </div>
            <div class="form-group">
                <label>Amount</label>
                <input type="number" step="0.01" name="amount" value="<?= htmlspecialchars($expense['amount'] ?? '0') ?>" required>
            </div>
            <div class="form-group">
                <label>UGI (optional)</label>
                <select name="ugi_id">
                    <option value="">-- None --</option>
                    <?php foreach ($ugis as $u): ?>
                    <option value="<?= $u['ugi_id'] ?>" <?= (($expense['ugi_id'] ?? '') == $u['ugi_id']) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($u['name']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Activity Type (optional)</label>
                <select name="activity_type_id">
                    <option value="">-- None --</option>
                    <?php foreach ($activity_types as $at): ?>
                    <option value="<?= $at['activity_type_id'] ?>" <?= (($expense['expense_type'] ?? '') == $at['activity_type_id']) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($at['activity_name']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Vendor</label>
                <input type="text" name="vendor_name" value="<?= htmlspecialchars($expense['vendor_name'] ?? '') ?>">
            </div>
            <button type="submit">Save Expense</button>
        </form>
    </div>
</body>
</html>
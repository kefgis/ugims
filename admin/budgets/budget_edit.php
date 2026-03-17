<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$budget_id = $_GET['id'] ?? null;
$budget = null;

if ($budget_id) {
    $stmt = $db->prepare("SELECT * FROM ugims_budget WHERE budget_id = ?");
    $stmt->execute([$budget_id]);
    $budget = $stmt->fetch(PDO::FETCH_ASSOC);
}

// Fetch lookup data
$fiscal_years = $db->query("SELECT fiscal_year_id, fiscal_year_name FROM lkp_fiscal_year ORDER BY start_date DESC")->fetchAll();
$budget_sources = $db->query("SELECT source_id, source_name FROM lkp_budget_source ORDER BY source_name")->fetchAll();

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $budget_name = $_POST['budget_name'];
    $fiscal_year_id = $_POST['fiscal_year_id'];
    $budget_type = $_POST['budget_type'];
    $budget_source_id = $_POST['budget_source_id'];
    $allocated_amount = $_POST['allocated_amount'];
    $budget_status = $_POST['budget_status'];
    $notes = $_POST['notes'];

    if (empty($budget_name) || empty($fiscal_year_id) || empty($allocated_amount)) {
        $error = 'Name, fiscal year, and allocated amount are required.';
    } else {
        if ($budget_id) {
            // Update
            $stmt = $db->prepare("UPDATE ugims_budget SET budget_name=?, fiscal_year_id=?, budget_type=?, budget_source_id=?, allocated_amount=?, budget_status=?, notes=?, last_updated=NOW() WHERE budget_id=?");
            $stmt->execute([$budget_name, $fiscal_year_id, $budget_type, $budget_source_id, $allocated_amount, $budget_status, $notes, $budget_id]);
            $message = 'Budget updated.';
        } else {
            // Insert
            $stmt = $db->prepare("INSERT INTO ugims_budget (budget_name, fiscal_year_id, budget_type, budget_source_id, allocated_amount, budget_status, notes, created_date, last_updated) VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW()) RETURNING budget_id");
            $stmt->execute([$budget_name, $fiscal_year_id, $budget_type, $budget_source_id, $allocated_amount, $budget_status, $notes]);
            $new_id = $stmt->fetchColumn();
            header('Location: budget_edit.php?id=' . $new_id);
            exit;
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title><?= $budget_id ? 'Edit' : 'Create' ?> Budget</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2><?= $budget_id ? 'Edit' : 'Create' ?> Budget</h2>
        <div><a href="index.php">← Back to Budgets</a></div>
    </div>
    <div class="container">
        <?php if ($message): ?><div class="message"><?= $message ?></div><?php endif; ?>
        <?php if ($error): ?><div class="error"><?= $error ?></div><?php endif; ?>
        <form method="post">
            <div class="form-group">
                <label>Budget Name</label>
                <input type="text" name="budget_name" value="<?= htmlspecialchars($budget['budget_name'] ?? '') ?>" required>
            </div>
            <div class="form-group">
                <label>Fiscal Year</label>
                <select name="fiscal_year_id" required>
                    <option value="">-- Select --</option>
                    <?php foreach ($fiscal_years as $fy): ?>
                    <option value="<?= $fy['fiscal_year_id'] ?>" <?= (($budget['fiscal_year_id'] ?? '') == $fy['fiscal_year_id']) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($fy['fiscal_year_name']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Budget Type</label>
                <input type="text" name="budget_type" value="<?= htmlspecialchars($budget['budget_type'] ?? 'Operational') ?>">
            </div>
            <div class="form-group">
                <label>Source</label>
                <select name="budget_source_id">
                    <option value="">-- Select --</option>
                    <?php foreach ($budget_sources as $bs): ?>
                    <option value="<?= $bs['source_id'] ?>" <?= (($budget['budget_source_id'] ?? '') == $bs['source_id']) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($bs['source_name']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Allocated Amount</label>
                <input type="number" step="0.01" name="allocated_amount" value="<?= htmlspecialchars($budget['allocated_amount'] ?? '0') ?>" required>
            </div>
            <div class="form-group">
                <label>Status</label>
                <input type="text" name="budget_status" value="<?= htmlspecialchars($budget['budget_status'] ?? 'Draft') ?>">
            </div>
            <div class="form-group">
                <label>Notes</label>
                <textarea name="notes" rows="3"><?= htmlspecialchars($budget['notes'] ?? '') ?></textarea>
            </div>
            <button type="submit">Save Budget</button>
        </form>
    </div>
</body>
</html>
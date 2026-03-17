<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$plan_id = $_GET['id'] ?? null;
$plan = null;

if ($plan_id) {
    $stmt = $db->prepare("SELECT * FROM ugims_management_plan WHERE plan_id = :id");
    $stmt->execute([':id' => $plan_id]);
    $plan = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$plan) {
        header('Location: plan_list.php');
        exit;
    }
}

// Fetch lookup data
$plan_types = $db->query("SELECT plan_type_id, plan_type_name FROM lkp_plan_type ORDER BY plan_type_name")->fetchAll();
$fiscal_years = $db->query("SELECT fiscal_year_id, fiscal_year_name FROM lkp_fiscal_year ORDER BY start_date DESC")->fetchAll();
$plan_statuses = $db->query("SELECT status_id, status_name FROM lkp_plan_status ORDER BY status_id")->fetchAll();

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $plan_name = $_POST['plan_name'] ?? '';
    $plan_type_id = $_POST['plan_type_id'] ?? null;
    $fiscal_year_id = $_POST['fiscal_year_id'] ?? null;
    $scope_type = $_POST['scope_type'] ?? '';
    $planned_start_date = $_POST['planned_start_date'] ?? null;
    $planned_end_date = $_POST['planned_end_date'] ?? null;
    $total_budget_allocated = $_POST['total_budget_allocated'] ?? 0;
    $plan_status_id = $_POST['plan_status_id'] ?? null;
    $goals = $_POST['goals_and_objectives'] ?? '';

    if (empty($plan_name)) {
        $error = 'Plan name is required.';
    } else {
        if ($plan_id) {
            // Update
            $sql = "UPDATE ugims_management_plan SET
                    plan_name = :name,
                    plan_type_id = :type_id,
                    fiscal_year_id = :fiscal_year,
                    scope_type = :scope,
                    planned_start_date = :start,
                    planned_end_date = :end,
                    total_budget_allocated = :budget,
                    plan_status_id = :status,
                    goals_and_objectives = :goals,
                    last_updated = NOW()
                    WHERE plan_id = :id";
            $stmt = $db->prepare($sql);
            $params = [
                ':id' => $plan_id,
                ':name' => $plan_name,
                ':type_id' => $plan_type_id,
                ':fiscal_year' => $fiscal_year_id,
                ':scope' => $scope_type,
                ':start' => $planned_start_date,
                ':end' => $planned_end_date,
                ':budget' => $total_budget_allocated,
                ':status' => $plan_status_id,
                ':goals' => $goals
            ];
            if ($stmt->execute($params)) {
                $message = 'Plan updated successfully.';
            } else {
                $error = 'Failed to update plan.';
            }
        } else {
            // Insert
            $sql = "INSERT INTO ugims_management_plan (
                    plan_name, plan_type_id, fiscal_year_id, scope_type,
                    planned_start_date, planned_end_date, total_budget_allocated,
                    plan_status_id, goals_and_objectives, created_date, last_updated
                    ) VALUES (
                    :name, :type_id, :fiscal_year, :scope,
                    :start, :end, :budget,
                    :status, :goals, NOW(), NOW()
                    ) RETURNING plan_id";
            $stmt = $db->prepare($sql);
            $params = [
                ':name' => $plan_name,
                ':type_id' => $plan_type_id,
                ':fiscal_year' => $fiscal_year_id,
                ':scope' => $scope_type,
                ':start' => $planned_start_date,
                ':end' => $planned_end_date,
                ':budget' => $total_budget_allocated,
                ':status' => $plan_status_id,
                ':goals' => $goals
            ];
            if ($stmt->execute($params)) {
                $new_id = $stmt->fetchColumn();
                header('Location: plan_activities.php?plan_id=' . $new_id);
                exit;
            } else {
                $error = 'Failed to create plan.';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title><?= $plan_id ? 'Edit' : 'Add' ?> Maintenance Plan</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2><?= $plan_id ? 'Edit' : 'Add' ?> Maintenance Plan</h2>
        <div>
            <a href="plan_list.php">← Back to Plans</a>
        </div>
    </div>
    <div class="container">
        <?php if ($message): ?><div class="message"><?= $message ?></div><?php endif; ?>
        <?php if ($error): ?><div class="error"><?= $error ?></div><?php endif; ?>

        <form method="post">
            <div class="form-group">
                <label>Plan Name *</label>
                <input type="text" name="plan_name" value="<?= htmlspecialchars($plan['plan_name'] ?? '') ?>" required>
            </div>
            <div class="form-group">
                <label>Plan Type</label>
                <select name="plan_type_id">
                    <option value="">-- Select --</option>
                    <?php foreach ($plan_types as $pt): ?>
                    <option value="<?= $pt['plan_type_id'] ?>" <?= (($plan['plan_type_id'] ?? '') == $pt['plan_type_id']) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($pt['plan_type_name']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Fiscal Year</label>
                <select name="fiscal_year_id">
                    <option value="">-- Select --</option>
                    <?php foreach ($fiscal_years as $fy): ?>
                    <option value="<?= $fy['fiscal_year_id'] ?>" <?= (($plan['fiscal_year_id'] ?? '') == $fy['fiscal_year_id']) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($fy['fiscal_year_name']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Scope Type</label>
                <input type="text" name="scope_type" value="<?= htmlspecialchars($plan['scope_type'] ?? '') ?>">
            </div>
            <div class="form-row">
                <div class="form-col">
                    <label>Planned Start Date</label>
                    <input type="date" name="planned_start_date" value="<?= htmlspecialchars($plan['planned_start_date'] ?? '') ?>">
                </div>
                <div class="form-col">
                    <label>Planned End Date</label>
                    <input type="date" name="planned_end_date" value="<?= htmlspecialchars($plan['planned_end_date'] ?? '') ?>">
                </div>
            </div>
            <div class="form-group">
                <label>Total Budget Allocated</label>
                <input type="number" step="0.01" name="total_budget_allocated" value="<?= htmlspecialchars($plan['total_budget_allocated'] ?? '0') ?>">
            </div>
            <div class="form-group">
                <label>Status</label>
                <select name="plan_status_id">
                    <option value="">-- Select --</option>
                    <?php foreach ($plan_statuses as $ps): ?>
                    <option value="<?= $ps['status_id'] ?>" <?= (($plan['plan_status_id'] ?? '') == $ps['status_id']) ? 'selected' : '' ?>>
                        <?= htmlspecialchars($ps['status_name']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Goals & Objectives</label>
                <textarea name="goals_and_objectives" rows="4"><?= htmlspecialchars($plan['goals_and_objectives'] ?? '') ?></textarea>
            </div>
            <button type="submit">Save Plan</button>
            <?php if ($plan_id): ?>
                <a href="plan_activities.php?plan_id=<?= $plan_id ?>" class="btn">Manage Activities</a>
            <?php endif; ?>
        </form>
    </div>
</body>
</html>
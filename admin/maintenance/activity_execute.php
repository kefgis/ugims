<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$activity_id = $_GET['activity_id'] ?? null;
if (!$activity_id) {
    header('Location: plan_list.php');
    exit;
}

// Fetch activity details
$stmt = $db->prepare("
    SELECT pa.*, at.activity_name, u.name as ugi_name
    FROM ugims_plan_activity pa
    LEFT JOIN lkp_activity_type at ON pa.activity_type_id = at.activity_type_id
    LEFT JOIN ugims_ugi u ON pa.ugi_id = u.ugi_id
    WHERE pa.plan_activity_id = :id
");
$stmt->execute([':id' => $activity_id]);
$activity = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$activity) {
    header('Location: plan_list.php');
    exit;
}

// Fetch any existing execution for this activity
$stmt = $db->prepare("SELECT * FROM ugims_activity_execution WHERE plan_activity_id = :id ORDER BY recorded_datetime DESC LIMIT 1");
$stmt->execute([':id' => $activity_id]);
$execution = $stmt->fetch(PDO::FETCH_ASSOC);

// Fetch workforce users for assignment (simplified – you can also get from session)
$workers = $db->query("SELECT user_id, first_name, last_name FROM ugims_workforce_user WHERE is_active = true ORDER BY first_name")->fetchAll();

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $actual_start = $_POST['actual_start_datetime'] ?? null;
    $actual_end = $_POST['actual_end_datetime'] ?? null;
    $actual_man_days = $_POST['actual_man_days'] ?? 0;
    $actual_labor_cost = $_POST['actual_labor_cost'] ?? 0;
    $actual_material_cost = $_POST['actual_material_cost'] ?? 0;
    $materials_used = $_POST['materials_used'] ?? '';
    $work_notes = $_POST['work_notes'] ?? '';
    $quality_rating = $_POST['quality_rating'] ?? null;
    $performed_by = $_POST['performed_by_user_id'] ?? null;
    $supervised_by = $_POST['supervised_by_user_id'] ?? null;
    $completion_status = $_POST['completion_status_id'] ?? 6; // Completed

    if (empty($actual_start) || empty($actual_end) || empty($performed_by)) {
        $error = 'Start time, end time, and performer are required.';
    } else {
        // Insert execution record
        $sql = "INSERT INTO ugims_activity_execution (
                plan_activity_id, ugi_id, activity_type_id,
                actual_start_datetime, actual_end_datetime,
                actual_man_days, actual_labor_cost, actual_material_cost,
                materials_used_text, work_notes, quality_rating,
                performed_by_user_id, supervised_by_user_id,
                completion_status_id, recorded_datetime
                ) VALUES (
                :plan_activity_id, :ugi_id, :activity_type_id,
                :start, :end,
                :man_days, :labor, :material,
                :materials, :notes, :rating,
                :performed, :supervised,
                :status, NOW()
                )";
        $stmt = $db->prepare($sql);
        $params = [
            ':plan_activity_id' => $activity_id,
            ':ugi_id' => $activity['ugi_id'],
            ':activity_type_id' => $activity['activity_type_id'],
            ':start' => $actual_start,
            ':end' => $actual_end,
            ':man_days' => $actual_man_days,
            ':labor' => $actual_labor_cost,
            ':material' => $actual_material_cost,
            ':materials' => $materials_used,
            ':notes' => $work_notes,
            ':rating' => $quality_rating,
            ':performed' => $performed_by,
            ':supervised' => $supervised_by,
            ':status' => $completion_status
        ];
        if ($stmt->execute($params)) {
            // Optionally update the activity status to Completed
            $upd = $db->prepare("UPDATE ugims_plan_activity SET activity_status_id = 6 WHERE plan_activity_id = :id");
            $upd->execute([':id' => $activity_id]);
            $message = 'Execution logged successfully.';
        } else {
            $error = 'Failed to log execution.';
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Log Activity Execution</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Log Execution: <?= htmlspecialchars($activity['activity_name']) ?></h2>
        <div>
            <a href="plan_activities.php?plan_id=<?= $activity['plan_id'] ?>">← Back to Activities</a>
        </div>
    </div>
    <div class="container">
        <h3><?= htmlspecialchars($activity['ugi_name']) ?></h3>
        <p>Scheduled: <?= htmlspecialchars($activity['scheduled_start_date']) ?> to <?= htmlspecialchars($activity['scheduled_end_date']) ?></p>

        <?php if ($message): ?><div class="message"><?= $message ?></div><?php endif; ?>
        <?php if ($error): ?><div class="error"><?= $error ?></div><?php endif; ?>

        <?php if ($execution): ?>
        <div class="message">Previous execution recorded on <?= htmlspecialchars($execution['recorded_datetime']) ?></div>
        <?php endif; ?>

        <form method="post">
            <div class="form-row">
                <div class="form-col">
                    <div class="form-group">
                        <label>Actual Start Date/Time *</label>
                        <input type="datetime-local" name="actual_start_datetime" required value="<?= htmlspecialchars($execution['actual_start_datetime'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Actual End Date/Time *</label>
                        <input type="datetime-local" name="actual_end_datetime" required value="<?= htmlspecialchars($execution['actual_end_datetime'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Actual Man-days</label>
                        <input type="number" step="0.1" name="actual_man_days" value="<?= htmlspecialchars($execution['actual_man_days'] ?? '0') ?>">
                    </div>
                    <div class="form-group">
                        <label>Actual Labor Cost</label>
                        <input type="number" step="0.01" name="actual_labor_cost" value="<?= htmlspecialchars($execution['actual_labor_cost'] ?? '0') ?>">
                    </div>
                    <div class="form-group">
                        <label>Actual Material Cost</label>
                        <input type="number" step="0.01" name="actual_material_cost" value="<?= htmlspecialchars($execution['actual_material_cost'] ?? '0') ?>">
                    </div>
                </div>
                <div class="form-col">
                    <div class="form-group">
                        <label>Performed By *</label>
                        <select name="performed_by_user_id" required>
                            <option value="">-- Select --</option>
                            <?php foreach ($workers as $w): ?>
                            <option value="<?= $w['user_id'] ?>" <?= (($execution['performed_by_user_id'] ?? '') == $w['user_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($w['first_name'] . ' ' . $w['last_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Supervised By</label>
                        <select name="supervised_by_user_id">
                            <option value="">-- None --</option>
                            <?php foreach ($workers as $w): ?>
                            <option value="<?= $w['user_id'] ?>" <?= (($execution['supervised_by_user_id'] ?? '') == $w['user_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($w['first_name'] . ' ' . $w['last_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Quality Rating (1-5)</label>
                        <input type="number" min="1" max="5" name="quality_rating" value="<?= htmlspecialchars($execution['quality_rating'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Completion Status</label>
                        <select name="completion_status_id">
                            <option value="6">Completed</option>
                            <option value="7">Partially Completed</option>
                            <option value="9">Failed</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label>Materials Used</label>
                <textarea name="materials_used" rows="3"><?= htmlspecialchars($execution['materials_used_text'] ?? '') ?></textarea>
            </div>
            <div class="form-group">
                <label>Work Notes</label>
                <textarea name="work_notes" rows="3"><?= htmlspecialchars($execution['work_notes'] ?? '') ?></textarea>
            </div>
            <button type="submit">Log Execution</button>
        </form>
    </div>
</body>
</html>
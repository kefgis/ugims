<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$activity_id = $_GET['id'] ?? null;
$plan_id = $_GET['plan_id'] ?? null;
$activity = null;

if ($activity_id) {
    $stmt = $db->prepare("SELECT * FROM ugims_plan_activity WHERE plan_activity_id = :id");
    $stmt->execute([':id' => $activity_id]);
    $activity = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$activity) {
        header('Location: plan_list.php');
        exit;
    }
    $plan_id = $activity['plan_id'];
} elseif (!$plan_id) {
    header('Location: plan_list.php');
    exit;
}

// Fetch lookup data
$activity_types = $db->query("SELECT activity_type_id, activity_name FROM lkp_activity_type ORDER BY activity_name")->fetchAll();
$ugis = $db->query("SELECT ugi_id, name FROM ugims_ugi ORDER BY name")->fetchAll();
$teams = $db->query("SELECT team_id, team_name FROM ugims_team WHERE is_active = true ORDER BY team_name")->fetchAll();
$frequencies = $db->query("SELECT frequency_id, frequency_name FROM lkp_frequency ORDER BY frequency_id")->fetchAll();
$statuses = $db->query("SELECT status_id, status_name FROM lkp_activity_status ORDER BY status_id")->fetchAll();

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $activity_type_id = $_POST['activity_type_id'] ?? null;
    $ugi_id = $_POST['ugi_id'] ?? null;
    $scheduled_start_date = $_POST['scheduled_start_date'] ?? null;
    $scheduled_end_date = $_POST['scheduled_end_date'] ?? null;
    $estimated_man_days = $_POST['estimated_man_days'] ?? 0;
    $estimated_labor_cost = $_POST['estimated_labor_cost'] ?? 0;
    $estimated_material_cost = $_POST['estimated_material_cost'] ?? 0;
    $assigned_team_id = $_POST['assigned_team_id'] ?? null;
    $frequency_id = $_POST['frequency_id'] ?? null;
    $priority = $_POST['priority'] ?? 3;
    $activity_status_id = $_POST['activity_status_id'] ?? 1;
    $weather_dependent = isset($_POST['weather_dependent']) ? 'true' : 'false';
    $requires_supervision = isset($_POST['requires_supervision']) ? 'true' : 'false';

    if (empty($activity_type_id) || empty($ugi_id)) {
        $error = 'Activity type and UGI are required.';
    } else {
        if ($activity_id) {
            // Update
            $sql = "UPDATE ugims_plan_activity SET
                    activity_type_id = :type_id,
                    ugi_id = :ugi_id,
                    scheduled_start_date = :start,
                    scheduled_end_date = :end,
                    estimated_man_days = :man_days,
                    estimated_labor_cost = :labor,
                    estimated_material_cost = :material,
                    assigned_team_id = :team,
                    frequency_id = :freq,
                    priority = :priority,
                    activity_status_id = :status,
                    weather_dependent = :weather,
                    requires_supervision = :supervision,
                    last_updated = NOW()
                    WHERE plan_activity_id = :id";
            $stmt = $db->prepare($sql);
            $params = [
                ':id' => $activity_id,
                ':type_id' => $activity_type_id,
                ':ugi_id' => $ugi_id,
                ':start' => $scheduled_start_date,
                ':end' => $scheduled_end_date,
                ':man_days' => $estimated_man_days,
                ':labor' => $estimated_labor_cost,
                ':material' => $estimated_material_cost,
                ':team' => $assigned_team_id,
                ':freq' => $frequency_id,
                ':priority' => $priority,
                ':status' => $activity_status_id,
                ':weather' => $weather_dependent,
                ':supervision' => $requires_supervision
            ];
            if ($stmt->execute($params)) {
                $message = 'Activity updated successfully.';
            } else {
                $error = 'Failed to update activity.';
            }
        } else {
            // Insert
            $sql = "INSERT INTO ugims_plan_activity (
                    plan_id, activity_type_id, ugi_id,
                    scheduled_start_date, scheduled_end_date,
                    estimated_man_days, estimated_labor_cost, estimated_material_cost,
                    assigned_team_id, frequency_id, priority,
                    activity_status_id, weather_dependent, requires_supervision,
                    created_date, last_updated
                    ) VALUES (
                    :plan_id, :type_id, :ugi_id,
                    :start, :end,
                    :man_days, :labor, :material,
                    :team, :freq, :priority,
                    :status, :weather, :supervision,
                    NOW(), NOW()
                    ) RETURNING plan_activity_id";
            $stmt = $db->prepare($sql);
            $params = [
                ':plan_id' => $plan_id,
                ':type_id' => $activity_type_id,
                ':ugi_id' => $ugi_id,
                ':start' => $scheduled_start_date,
                ':end' => $scheduled_end_date,
                ':man_days' => $estimated_man_days,
                ':labor' => $estimated_labor_cost,
                ':material' => $estimated_material_cost,
                ':team' => $assigned_team_id,
                ':freq' => $frequency_id,
                ':priority' => $priority,
                ':status' => $activity_status_id,
                ':weather' => $weather_dependent,
                ':supervision' => $requires_supervision
            ];
            if ($stmt->execute($params)) {
                $new_id = $stmt->fetchColumn();
                header('Location: plan_activities.php?plan_id=' . $plan_id);
                exit;
            } else {
                $error = 'Failed to create activity.';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title><?= $activity_id ? 'Edit' : 'Add' ?> Activity</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2><?= $activity_id ? 'Edit' : 'Add' ?> Activity</h2>
        <div>
            <a href="plan_activities.php?plan_id=<?= $plan_id ?>">← Back to Activities</a>
        </div>
    </div>
    <div class="container">
        <?php if ($message): ?><div class="message"><?= $message ?></div><?php endif; ?>
        <?php if ($error): ?><div class="error"><?= $error ?></div><?php endif; ?>

        <form method="post">
            <div class="form-row">
                <div class="form-col">
                    <div class="form-group">
                        <label>Activity Type *</label>
                        <select name="activity_type_id" required>
                            <option value="">-- Select --</option>
                            <?php foreach ($activity_types as $at): ?>
                            <option value="<?= $at['activity_type_id'] ?>" <?= (($activity['activity_type_id'] ?? '') == $at['activity_type_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($at['activity_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>UGI *</label>
                        <select name="ugi_id" required>
                            <option value="">-- Select --</option>
                            <?php foreach ($ugis as $u): ?>
                            <option value="<?= $u['ugi_id'] ?>" <?= (($activity['ugi_id'] ?? '') == $u['ugi_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($u['name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Assigned Team</label>
                        <select name="assigned_team_id">
                            <option value="">-- None --</option>
                            <?php foreach ($teams as $t): ?>
                            <option value="<?= $t['team_id'] ?>" <?= (($activity['assigned_team_id'] ?? '') == $t['team_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($t['team_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Frequency</label>
                        <select name="frequency_id">
                            <option value="">-- One-time --</option>
                            <?php foreach ($frequencies as $f): ?>
                            <option value="<?= $f['frequency_id'] ?>" <?= (($activity['frequency_id'] ?? '') == $f['frequency_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($f['frequency_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
                <div class="form-col">
                    <div class="form-group">
                        <label>Scheduled Start</label>
                        <input type="date" name="scheduled_start_date" value="<?= htmlspecialchars($activity['scheduled_start_date'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Scheduled End</label>
                        <input type="date" name="scheduled_end_date" value="<?= htmlspecialchars($activity['scheduled_end_date'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Est. Man-days</label>
                        <input type="number" step="0.1" name="estimated_man_days" value="<?= htmlspecialchars($activity['estimated_man_days'] ?? '0') ?>">
                    </div>
                    <div class="form-group">
                        <label>Est. Labor Cost</label>
                        <input type="number" step="0.01" name="estimated_labor_cost" value="<?= htmlspecialchars($activity['estimated_labor_cost'] ?? '0') ?>">
                    </div>
                    <div class="form-group">
                        <label>Est. Material Cost</label>
                        <input type="number" step="0.01" name="estimated_material_cost" value="<?= htmlspecialchars($activity['estimated_material_cost'] ?? '0') ?>">
                    </div>
                </div>
            </div>
            <div class="form-row">
                <div class="form-col">
                    <div class="form-group">
                        <label>Priority (1=highest, 5=lowest)</label>
                        <input type="number" min="1" max="5" name="priority" value="<?= htmlspecialchars($activity['priority'] ?? '3') ?>">
                    </div>
                </div>
                <div class="form-col">
                    <div class="form-group">
                        <label>Status</label>
                        <select name="activity_status_id">
                            <?php foreach ($statuses as $s): ?>
                            <option value="<?= $s['status_id'] ?>" <?= (($activity['activity_status_id'] ?? '1') == $s['status_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($s['status_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
            </div>
            <div class="checkbox-group">
                <label><input type="checkbox" name="weather_dependent" <?= ($activity['weather_dependent'] ?? false) ? 'checked' : '' ?>> Weather Dependent</label>
                <label><input type="checkbox" name="requires_supervision" <?= ($activity['requires_supervision'] ?? false) ? 'checked' : '' ?>> Requires Supervision</label>
            </div>
            <button type="submit">Save Activity</button>
        </form>
    </div>
</body>
</html>
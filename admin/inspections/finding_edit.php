<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$finding_id = $_GET['id'] ?? null;
$inspection_id = $_GET['inspection_id'] ?? null;
$finding = null;

if ($finding_id) {
    $stmt = $db->prepare("SELECT * FROM ugims_inspection_finding WHERE finding_id = :id");
    $stmt->execute([':id' => $finding_id]);
    $finding = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$finding) {
        header('Location: list.php');
        exit;
    }
    $inspection_id = $finding['inspection_id'];
} elseif (!$inspection_id) {
    header('Location: list.php');
    exit;
}

// Fetch lookup data
$priorities = $db->query("SELECT priority_id, priority_name FROM lkp_finding_priority ORDER BY priority_id")->fetchAll();
$conditions = $db->query("SELECT status_id, status_name FROM lkp_condition_status ORDER BY status_id")->fetchAll();
$ugis = $db->query("SELECT ugi_id, name FROM ugims_ugi ORDER BY name")->fetchAll();

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $finding_description = $_POST['finding_description'] ?? '';
    $finding_priority_id = $_POST['finding_priority_id'] ?? null;
    $condition_before_id = $_POST['condition_before_id'] ?? null;
    $severity = $_POST['severity'] ?? 3;
    $recommended_action = $_POST['recommended_action'] ?? '';
    $resolved = isset($_POST['resolved']) ? true : false;

    if (empty($finding_description)) {
        $error = 'Finding description is required.';
    } else {
        if ($finding_id) {
            // Update
            $sql = "UPDATE ugims_inspection_finding SET
                    finding_description = :desc,
                    finding_priority_id = :priority,
                    condition_before_id = :condition,
                    severity = :severity,
                    recommended_action = :action,
                    resolved = :resolved,
                    last_updated = NOW()
                    WHERE finding_id = :id";
            $stmt = $db->prepare($sql);
            $params = [
                ':id' => $finding_id,
                ':desc' => $finding_description,
                ':priority' => $finding_priority_id,
                ':condition' => $condition_before_id,
                ':severity' => $severity,
                ':action' => $recommended_action,
                ':resolved' => $resolved
            ];
            if ($stmt->execute($params)) {
                $message = 'Finding updated successfully.';
            } else {
                $error = 'Failed to update finding.';
            }
        } else {
            // Insert
            $sql = "INSERT INTO ugims_inspection_finding (
                    inspection_id, finding_description, finding_priority_id,
                    condition_before_id, severity, recommended_action,
                    resolved, created_date, last_updated
                    ) VALUES (
                    :inspection_id, :desc, :priority,
                    :condition, :severity, :action,
                    :resolved, NOW(), NOW()
                    ) RETURNING finding_id";
            $stmt = $db->prepare($sql);
            $params = [
                ':inspection_id' => $inspection_id,
                ':desc' => $finding_description,
                ':priority' => $finding_priority_id,
                ':condition' => $condition_before_id,
                ':severity' => $severity,
                ':action' => $recommended_action,
                ':resolved' => $resolved
            ];
            if ($stmt->execute($params)) {
                $new_id = $stmt->fetchColumn();
                header('Location: findings.php?inspection_id=' . $inspection_id);
                exit;
            } else {
                $error = 'Failed to create finding.';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title><?= $finding_id ? 'Edit' : 'Add' ?> Finding</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2><?= $finding_id ? 'Edit' : 'Add' ?> Finding</h2>
        <div>
            <a href="findings.php?inspection_id=<?= $inspection_id ?>">← Back to Findings</a>
        </div>
    </div>
    <div class="container">
        <?php if ($message): ?><div class="message"><?= $message ?></div><?php endif; ?>
        <?php if ($error): ?><div class="error"><?= $error ?></div><?php endif; ?>

        <form method="post">
            <div class="form-group">
                <label>Finding Description *</label>
                <textarea name="finding_description" rows="4" required><?= htmlspecialchars($finding['finding_description'] ?? '') ?></textarea>
            </div>
            <div class="form-row">
                <div class="form-col">
                    <div class="form-group">
                        <label>Priority</label>
                        <select name="finding_priority_id">
                            <option value="">-- Select --</option>
                            <?php foreach ($priorities as $p): ?>
                            <option value="<?= $p['priority_id'] ?>" <?= (($finding['finding_priority_id'] ?? '') == $p['priority_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($p['priority_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Condition Before</label>
                        <select name="condition_before_id">
                            <option value="">-- Select --</option>
                            <?php foreach ($conditions as $c): ?>
                            <option value="<?= $c['status_id'] ?>" <?= (($finding['condition_before_id'] ?? '') == $c['status_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($c['status_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
                <div class="form-col">
                    <div class="form-group">
                        <label>Severity (1-5)</label>
                        <input type="number" min="1" max="5" name="severity" value="<?= htmlspecialchars($finding['severity'] ?? '3') ?>">
                    </div>
                    <div class="form-group">
                        <label>Resolved?</label>
                        <input type="checkbox" name="resolved" value="1" <?= ($finding['resolved'] ?? false) ? 'checked' : '' ?>>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label>Recommended Action</label>
                <textarea name="recommended_action" rows="3"><?= htmlspecialchars($finding['recommended_action'] ?? '') ?></textarea>
            </div>
            <button type="submit">Save Finding</button>
        </form>
    </div>
</body>
</html>
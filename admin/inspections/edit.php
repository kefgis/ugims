<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$inspection_id = $_GET['id'] ?? null;
$inspection = null;

if ($inspection_id) {
    $stmt = $db->prepare("SELECT * FROM ugims_inspection WHERE inspection_id = :id");
    $stmt->execute([':id' => $inspection_id]);
    $inspection = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$inspection) {
        header('Location: list.php');
        exit;
    }
}

// Fetch lookup data
$inspection_types = $db->query("SELECT inspection_type_id, inspection_name FROM lkp_inspection_type ORDER BY inspection_name")->fetchAll();
$inspection_statuses = $db->query("SELECT status_id, status_name FROM lkp_inspection_status ORDER BY status_id")->fetchAll();
$ugis = $db->query("SELECT ugi_id, name FROM ugims_ugi ORDER BY name")->fetchAll();
$inspectors = $db->query("SELECT user_id, first_name, last_name FROM ugims_workforce_user WHERE is_active = true ORDER BY first_name")->fetchAll();

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $inspection_number = $_POST['inspection_number'] ?? ('INS-' . date('Ymd') . '-' . rand(1000,9999));
    $inspection_type_id = $_POST['inspection_type_id'] ?? null;
    $ugi_id = $_POST['ugi_id'] ?? null;
    $scheduled_date = $_POST['scheduled_date'] ?? null;
    $assigned_to_user_id = $_POST['assigned_to_user_id'] ?? null;
    $inspection_status_id = $_POST['inspection_status_id'] ?? 1;
    $notes = $_POST['notes'] ?? '';

    if (empty($inspection_type_id) || empty($ugi_id) || empty($scheduled_date)) {
        $error = 'Inspection type, UGI, and scheduled date are required.';
    } else {
        if ($inspection_id) {
            // Update
            $sql = "UPDATE ugims_inspection SET
                    inspection_type_id = :type_id,
                    ugi_id = :ugi_id,
                    scheduled_date = :scheduled,
                    assigned_to_user_id = :inspector,
                    inspection_status_id = :status,
                    inspector_notes = :notes,
                    last_updated = NOW()
                    WHERE inspection_id = :id";
            $stmt = $db->prepare($sql);
            $params = [
                ':id' => $inspection_id,
                ':type_id' => $inspection_type_id,
                ':ugi_id' => $ugi_id,
                ':scheduled' => $scheduled_date,
                ':inspector' => $assigned_to_user_id,
                ':status' => $inspection_status_id,
                ':notes' => $notes
            ];
            if ($stmt->execute($params)) {
                $message = 'Inspection updated successfully.';
            } else {
                $error = 'Failed to update inspection.';
            }
        } else {
            // Insert
            $sql = "INSERT INTO ugims_inspection (
                    inspection_number, inspection_type_id, ugi_id,
                    scheduled_date, assigned_to_user_id,
                    inspection_status_id, inspector_notes,
                    created_date, last_updated
                    ) VALUES (
                    :number, :type_id, :ugi_id,
                    :scheduled, :inspector,
                    :status, :notes,
                    NOW(), NOW()
                    ) RETURNING inspection_id";
            $stmt = $db->prepare($sql);
            $params = [
                ':number' => $inspection_number,
                ':type_id' => $inspection_type_id,
                ':ugi_id' => $ugi_id,
                ':scheduled' => $scheduled_date,
                ':inspector' => $assigned_to_user_id,
                ':status' => $inspection_status_id,
                ':notes' => $notes
            ];
            if ($stmt->execute($params)) {
                $new_id = $stmt->fetchColumn();
                header('Location: findings.php?inspection_id=' . $new_id);
                exit;
            } else {
                $error = 'Failed to create inspection.';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title><?= $inspection_id ? 'Edit' : 'Schedule' ?> Inspection</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2><?= $inspection_id ? 'Edit' : 'Schedule' ?> Inspection</h2>
        <div>
            <a href="list.php">← Back to List</a>
        </div>
    </div>
    <div class="container">
        <?php if ($message): ?><div class="message"><?= $message ?></div><?php endif; ?>
        <?php if ($error): ?><div class="error"><?= $error ?></div><?php endif; ?>

        <form method="post">
            <div class="form-row">
                <div class="form-col">
                    <div class="form-group">
                        <label>Inspection Number</label>
                        <input type="text" name="inspection_number" value="<?= htmlspecialchars($inspection['inspection_number'] ?? '') ?>" placeholder="Auto-generated if empty">
                    </div>
                    <div class="form-group">
                        <label>Inspection Type *</label>
                        <select name="inspection_type_id" required>
                            <option value="">-- Select --</option>
                            <?php foreach ($inspection_types as $t): ?>
                            <option value="<?= $t['inspection_type_id'] ?>" <?= (($inspection['inspection_type_id'] ?? '') == $t['inspection_type_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($t['inspection_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>UGI *</label>
                        <select name="ugi_id" required>
                            <option value="">-- Select --</option>
                            <?php foreach ($ugis as $u): ?>
                            <option value="<?= $u['ugi_id'] ?>" <?= (($inspection['ugi_id'] ?? '') == $u['ugi_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($u['name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
                <div class="form-col">
                    <div class="form-group">
                        <label>Scheduled Date *</label>
                        <input type="datetime-local" name="scheduled_date" value="<?= htmlspecialchars($inspection['scheduled_date'] ?? '') ?>" required>
                    </div>
                    <div class="form-group">
                        <label>Assign to Inspector</label>
                        <select name="assigned_to_user_id">
                            <option value="">-- Unassigned --</option>
                            <?php foreach ($inspectors as $insp): ?>
                            <option value="<?= $insp['user_id'] ?>" <?= (($inspection['assigned_to_user_id'] ?? '') == $insp['user_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($insp['first_name'] . ' ' . $insp['last_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <select name="inspection_status_id">
                            <?php foreach ($inspection_statuses as $s): ?>
                            <option value="<?= $s['status_id'] ?>" <?= (($inspection['inspection_status_id'] ?? '1') == $s['status_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($s['status_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label>Notes</label>
                <textarea name="notes" rows="3"><?= htmlspecialchars($inspection['inspector_notes'] ?? '') ?></textarea>
            </div>
            <button type="submit">Save Inspection</button>
            <?php if ($inspection_id): ?>
                <a href="findings.php?inspection_id=<?= $inspection_id ?>" class="btn">Manage Findings</a>
            <?php endif; ?>
        </form>
    </div>
</body>
</html>
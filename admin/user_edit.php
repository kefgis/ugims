<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

$user_id = $_GET['id'] ?? 0;
if (!$user_id) {
    header('Location: users.php');
    exit;
}

$stmt = $db->prepare("SELECT * FROM ugims_users WHERE user_id = :id");
$stmt->execute([':id' => $user_id]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$user) {
    header('Location: users.php');
    exit;
}

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $full_name = trim($_POST['full_name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $role = $_POST['role'] ?? 'staff';
    $new_password = $_POST['new_password'] ?? '';

    $update = "UPDATE ugims_users SET full_name = :f, email = :e, role = :r";
    $params = [':f' => $full_name, ':e' => $email, ':r' => $role, ':id' => $user_id];

    if (!empty($new_password)) {
        $hash = password_hash($new_password, PASSWORD_DEFAULT);
        $update .= ", password_hash = :p";
        $params[':p'] = $hash;
    }

    $update .= " WHERE user_id = :id";
    $stmt = $db->prepare($update);
    if ($stmt->execute($params)) {
        $message = 'User updated successfully.';
        // Refresh user data
        $stmt = $db->prepare("SELECT * FROM ugims_users WHERE user_id = :id");
        $stmt->execute([':id' => $user_id]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
    } else {
        $error = 'Failed to update user.';
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Edit User</title>
    <style>
        body { font-family: Arial; margin: 0; background: #f4f6f9; }
        .header { background: #2c3e50; color: white; padding: 15px; }
        .container { padding: 20px; max-width: 500px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; font-weight: bold; margin-bottom: 5px; }
        input, select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        button { padding: 10px 20px; background: #3498db; color: white; border: none; border-radius: 4px; cursor: pointer; }
        .message { background: #d4edda; color: #155724; padding: 10px; margin-bottom: 20px; border-radius: 4px; }
        .error { background: #f8d7da; color: #721c24; padding: 10px; margin-bottom: 20px; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="header">
        <h2>UGIMS – Edit User</h2>
        <a href="users.php" style="color:white;">← Back to Users</a>
    </div>
    <div class="container">
        <?php if ($message): ?><div class="message"><?= $message ?></div><?php endif; ?>
        <?php if ($error): ?><div class="error"><?= $error ?></div><?php endif; ?>

        <form method="post">
            <div class="form-group">
                <label>Username (cannot change)</label>
                <input type="text" value="<?= htmlspecialchars($user['username']) ?>" disabled>
            </div>
            <div class="form-group">
                <label>Full Name</label>
                <input type="text" name="full_name" value="<?= htmlspecialchars($user['full_name']) ?>">
            </div>
            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" value="<?= htmlspecialchars($user['email']) ?>">
            </div>
            <div class="form-group">
                <label>Role</label>
                <select name="role">
                    <option value="staff" <?= $user['role'] == 'staff' ? 'selected' : '' ?>>Staff</option>
                    <option value="admin" <?= $user['role'] == 'admin' ? 'selected' : '' ?>>Admin</option>
                </select>
            </div>
            <div class="form-group">
                <label>New Password (leave blank to keep current)</label>
                <input type="password" name="new_password">
            </div>
            <button type="submit">Update User</button>
        </form>
    </div>
</body>
</html>
<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';
    $full_name = trim($_POST['full_name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $role = $_POST['role'] ?? 'staff';

    if (empty($username) || empty($password)) {
        $error = 'Username and password are required.';
    } else {
        // Check if username already exists
        $check = $db->prepare("SELECT COUNT(*) FROM ugims_users WHERE username = :u");
        $check->execute([':u' => $username]);
        if ($check->fetchColumn() > 0) {
            $error = 'Username already taken.';
        } else {
            $hash = password_hash($password, PASSWORD_DEFAULT);
            $stmt = $db->prepare("INSERT INTO ugims_users (username, password_hash, full_name, email, role) VALUES (:u, :p, :f, :e, :r)");
            $success = $stmt->execute([
                ':u' => $username,
                ':p' => $hash,
                ':f' => $full_name,
                ':e' => $email,
                ':r' => $role
            ]);
            if ($success) {
                $message = 'User created successfully.';
            } else {
                $error = 'Failed to create user.';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Add User</title>
    <style>
        body { font-family: Arial; margin: 0; background: #f4f6f9; }
        .header { background: #2c3e50; color: white; padding: 15px; }
        .container { padding: 20px; max-width: 500px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; font-weight: bold; margin-bottom: 5px; }
        input, select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        button { padding: 10px 20px; background: #2ecc71; color: white; border: none; border-radius: 4px; cursor: pointer; }
        .message { background: #d4edda; color: #155724; padding: 10px; margin-bottom: 20px; border-radius: 4px; }
        .error { background: #f8d7da; color: #721c24; padding: 10px; margin-bottom: 20px; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="header">
        <h2>UGIMS – Add User</h2>
        <a href="users.php" style="color:white;">← Back to Users</a>
    </div>
    <div class="container">
        <?php if ($message): ?><div class="message"><?= $message ?></div><?php endif; ?>
        <?php if ($error): ?><div class="error"><?= $error ?></div><?php endif; ?>

        <form method="post">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" required>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" required>
            </div>
            <div class="form-group">
                <label>Full Name</label>
                <input type="text" name="full_name">
            </div>
            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email">
            </div>
            <div class="form-group">
                <label>Role</label>
                <select name="role">
                    <option value="staff">Staff</option>
                    <option value="admin">Admin</option>
                </select>
            </div>
            <button type="submit">Create User</button>
        </form>
    </div>
</body>
</html>
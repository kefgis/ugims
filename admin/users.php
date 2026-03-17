<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'admin') {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

// Fetch all users
$stmt = $db->query("SELECT user_id, username, full_name, email, role, created_at, last_login FROM ugims_users ORDER BY user_id");
$users = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Users</title>
    <style>
        body { font-family: Arial; margin: 0; background: #f4f6f9; }
        .header { background: #2c3e50; color: white; padding: 15px; }
        .container { padding: 20px; }
        table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f8f9fa; }
        .btn { padding: 5px 10px; background: #3498db; color: white; text-decoration: none; border-radius: 3px; margin-right: 5px; }
        .btn-delete { background: #e74c3c; }
        .btn-add { background: #2ecc71; margin-bottom: 15px; display: inline-block; }
    </style>
</head>
<body>
    <div class="header">
        <h2>UGIMS – Manage Users</h2>
        <a href="dashboard.php" style="color:white;">← Back to Dashboard</a>
    </div>
    <div class="container">
        <a href="user_add.php" class="btn btn-add">➕ Add New User</a>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Username</th>
                    <th>Full Name</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Created</th>
                    <th>Last Login</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($users as $user): ?>
                <tr>
                    <td><?= $user['user_id'] ?></td>
                    <td><?= htmlspecialchars($user['username']) ?></td>
                    <td><?= htmlspecialchars($user['full_name']) ?></td>
                    <td><?= htmlspecialchars($user['email']) ?></td>
                    <td><?= htmlspecialchars($user['role']) ?></td>
                    <td><?= htmlspecialchars($user['created_at']) ?></td>
                    <td><?= htmlspecialchars($user['last_login'] ?? 'Never') ?></td>
                    <td>
                        <a href="user_edit.php?id=<?= $user['user_id'] ?>" class="btn">Edit</a>
                        <?php if ($user['user_id'] != $_SESSION['user_id']): // cannot delete yourself ?>
                            <a href="user_delete.php?id=<?= $user['user_id'] ?>" class="btn btn-delete" onclick="return confirm('Delete this user?')">Delete</a>
                        <?php endif; ?>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
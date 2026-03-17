<?php
session_start();
if (isset($_SESSION['user_id'])) {
    header('Location: dashboard.php');
    exit;
}

require_once '../api/config/database.php';

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';

    if ($username && $password) {
        $db = (new Database())->getConnection();
        $stmt = $db->prepare("SELECT user_id, username, password_hash, role FROM ugims_users WHERE username = :username");
        $stmt->execute([':username' => $username]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user && password_verify($password, $user['password_hash'])) {
            $_SESSION['user_id'] = $user['user_id'];
            $_SESSION['username'] = $user['username'];
            $_SESSION['role'] = $user['role'];

            // Update last login
            $update = $db->prepare("UPDATE ugims_users SET last_login = NOW() WHERE user_id = :id");
            $update->execute([':id' => $user['user_id']]);

            header('Location: dashboard.php');
            exit;
        } else {
            $error = 'Invalid username or password';
        }
    } else {
        $error = 'Please enter username and password';
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>UGIMS Admin Login</title>
    <style>
        body { font-family: Arial; background: #f0f2f5; display: flex; justify-content: center; align-items: center; height: 100vh; }
        .login-box { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); width: 300px; }
        h2 { margin-top: 0; color: #333; }
        input { width: 100%; padding: 8px; margin: 8px 0; border: 1px solid #ddd; border-radius: 4px; }
        button { width: 100%; padding: 10px; background: #2ecc71; color: white; border: none; border-radius: 4px; cursor: pointer; }
        .error { color: red; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="login-box">
        <h2>UGIMS Admin Login</h2>
        <?php if ($error): ?><div class="error"><?= htmlspecialchars($error) ?></div><?php endif; ?>
        <form method="post">
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Login</button>
        </form>
    </div>
</body>
</html>
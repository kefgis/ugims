<?php
// TEMPORARY PASSWORD RESET SCRIPT - DELETE AFTER USE!
require_once '../api/config/database.php';

$db = (new Database())->getConnection();

// Configuration - CHANGE THESE VALUES
$target_username = 'admin';  // Your admin username
$new_password = 'admin123';   // Your new password

// Generate the hash using the same method as your login
$hash = password_hash($new_password, PASSWORD_DEFAULT);

// First, let's see what users exist
echo "<h3>Current Users in Database:</h3>";
$users = $db->query("SELECT user_id, username, role FROM ugims_users ORDER BY user_id")->fetchAll();

if (count($users) > 0) {
    echo "<table border='1' cellpadding='8' style='border-collapse: collapse; margin-bottom: 20px;'>";
    echo "<tr><th>ID</th><th>Username</th><th>Role</th><th>Status</th></tr>";
    foreach ($users as $user) {
        $is_target = ($user['username'] == $target_username) ? '← TARGET' : '';
        echo "<tr>";
        echo "<td>" . $user['user_id'] . "</td>";
        echo "<td>" . htmlspecialchars($user['username']) . "</td>";
        echo "<td>" . htmlspecialchars($user['role']) . "</td>";
        echo "<td><strong>" . $is_target . "</strong></td>";
        echo "</tr>";
    }
    echo "</table>";
} else {
    echo "<p style='color: red;'>No users found in database!</p>";
}

// Attempt to reset password
if (count($users) > 0) {
    // Try to find the user
    $stmt = $db->prepare("SELECT user_id FROM ugims_users WHERE username = ?");
    $stmt->execute([$target_username]);
    $user = $stmt->fetch();
    
    if ($user) {
        // Update the password
        $update = $db->prepare("UPDATE ugims_users SET password_hash = ? WHERE username = ?");
        $result = $update->execute([$hash, $target_username]);
        
        if ($result) {
            echo "<div style='background: #d4edda; color: #155724; padding: 15px; border-radius: 4px; margin: 20px 0;'>";
            echo "<h3 style='margin-top: 0;'>✓ Password Reset Successful!</h3>";
            echo "<p><strong>Username:</strong> " . htmlspecialchars($target_username) . "</p>";
            echo "<p><strong>New Password:</strong> " . htmlspecialchars($new_password) . "</p>";
            echo "<p><strong>Password Hash:</strong> " . $hash . "</p>";
            echo "<p style='margin-top: 15px;'><a href='login.php' style='background: #2ecc71; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px;'>Click here to Login</a></p>";
            echo "</div>";
        } else {
            echo "<div style='background: #f8d7da; color: #721c24; padding: 15px; border-radius: 4px; margin: 20px 0;'>";
            echo "<h3>✗ Password Reset Failed</h3>";
            echo "<p>Could not update the database.</p>";
            echo "</div>";
        }
    } else {
        echo "<div style='background: #fff3cd; color: #856404; padding: 15px; border-radius: 4px; margin: 20px 0;'>";
        echo "<h3>⚠ User Not Found</h3>";
        echo "<p>Username '<strong>" . htmlspecialchars($target_username) . "</strong>' does not exist.</p>";
        echo "<p>Please check the table above for available usernames and update the \$target_username variable.</p>";
        echo "</div>";
    }
}

// If no users exist, offer to create one
if (count($users) == 0) {
    echo "<div style='background: #fff3cd; color: #856404; padding: 15px; border-radius: 4px; margin: 20px 0;'>";
    echo "<h3>⚠ No Users Found</h3>";
    echo "<p>The database has no users. Would you like to create an admin user?</p>";
    echo "<form method='post'>";
    echo "<input type='hidden' name='create_admin' value='1'>";
    echo "<button type='submit' style='background: #2ecc71; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer;'>Create Admin User</button>";
    echo "</form>";
    echo "</div>";
}

// Handle admin creation
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['create_admin'])) {
    $admin_username = 'admin';
    $admin_password = 'admin123';
    $admin_hash = password_hash($admin_password, PASSWORD_DEFAULT);
    
    $insert = $db->prepare("INSERT INTO ugims_users (username, password_hash, full_name, email, role, created_at) VALUES (?, ?, ?, ?, ?, NOW())");
    $result = $insert->execute([$admin_username, $admin_hash, 'Administrator', 'admin@example.com', 'admin']);
    
    if ($result) {
        echo "<div style='background: #d4edda; color: #155724; padding: 15px; border-radius: 4px; margin: 20px 0;'>";
        echo "<h3>✓ Admin User Created!</h3>";
        echo "<p><strong>Username:</strong> admin</p>";
        echo "<p><strong>Password:</strong> admin123</p>";
        echo "<p><a href='login.php' style='background: #2ecc71; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px;'>Click here to Login</a></p>";
        echo "</div>";
    }
}

// Add this at the bottom for security reminder
echo "<div style='margin-top: 30px; padding: 15px; background: #f8d7da; color: #721c24; border-radius: 4px;'>";
echo "<strong>⚠️ IMPORTANT SECURITY NOTICE:</strong><br>";
echo "This file contains sensitive password reset functionality. ";
echo "<strong style='font-size: 1.1em;'>DELETE THIS FILE IMMEDIATELY</strong> after you have reset your password!";
echo "</div>";
?>

<style>
    body {
        font-family: Arial, sans-serif;
        max-width: 800px;
        margin: 20px auto;
        padding: 20px;
        background: #f8f9fa;
    }
    table {
        width: 100%;
        background: white;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    th {
        background: #2c3e50;
        color: white;
        padding: 10px;
    }
    td {
        padding: 8px;
    }
    .warning {
        background: #fff3cd;
        border-left: 4px solid #ffc107;
        padding: 15px;
        margin: 20px 0;
    }
</style>
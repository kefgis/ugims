<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

// Get current user info
$stmt = $db->prepare("SELECT * FROM ugims_users WHERE user_id = ?");
$stmt->execute([$_SESSION['user_id']]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

// Get user activity stats
$stats = [];

// Reports submitted by user
$stats['reports_count'] = $db->prepare("SELECT COUNT(*) FROM ugims_citizen_report WHERE created_by_user_id = ?");
$stats['reports_count']->execute([$_SESSION['user_id']]);
$stats['reports_count'] = $stats['reports_count']->fetchColumn();

// Activities performed
$stats['activities_count'] = $db->prepare("SELECT COUNT(*) FROM ugims_activity_execution WHERE recorded_by_user_id = ?");
$stats['activities_count']->execute([$_SESSION['user_id']]);
$stats['activities_count'] = $stats['activities_count']->fetchColumn();

// Inspections conducted
$stats['inspections_count'] = $db->prepare("SELECT COUNT(*) FROM ugims_inspection WHERE inspector_user_id = ?");
$stats['inspections_count']->execute([$_SESSION['user_id']]);
$stats['inspections_count'] = $stats['inspections_count']->fetchColumn();

// Get recent activities
$recent_activities = $db->prepare("
    (SELECT 'report' as type, created_date as date, report_number as reference, 'Citizen Report' as description 
     FROM ugims_citizen_report WHERE created_by_user_id = ?)
    UNION ALL
    (SELECT 'activity' as type, recorded_datetime as date, execution_number as reference, 'Activity Execution' as description 
     FROM ugims_activity_execution WHERE recorded_by_user_id = ?)
    UNION ALL
    (SELECT 'inspection' as type, created_date as date, inspection_number as reference, 'Inspection' as description 
     FROM ugims_inspection WHERE inspector_user_id = ?)
    ORDER BY date DESC
    LIMIT 10
");
$recent_activities->execute([$_SESSION['user_id'], $_SESSION['user_id'], $_SESSION['user_id']]);
$recent_activities = $recent_activities->fetchAll();

$message = '';
$error = '';

// Handle profile update
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['update_profile'])) {
        $full_name = trim($_POST['full_name'] ?? '');
        $email = trim($_POST['email'] ?? '');
        
        $stmt = $db->prepare("UPDATE ugims_users SET full_name = ?, email = ? WHERE user_id = ?");
        if ($stmt->execute([$full_name, $email, $_SESSION['user_id']])) {
            $message = 'Profile updated successfully.';
            // Refresh user data
            $stmt = $db->prepare("SELECT * FROM ugims_users WHERE user_id = ?");
            $stmt->execute([$_SESSION['user_id']]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
        } else {
            $error = 'Failed to update profile.';
        }
    }
    
    if (isset($_POST['change_password'])) {
        $current = $_POST['current_password'] ?? '';
        $new = $_POST['new_password'] ?? '';
        $confirm = $_POST['confirm_password'] ?? '';
        
        if (empty($current) || empty($new) || empty($confirm)) {
            $error = 'All password fields are required.';
        } elseif ($new !== $confirm) {
            $error = 'New passwords do not match.';
        } elseif (strlen($new) < 6) {
            $error = 'Password must be at least 6 characters.';
        } elseif (!password_verify($current, $user['password_hash'])) {
            $error = 'Current password is incorrect.';
        } else {
            $hash = password_hash($new, PASSWORD_DEFAULT);
            $stmt = $db->prepare("UPDATE ugims_users SET password_hash = ? WHERE user_id = ?");
            if ($stmt->execute([$hash, $_SESSION['user_id']])) {
                $message = 'Password changed successfully.';
            } else {
                $error = 'Failed to change password.';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>My Profile - UGIMS</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .profile-container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .profile-header {
            background: linear-gradient(135deg, #2c3e50, #3498db);
            color: white;
            padding: 40px;
            border-radius: 15px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 30px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.2);
        }
        
        .profile-avatar {
            width: 120px;
            height: 120px;
            background: #f1c40f;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3.5rem;
            color: white;
            border: 4px solid white;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }
        
        .profile-title h1 {
            margin: 0;
            font-size: 2.2rem;
        }
        
        .profile-title p {
            margin: 5px 0 0;
            opacity: 0.9;
            font-size: 1.1rem;
        }
        
        .profile-badge {
            display: inline-block;
            padding: 5px 15px;
            background: rgba(255,255,255,0.2);
            border-radius: 20px;
            margin-top: 10px;
            font-size: 0.9rem;
        }
        
        .profile-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        
        .profile-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .card-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #ecf0f1;
        }
        
        .card-header i {
            font-size: 2rem;
            color: #3498db;
        }
        
        .card-header h3 {
            margin: 0;
            color: #2c3e50;
        }
        
        .info-row {
            display: flex;
            margin-bottom: 15px;
            padding: 10px 0;
            border-bottom: 1px dashed #ecf0f1;
        }
        
        .info-label {
            width: 120px;
            font-weight: 600;
            color: #7f8c8d;
        }
        
        .info-value {
            flex: 1;
            color: #2c3e50;
        }
        
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-item {
            text-align: center;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 10px;
        }
        
        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            color: #2c3e50;
        }
        
        .stat-label {
            font-size: 0.85rem;
            color: #7f8c8d;
            margin-top: 5px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #2c3e50;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 3px rgba(52,152,219,0.1);
        }
        
        .btn-save {
            background: #2ecc71;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: background 0.3s;
        }
        
        .btn-save:hover {
            background: #27ae60;
        }
        
        .btn-change {
            background: #3498db;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: background 0.3s;
        }
        
        .btn-change:hover {
            background: #2980b9;
        }
        
        .message {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .message.success {
            background: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }
        
        .message.error {
            background: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
        
        .activity-list {
            list-style: none;
            padding: 0;
        }
        
        .activity-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 12px 0;
            border-bottom: 1px solid #ecf0f1;
        }
        
        .activity-item:last-child {
            border-bottom: none;
        }
        
        .activity-icon {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        
        .activity-icon.report { background: #f39c12; }
        .activity-icon.activity { background: #2ecc71; }
        .activity-icon.inspection { background: #3498db; }
        
        .activity-details {
            flex: 1;
        }
        
        .activity-title {
            font-weight: 600;
            margin-bottom: 3px;
        }
        
        .activity-meta {
            font-size: 0.85rem;
            color: #7f8c8d;
        }
        
        .role-info {
            background: #e8f4fd;
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
        }
        
        .role-info h4 {
            margin: 0 0 10px;
            color: #2c3e50;
        }
        
        .permission-list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 10px;
        }
        
        .permission-tag {
            background: white;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            border: 1px solid #3498db;
            color: #3498db;
        }
        
        .dashboard-link {
            display: inline-block;
            margin-top: 20px;
            color: #3498db;
            text-decoration: none;
            font-weight: 600;
        }
        
        .dashboard-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="profile-container">
        <!-- Profile Header -->
        <div class="profile-header">
            <div class="profile-avatar">
                <?= strtoupper(substr($user['username'] ?? 'U', 0, 1)) ?>
            </div>
            <div class="profile-title">
                <h1><?= htmlspecialchars($user['full_name'] ?? $user['username']) ?></h1>
                <p><?= htmlspecialchars($user['email'] ?? 'No email provided') ?></p>
                <span class="profile-badge">
                    <i class="fas fa-user-tag"></i> Role: <?= ucfirst(htmlspecialchars($user['role'])) ?>
                </span>
            </div>
        </div>
        
        <?php if ($message): ?>
            <div class="message success">
                <i class="fas fa-check-circle"></i>
                <?= htmlspecialchars($message) ?>
            </div>
        <?php endif; ?>
        
        <?php if ($error): ?>
            <div class="message error">
                <i class="fas fa-exclamation-circle"></i>
                <?= htmlspecialchars($error) ?>
            </div>
        <?php endif; ?>
        
        <!-- Profile Grid -->
        <div class="profile-grid">
            <!-- Personal Information -->
            <div class="profile-card">
                <div class="card-header">
                    <i class="fas fa-user-circle"></i>
                    <h3>Personal Information</h3>
                </div>
                
                <form method="post">
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" value="<?= htmlspecialchars($user['username']) ?>" disabled>
                        <small style="color: #7f8c8d;">Username cannot be changed</small>
                    </div>
                    
                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" name="full_name" value="<?= htmlspecialchars($user['full_name'] ?? '') ?>">
                    </div>
                    
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="email" value="<?= htmlspecialchars($user['email'] ?? '') ?>">
                    </div>
                    
                    <button type="submit" name="update_profile" class="btn-save">
                        <i class="fas fa-save"></i> Update Profile
                    </button>
                </form>
            </div>
            
            <!-- Change Password -->
            <div class="profile-card">
                <div class="card-header">
                    <i class="fas fa-lock"></i>
                    <h3>Change Password</h3>
                </div>
                
                <form method="post">
                    <div class="form-group">
                        <label>Current Password</label>
                        <input type="password" name="current_password" required>
                    </div>
                    
                    <div class="form-group">
                        <label>New Password</label>
                        <input type="password" name="new_password" required>
                        <small style="color: #7f8c8d;">Minimum 6 characters</small>
                    </div>
                    
                    <div class="form-group">
                        <label>Confirm New Password</label>
                        <input type="password" name="confirm_password" required>
                    </div>
                    
                    <button type="submit" name="change_password" class="btn-change">
                        <i class="fas fa-key"></i> Change Password
                    </button>
                </form>
            </div>
            
            <!-- Account Statistics -->
            <div class="profile-card">
                <div class="card-header">
                    <i class="fas fa-chart-bar"></i>
                    <h3>Account Statistics</h3>
                </div>
                
                <div class="stat-grid">
                    <div class="stat-item">
                        <div class="stat-number"><?= $stats['reports_count'] ?></div>
                        <div class="stat-label">Reports</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number"><?= $stats['activities_count'] ?></div>
                        <div class="stat-label">Activities</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number"><?= $stats['inspections_count'] ?></div>
                        <div class="stat-label">Inspections</div>
                    </div>
                </div>
                
                <div class="info-row">
                    <span class="info-label">Member Since</span>
                    <span class="info-value"><?= date('F j, Y', strtotime($user['created_at'])) ?></span>
                </div>
                
                <div class="info-row">
                    <span class="info-label">Last Login</span>
                    <span class="info-value"><?= $user['last_login'] ? date('F j, Y H:i', strtotime($user['last_login'])) : 'Never' ?></span>
                </div>
                
                <div class="role-info">
                    <h4><i class="fas fa-shield-alt"></i> Role: <?= ucfirst($user['role']) ?></h4>
                    <p style="margin: 5px 0; color: #7f8c8d; font-size: 0.9rem;">Your permissions:</p>
                    <div class="permission-list">
                        <?php
                        $permissions = [
                            'admin' => ['Full System Access', 'User Management', 'All Modules'],
                            'manager' => ['Manage Assets', 'View Reports', 'Manage Plans', 'Budget View'],
                            'inspector' => ['Conduct Inspections', 'View Assets', 'Submit Findings'],
                            'field' => ['View Tasks', 'Log Activities', 'View Assigned Zones'],
                            'staff' => ['Basic Access', 'View Assigned Items']
                        ];
                        
                        $role_perms = $permissions[$user['role']] ?? ['Basic Access'];
                        foreach ($role_perms as $perm):
                        ?>
                        <span class="permission-tag"><?= $perm ?></span>
                        <?php endforeach; ?>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Recent Activity -->
        <?php if (!empty($recent_activities)): ?>
        <div class="profile-card" style="margin-top: 25px;">
            <div class="card-header">
                <i class="fas fa-history"></i>
                <h3>Recent Activity</h3>
            </div>
            
            <ul class="activity-list">
                <?php foreach ($recent_activities as $activity): ?>
                <li class="activity-item">
                    <div class="activity-icon <?= $activity['type'] ?>">
                        <i class="fas fa-<?= $activity['type'] == 'report' ? 'flag' : ($activity['type'] == 'activity' ? 'tasks' : 'clipboard-check') ?>"></i>
                    </div>
                    <div class="activity-details">
                        <div class="activity-title"><?= htmlspecialchars($activity['description']) ?></div>
                        <div class="activity-meta">
                            <span><i class="far fa-calendar"></i> <?= date('M d, Y H:i', strtotime($activity['date'])) ?></span>
                            <?php if ($activity['reference']): ?>
                            <span><i class="fas fa-hashtag"></i> <?= htmlspecialchars($activity['reference']) ?></span>
                            <?php endif; ?>
                        </div>
                    </div>
                </li>
                <?php endforeach; ?>
            </ul>
        </div>
        <?php endif; ?>
        
        <!-- Back to Dashboard -->
        <div style="text-align: center; margin-top: 30px;">
            <a href="dashboard.php" class="dashboard-link">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
        </div>
    </div>
</body>
</html>
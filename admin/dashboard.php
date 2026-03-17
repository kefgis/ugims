<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

// Get user info
$stmt = $db->prepare("SELECT * FROM ugims_users WHERE user_id = ?");
$stmt->execute([$_SESSION['user_id']]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

// Get statistics
$stats = [];

// UGI Statistics
$stats['ugi_total'] = $db->query("SELECT COUNT(*) FROM ugims_ugi")->fetchColumn();
$stats['ugi_by_condition'] = $db->query("
    SELECT cs.status_name, COUNT(*) as count 
    FROM ugims_ugi u 
    JOIN lkp_condition_status cs ON u.condition_status_id = cs.status_id 
    GROUP BY cs.status_name
")->fetchAll();

// Parcel Statistics
$stats['parcel_total'] = $db->query("SELECT COUNT(*) FROM ugims_parcel")->fetchColumn();

// Citizen Reports Statistics
$stats['reports_total'] = $db->query("SELECT COUNT(*) FROM ugims_citizen_report")->fetchColumn();
$stats['reports_pending'] = $db->query("SELECT COUNT(*) FROM ugims_citizen_report WHERE status_id = 1")->fetchColumn();
$stats['reports_by_status'] = $db->query("
    SELECT rs.status_name, COUNT(*) as count 
    FROM ugims_citizen_report r 
    JOIN lkp_citizen_report_status rs ON r.status_id = rs.status_id 
    GROUP BY rs.status_name
")->fetchAll();

// Activity Statistics
$stats['activities_planned'] = $db->query("SELECT COUNT(*) FROM ugims_plan_activity WHERE activity_status_id = 1")->fetchColumn();
$stats['activities_in_progress'] = $db->query("SELECT COUNT(*) FROM ugims_plan_activity WHERE activity_status_id = 4")->fetchColumn();
$stats['activities_completed'] = $db->query("SELECT COUNT(*) FROM ugims_plan_activity WHERE activity_status_id = 6")->fetchColumn();

// Inspection Statistics
$stats['inspections_scheduled'] = $db->query("SELECT COUNT(*) FROM ugims_inspection WHERE inspection_status_id = 1")->fetchColumn();
$stats['inspections_completed'] = $db->query("SELECT COUNT(*) FROM ugims_inspection WHERE inspection_status_id = 6")->fetchColumn();

// Budget Statistics
$stats['total_budget'] = $db->query("SELECT SUM(allocated_amount) FROM ugims_budget")->fetchColumn();
$stats['total_expenses'] = $db->query("SELECT SUM(amount) FROM ugims_expense")->fetchColumn();

// Recent Activities
$recent_activities = $db->query("
    SELECT ae.*, u.name as ugi_name, at.activity_name 
    FROM ugims_activity_execution ae
    JOIN ugims_ugi u ON ae.ugi_id = u.ugi_id
    JOIN lkp_activity_type at ON ae.activity_type_id = at.activity_type_id
    ORDER BY ae.recorded_datetime DESC
    LIMIT 10
")->fetchAll();

// Recent Citizen Reports
$recent_reports = $db->query("
    SELECT r.*, rt.report_type_name, rs.status_name 
    FROM ugims_citizen_report r
    JOIN lkp_citizen_report_type rt ON r.report_type_id = rt.report_type_id
    JOIN lkp_citizen_report_status rs ON r.status_id = rs.status_id
    ORDER BY r.created_date DESC
    LIMIT 10
")->fetchAll();

// Define modules with their permissions
$modules = [
    'dashboard' => [
        'name' => 'Dashboard',
        'icon' => 'fas fa-tachometer-alt',
        'description' => 'System overview and analytics',
        'path' => 'dashboard.php',
        'roles' => ['admin', 'manager', 'inspector', 'field', 'staff'],
        'color' => '#3498db'
    ],
    'ugi_assets' => [
        'name' => 'UGI Assets',
        'icon' => 'fas fa-tree',
        'description' => 'Manage parks, sport fields, and green spaces',
        'path' => 'ugi_list.php',
        'roles' => ['admin', 'manager', 'planner'],
        'color' => '#2ecc71'
    ],
    'parcels' => [
        'name' => 'Parcels',
        'icon' => 'fas fa-draw-polygon',
        'description' => 'Land parcel management',
        'path' => 'parcel_list.php',
        'roles' => ['admin', 'manager', 'planner'],
        'color' => '#e67e22'
    ],
    'citizen_reports' => [
        'name' => 'Citizen Reports',
        'icon' => 'fas fa-flag',
        'description' => 'Manage public reports and feedback',
        'path' => 'reports.php',
        'roles' => ['admin', 'manager', 'inspector', 'field'],
        'color' => '#f39c12'
    ],
    'maintenance' => [
        'name' => 'Maintenance Plans',
        'icon' => 'fas fa-calendar-check',
        'description' => 'Plan and track maintenance activities',
        'path' => 'maintenance/plan_list.php',
        'roles' => ['admin', 'manager', 'planner'],
        'color' => '#9b59b6'
    ],
    'activities' => [
        'name' => 'Activities',
        'icon' => 'fas fa-tasks',
        'description' => 'View and log maintenance activities',
        'path' => 'maintenance/plan_activities.php',
        'roles' => ['admin', 'manager', 'field'],
        'color' => '#3498db'
    ],
    'inspections' => [
        'name' => 'Inspections',
        'icon' => 'fas fa-clipboard-check',
        'description' => 'Schedule and record inspections',
        'path' => 'inspections/list.php',
        'roles' => ['admin', 'manager', 'inspector'],
        'color' => '#e74c3c'
    ],
    'budgets' => [
        'name' => 'Budgets',
        'icon' => 'fas fa-chart-line',
        'description' => 'Financial management',
        'path' => 'budgets/index.php',
        'roles' => ['admin', 'manager'],
        'color' => '#27ae60'
    ],
    'expenses' => [
        'name' => 'Expenses',
        'icon' => 'fas fa-wallet',
        'description' => 'Track expenses and costs',
        'path' => 'budgets/expenses.php',
        'roles' => ['admin', 'manager'],
        'color' => '#f1c40f'
    ],
    'reports_analytics' => [
        'name' => 'Reports & Analytics',
        'icon' => 'fas fa-chart-pie',
        'description' => 'Generate reports and insights',
        'path' => 'reports/index.php',
        'roles' => ['admin', 'manager', 'inspector'],
        'color' => '#1abc9c'
    ],
    'calendar' => [
        'name' => 'Calendar',
        'icon' => 'fas fa-calendar-alt',
        'description' => 'View scheduled activities',
        'path' => 'calendar.php',
        'roles' => ['admin', 'manager', 'field', 'inspector'],
        'color' => '#e67e22'
    ],
    'explorer' => [
        'name' => 'Map Explorer',
        'icon' => 'fas fa-map-marked-alt',
        'description' => 'Interactive map viewer',
        'path' => 'explorer.php',
        'roles' => ['admin', 'manager', 'inspector', 'field', 'planner'],
        'color' => '#3498db'
    ],
    'import' => [
        'name' => 'Import Data',
        'icon' => 'fas fa-upload',
        'description' => 'Import shapefiles and data',
        'path' => 'import/index.php',
        'roles' => ['admin', 'manager'],
        'color' => '#9b59b6'
    ],
    'export' => [
        'name' => 'Export Data',
        'icon' => 'fas fa-download',
        'description' => 'Export spatial data',
        'path' => 'export/index.php',
        'roles' => ['admin', 'manager', 'planner'],
        'color' => '#3498db'
    ],
    'users' => [
        'name' => 'User Management',
        'icon' => 'fas fa-users-cog',
        'description' => 'Manage system users',
        'path' => 'users.php',
        'roles' => ['admin'],
        'color' => '#e74c3c'
    ],
    'profile' => [
        'name' => 'My Profile',
        'icon' => 'fas fa-user-circle',
        'description' => 'View and edit profile',
        'path' => 'profile.php',
        'roles' => ['admin', 'manager', 'inspector', 'field', 'staff'],
        'color' => '#3498db'
    ]
];

// Filter modules based on user role
$user_role = $_SESSION['role'];
$available_modules = array_filter($modules, function($module) use ($user_role) {
    return in_array($user_role, $module['roles']);
});
?>
<!DOCTYPE html>
<html>
<head>
    <title>UGIMS Master Dashboard</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --sidebar-width: 280px;
            --header-height: 70px;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f4f6f9;
            overflow-x: hidden;
        }
        
        /* Header */
        .header {
            background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
            color: white;
            height: var(--header-height);
            padding: 0 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            box-shadow: 0 2px 10px rgba(0,0,0,0.2);
        }
        
        .logo-area {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .logo {
            font-size: 1.8rem;
            color: #2ecc71;
        }
        
        .logo-text h1 {
            font-size: 1.3rem;
            margin: 0;
            font-weight: 500;
        }
        
        .logo-text p {
            font-size: 0.8rem;
            margin: 0;
            opacity: 0.8;
        }
        
        .user-menu {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .user-info {
            text-align: right;
        }
        
        .user-name {
            font-weight: 600;
            font-size: 0.95rem;
        }
        
        .user-role {
            font-size: 0.8rem;
            opacity: 0.8;
            text-transform: capitalize;
        }
        
        .user-avatar {
            width: 45px;
            height: 45px;
            background: #2ecc71;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
        }
        
        .logout-btn {
            background: rgba(255,255,255,0.1);
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 4px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 5px;
            transition: background 0.3s;
        }
        
        .logout-btn:hover {
            background: rgba(255,255,255,0.2);
        }
        
        /* Main Layout */
        .main-container {
            display: flex;
            margin-top: var(--header-height);
            min-height: calc(100vh - var(--header-height));
        }
        
        /* Sidebar */
        .sidebar {
            width: var(--sidebar-width);
            background: white;
            position: fixed;
            left: 0;
            top: var(--header-height);
            bottom: 0;
            overflow-y: auto;
            box-shadow: 2px 0 5px rgba(0,0,0,0.1);
            z-index: 900;
        }
        
        .sidebar-header {
            padding: 20px;
            background: #f8f9fa;
            border-bottom: 1px solid #ddd;
        }
        
        .sidebar-header h3 {
            margin: 0;
            color: #2c3e50;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .sidebar-header p {
            margin: 5px 0 0;
            font-size: 0.8rem;
            color: #7f8c8d;
        }
        
        .sidebar-nav {
            padding: 15px;
        }
        
        .nav-section {
            margin-bottom: 25px;
        }
        
        .nav-section-title {
            font-size: 0.75rem;
            text-transform: uppercase;
            color: #95a5a6;
            margin-bottom: 10px;
            padding-left: 10px;
            letter-spacing: 0.5px;
        }
        
        .nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 15px;
            margin-bottom: 5px;
            border-radius: 8px;
            color: #2c3e50;
            text-decoration: none;
            transition: all 0.3s;
            position: relative;
        }
        
        .nav-item:hover {
            background: #f0f0f0;
        }
        
        .nav-item.active {
            background: #3498db;
            color: white;
        }
        
        .nav-item i {
            width: 20px;
            font-size: 1.1rem;
        }
        
        .nav-item .badge {
            position: absolute;
            right: 15px;
            background: #e74c3c;
            color: white;
            padding: 2px 6px;
            border-radius: 10px;
            font-size: 0.7rem;
        }
        
        /* Main Content */
        .content {
            flex: 1;
            margin-left: var(--sidebar-width);
            padding: 30px;
        }
        
        /* Welcome Banner */
        .welcome-banner {
            background: linear-gradient(135deg, #3498db, #2c3e50);
            color: white;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .welcome-text h2 {
            font-size: 1.8rem;
            margin-bottom: 10px;
        }
        
        .welcome-text p {
            font-size: 1rem;
            opacity: 0.9;
        }
        
        .welcome-stats {
            display: flex;
            gap: 30px;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-number {
            font-size: 2rem;
            font-weight: 700;
        }
        
        .stat-label {
            font-size: 0.9rem;
            opacity: 0.8;
        }
        
        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            gap: 15px;
            transition: transform 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        
        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            color: white;
        }
        
        .stat-details h3 {
            font-size: 1.5rem;
            margin: 0;
            color: #2c3e50;
        }
        
        .stat-details p {
            margin: 5px 0 0;
            color: #7f8c8d;
            font-size: 0.9rem;
        }
        
        /* Modules Grid */
        .section-title {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .section-title h3 {
            font-size: 1.3rem;
            color: #2c3e50;
        }
        
        .modules-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .module-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
        }
        
        .module-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        
        .module-card.disabled {
            opacity: 0.5;
            filter: grayscale(0.5);
            pointer-events: none;
        }
        
        .module-card.active {
            border-left: 4px solid var(--module-color);
        }
        
        .module-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 15px;
        }
        
        .module-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
        }
        
        .module-header h4 {
            margin: 0;
            font-size: 1.1rem;
            color: #2c3e50;
        }
        
        .module-description {
            color: #7f8c8d;
            font-size: 0.9rem;
            margin-bottom: 15px;
            line-height: 1.5;
        }
        
        .module-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .module-badge {
            background: #f0f0f0;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.7rem;
            color: #555;
            text-transform: uppercase;
        }
        
        .module-link {
            color: #3498db;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .module-link:hover {
            color: #2980b9;
        }
        
        /* Charts Row */
        .charts-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .chart-card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .chart-card h4 {
            margin: 0 0 15px;
            color: #2c3e50;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        canvas {
            max-height: 300px;
        }
        
        /* Recent Activities */
        .recent-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 20px;
        }
        
        .recent-card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .recent-card h4 {
            margin: 0 0 15px;
            color: #2c3e50;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .activity-list {
            list-style: none;
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
            background: #f0f0f0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #555;
        }
        
        .activity-details {
            flex: 1;
        }
        
        .activity-title {
            font-weight: 600;
            margin-bottom: 3px;
        }
        
        .activity-meta {
            font-size: 0.8rem;
            color: #7f8c8d;
            display: flex;
            gap: 15px;
        }
        
        .report-status {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.7rem;
            font-weight: 600;
            color: white;
        }
        
        /* Responsive */
        @media (max-width: 1024px) {
            :root {
                --sidebar-width: 240px;
            }
            
            .welcome-banner {
                flex-direction: column;
                text-align: center;
                gap: 20px;
            }
        }
        
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
                transition: transform 0.3s;
            }
            
            .sidebar.open {
                transform: translateX(0);
            }
            
            .content {
                margin-left: 0;
            }
            
            .charts-row {
                grid-template-columns: 1fr;
            }
            
            .recent-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="header">
        <div class="logo-area">
            <i class="fas fa-tree logo"></i>
            <div class="logo-text">
                <h1>UGIMS</h1>
                <p>Urban Green Infrastructure Management</p>
            </div>
        </div>
        
        <div class="user-menu">
            <div class="user-info">
                <div class="user-name"><?= htmlspecialchars($user['full_name'] ?? $user['username']) ?></div>
                <div class="user-role"><?= htmlspecialchars($user['role']) ?></div>
            </div>
            <div class="user-avatar">
                <?= strtoupper(substr($user['username'] ?? 'U', 0, 1)) ?>
            </div>
            <a href="logout.php" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i>
            </a>
        </div>
    </div>
    
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h3>Navigation</h3>
            <p>Quick access to modules</p>
        </div>
        
        <div class="sidebar-nav">
            <?php
            $sections = [
                'Main' => ['dashboard', 'explorer', 'calendar'],
                'Management' => ['ugi_assets', 'parcels', 'citizen_reports'],
                'Operations' => ['maintenance', 'activities', 'inspections'],
                'Finance' => ['budgets', 'expenses'],
                'Data' => ['import', 'export', 'reports_analytics'],
                'Administration' => ['users', 'profile']
            ];
            
            foreach ($sections as $section => $module_keys):
                $has_modules = false;
                foreach ($module_keys as $key) {
                    if (isset($available_modules[$key])) {
                        $has_modules = true;
                        break;
                    }
                }
                if (!$has_modules) continue;
            ?>
            <div class="nav-section">
                <div class="nav-section-title"><?= $section ?></div>
                <?php foreach ($module_keys as $key):
                    if (!isset($available_modules[$key])) continue;
                    $module = $available_modules[$key];
                    $is_active = (basename($_SERVER['PHP_SELF']) == $module['path']);
                ?>
                <a href="<?= $module['path'] ?>" class="nav-item <?= $is_active ? 'active' : '' ?>">
                    <i class="<?= $module['icon'] ?>" style="color: <?= $module['color'] ?>"></i>
                    <span><?= $module['name'] ?></span>
                </a>
				<a href="profile.php" class="nav-item">
					<i class="fas fa-user-circle"></i>
					<span>My Profile</span>
				</a>
                <?php endforeach; ?>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
    
    <!-- Main Content -->
    <div class="content">
        <!-- Welcome Banner -->
        <div class="welcome-banner">
            <div class="welcome-text">
                <h2>Welcome back, <?= htmlspecialchars($user['full_name'] ?? $user['username']) ?>!</h2>
                <p>Here's what's happening with your green infrastructure today.</p>
            </div>
            <div class="welcome-stats">
                <div class="stat-item">
                    <div class="stat-number"><?= number_format($stats['ugi_total']) ?></div>
                    <div class="stat-label">UGI Assets</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><?= number_format($stats['reports_pending']) ?></div>
                    <div class="stat-label">Pending Reports</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><?= number_format($stats['activities_in_progress']) ?></div>
                    <div class="stat-label">Active Tasks</div>
                </div>
            </div>
        </div>
        
        <!-- Stats Grid -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon" style="background: linear-gradient(135deg, #3498db, #2980b9);">
                    <i class="fas fa-tree"></i>
                </div>
                <div class="stat-details">
                    <h3><?= number_format($stats['ugi_total']) ?></h3>
                    <p>Total UGI Assets</p>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon" style="background: linear-gradient(135deg, #e67e22, #d35400);">
                    <i class="fas fa-draw-polygon"></i>
                </div>
                <div class="stat-details">
                    <h3><?= number_format($stats['parcel_total']) ?></h3>
                    <p>Parcels</p>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon" style="background: linear-gradient(135deg, #f39c12, #e67e22);">
                    <i class="fas fa-flag"></i>
                </div>
                <div class="stat-details">
                    <h3><?= number_format($stats['reports_total']) ?></h3>
                    <p>Citizen Reports</p>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon" style="background: linear-gradient(135deg, #2ecc71, #27ae60);">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-details">
                    <h3><?= number_format($stats['activities_completed']) ?></h3>
                    <p>Completed Activities</p>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon" style="background: linear-gradient(135deg, #9b59b6, #8e44ad);">
                    <i class="fas fa-clipboard-check"></i>
                </div>
                <div class="stat-details">
                    <h3><?= number_format($stats['inspections_scheduled']) ?></h3>
                    <p>Scheduled Inspections</p>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon" style="background: linear-gradient(135deg, #e74c3c, #c0392b);">
                    <i class="fas fa-chart-line"></i>
                </div>
                <div class="stat-details">
                    <h3><?= number_format($stats['total_budget'] ?? 0, 2) ?></h3>
                    <p>Total Budget (ETB)</p>
                </div>
            </div>
        </div>
        
        <!-- Available Modules -->
        <div class="section-title">
            <h3><i class="fas fa-cubes" style="margin-right: 10px;"></i> Available Modules</h3>
            <span class="module-count"><?= count($available_modules) ?> modules</span>
        </div>
        
        <div class="modules-grid">
            <?php foreach ($available_modules as $key => $module): ?>
            <div class="module-card active">
                <div class="module-header">
                    <div class="module-icon" style="background: <?= $module['color'] ?>">
                        <i class="<?= $module['icon'] ?>"></i>
                    </div>
                    <h4><?= $module['name'] ?></h4>
                </div>
                <div class="module-description">
                    <?= $module['description'] ?>
                </div>
                <div class="module-footer">
                    <span class="module-badge"><?= $user_role ?> access</span>
                    <a href="<?= $module['path'] ?>" class="module-link">
                        Access Module <i class="fas fa-arrow-right"></i>
                    </a>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
        
        <!-- Charts Row -->
        <?php if (!empty($stats['reports_by_status']) || !empty($stats['ugi_by_condition'])): ?>
        <div class="charts-row">
            <?php if (!empty($stats['reports_by_status'])): ?>
            <div class="chart-card">
                <h4><i class="fas fa-chart-pie" style="color: #3498db;"></i> Reports by Status</h4>
                <canvas id="reportsChart"></canvas>
            </div>
            <?php endif; ?>
            
            <?php if (!empty($stats['ugi_by_condition'])): ?>
            <div class="chart-card">
                <h4><i class="fas fa-chart-bar" style="color: #2ecc71;"></i> UGI by Condition</h4>
                <canvas id="ugiConditionChart"></canvas>
            </div>
            <?php endif; ?>
        </div>
        <?php endif; ?>
        
        <!-- Recent Activities -->
        <div class="recent-grid">
            <?php if (!empty($recent_activities)): ?>
            <div class="recent-card">
                <h4><i class="fas fa-history" style="color: #3498db;"></i> Recent Activities</h4>
                <ul class="activity-list">
                    <?php foreach ($recent_activities as $act): ?>
                    <li class="activity-item">
                        <div class="activity-icon">
                            <i class="fas fa-tasks"></i>
                        </div>
                        <div class="activity-details">
                            <div class="activity-title"><?= htmlspecialchars($act['activity_name']) ?> at <?= htmlspecialchars($act['ugi_name']) ?></div>
                            <div class="activity-meta">
                                <span><i class="far fa-calendar"></i> <?= date('M d, H:i', strtotime($act['recorded_datetime'])) ?></span>
                                <span><i class="far fa-clock"></i> <?= $act['actual_man_days'] ?> days</span>
                            </div>
                        </div>
                    </li>
                    <?php endforeach; ?>
                </ul>
            </div>
            <?php endif; ?>
            
            <?php if (!empty($recent_reports)): ?>
            <div class="recent-card">
                <h4><i class="fas fa-flag" style="color: #f39c12;"></i> Recent Citizen Reports</h4>
                <ul class="activity-list">
                    <?php foreach ($recent_reports as $report): ?>
                    <li class="activity-item">
                        <div class="activity-icon">
                            <i class="fas fa-user"></i>
                        </div>
                        <div class="activity-details">
                            <div class="activity-title"><?= htmlspecialchars($report['report_type_name']) ?></div>
                            <div class="activity-meta">
                                <span><i class="far fa-calendar"></i> <?= date('M d', strtotime($report['created_date'])) ?></span>
                                <span>
                                    <span class="report-status" style="background: <?= $report['status_id'] == 1 ? '#f39c12' : ($report['status_id'] == 6 ? '#2ecc71' : '#3498db') ?>">
                                        <?= htmlspecialchars($report['status_name']) ?>
                                    </span>
                                </span>
                            </div>
                        </div>
                    </li>
                    <?php endforeach; ?>
                </ul>
            </div>
            <?php endif; ?>
        </div>
    </div>
    
    <script>
        // Reports Chart
        <?php if (!empty($stats['reports_by_status'])): ?>
        new Chart(document.getElementById('reportsChart'), {
            type: 'doughnut',
            data: {
                labels: <?= json_encode(array_column($stats['reports_by_status'], 'status_name')) ?>,
                datasets: [{
                    data: <?= json_encode(array_column($stats['reports_by_status'], 'count')) ?>,
                    backgroundColor: ['#f39c12', '#3498db', '#2ecc71', '#e74c3c', '#9b59b6']
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });
        <?php endif; ?>
        
        // UGI Condition Chart
        <?php if (!empty($stats['ugi_by_condition'])): ?>
        new Chart(document.getElementById('ugiConditionChart'), {
            type: 'bar',
            data: {
                labels: <?= json_encode(array_column($stats['ugi_by_condition'], 'status_name')) ?>,
                datasets: [{
                    label: 'Number of Assets',
                    data: <?= json_encode(array_column($stats['ugi_by_condition'], 'count')) ?>,
                    backgroundColor: '#2ecc71'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });
        <?php endif; ?>
        
        // Mobile sidebar toggle (you can add a hamburger menu button)
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('open');
        }
    </script>
</body>
</html>
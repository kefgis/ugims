<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

// ... existing summary counts (UGI, citizen reports, inspections, activities) remain the same ...
$ugi_count = $db->query("SELECT COUNT(*) FROM ugims_ugi")->fetchColumn();
$citizen_reports_total = $db->query("SELECT COUNT(*) FROM ugims_citizen_report")->fetchColumn();
$citizen_reports_pending = $db->query("SELECT COUNT(*) FROM ugims_citizen_report WHERE status_id = 1")->fetchColumn();
$inspections_total = $db->query("SELECT COUNT(*) FROM ugims_inspection")->fetchColumn();
$activities_completed = $db->query("SELECT COUNT(*) FROM ugims_activity_execution")->fetchColumn();

// UGI condition breakdown
$condition_data = $db->query("
    SELECT cs.status_name, COUNT(*) as count
    FROM ugims_ugi u
    JOIN lkp_condition_status cs ON u.condition_status_id = cs.status_id
    GROUP BY cs.status_name
")->fetchAll(PDO::FETCH_KEY_PAIR);

// Citizen reports by month (last 6 months)
$reports_by_month = $db->query("
    SELECT TO_CHAR(created_date, 'YYYY-MM') as month, COUNT(*) as count
    FROM ugims_citizen_report
    WHERE created_date >= NOW() - INTERVAL '6 months'
    GROUP BY month
    ORDER BY month
")->fetchAll();

// Inspection status breakdown
$inspection_status = $db->query("
    SELECT ist.status_name, COUNT(*) as count
    FROM ugims_inspection i
    JOIN lkp_inspection_status ist ON i.inspection_status_id = ist.status_id
    GROUP BY ist.status_name
")->fetchAll(PDO::FETCH_KEY_PAIR);

// NEW: Budget summary
$budget_summary = $db->query("
    SELECT 
        COUNT(*) as total_budgets,
        SUM(allocated_amount) as total_allocated,
        SUM(expended_amount) as total_spent
    FROM ugims_budget
")->fetch(PDO::FETCH_ASSOC);

// NEW: Spending by category (expense type)
$spending_by_category = $db->query("
    SELECT 
        CASE 
            WHEN expense_type = '1' THEN 'Materials'
            WHEN expense_type = '2' THEN 'Labor'
            WHEN expense_type = '3' THEN 'Equipment'
            ELSE 'Other'
        END as category,
        SUM(amount) as total
    FROM ugims_expense
    GROUP BY category
")->fetchAll(PDO::FETCH_KEY_PAIR);

// NEW: Monthly spending trend (last 6 months)
$monthly_spending = $db->query("
    SELECT TO_CHAR(expense_date, 'YYYY-MM') as month, SUM(amount) as total
    FROM ugims_expense
    WHERE expense_date >= NOW() - INTERVAL '6 months'
    GROUP BY month
    ORDER BY month
")->fetchAll();
?>
<!DOCTYPE html>
<html>
<head>
    <title>Reports & Analytics</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .chart-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .chart-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        canvas { max-height: 300px; }
    </style>
</head>
<body>
    <div class="header">
        <h2>Reports & Analytics</h2>
        <div>
            <a href="../dashboard.php">Dashboard</a>
            <a href="../logout.php">Logout</a>
        </div>
    </div>
    <div class="container">
        <!-- Summary Cards (existing + budget) -->
        <div class="cards">
            <div class="card">
                <h3>Total UGI Assets</h3>
                <div class="number"><?= $ugi_count ?></div>
            </div>
            <div class="card">
                <h3>Citizen Reports</h3>
                <div class="number"><?= $citizen_reports_total ?></div>
                <small>Pending: <?= $citizen_reports_pending ?></small>
            </div>
            <div class="card">
                <h3>Inspections</h3>
                <div class="number"><?= $inspections_total ?></div>
            </div>
            <div class="card">
                <h3>Activities Completed</h3>
                <div class="number"><?= $activities_completed ?></div>
            </div>
            <!-- NEW budget cards -->
            <div class="card">
                <h3>Total Budgets</h3>
                <div class="number"><?= $budget_summary['total_budgets'] ?></div>
            </div>
            <div class="card">
                <h3>Total Allocated</h3>
                <div class="number"><?= number_format($budget_summary['total_allocated'] ?? 0, 2) ?></div>
            </div>
            <div class="card">
                <h3>Total Spent</h3>
                <div class="number"><?= number_format($budget_summary['total_spent'] ?? 0, 2) ?></div>
            </div>
        </div>

        <!-- Navigation to Detailed Reports -->
        <div class="nav-links" style="margin: 20px 0;">
            <a href="citizen_reports.php">Citizen Reports Analysis</a>
            <a href="activities.php">Activity Completion</a>
            <a href="inspections.php">Inspection Findings</a>
            <a href="ugi_condition.php">UGI Condition</a>
            <a href="financial.php">Financial Reports</a> <!-- NEW link -->
        </div>

        <!-- Charts (existing + new financial charts) -->
        <div class="chart-container">
            <!-- UGI Condition Pie Chart (existing) -->
            <div class="chart-card">
                <h3>UGI Condition Breakdown</h3>
                <canvas id="conditionChart"></canvas>
            </div>

            <!-- Citizen Reports Over Time (existing) -->
            <div class="chart-card">
                <h3>Citizen Reports (Last 6 Months)</h3>
                <canvas id="reportsLineChart"></canvas>
            </div>

            <!-- Inspection Status (existing) -->
            <div class="chart-card">
                <h3>Inspection Status</h3>
                <canvas id="inspectionChart"></canvas>
            </div>

            <!-- NEW: Spending by Category -->
            <div class="chart-card">
                <h3>Spending by Category</h3>
                <canvas id="categoryChart"></canvas>
            </div>

            <!-- NEW: Monthly Spending Trend -->
            <div class="chart-card">
                <h3>Monthly Spending (Last 6 Months)</h3>
                <canvas id="spendingLineChart"></canvas>
            </div>
        </div>
    </div>

    <script>
        // Condition Chart
        new Chart(document.getElementById('conditionChart'), {
            type: 'pie',
            data: {
                labels: <?= json_encode(array_keys($condition_data)) ?>,
                datasets: [{
                    data: <?= json_encode(array_values($condition_data)) ?>,
                    backgroundColor: ['#2ecc71', '#f1c40f', '#e67e22', '#e74c3c', '#3498db']
                }]
            }
        });

        // Reports Line Chart
        new Chart(document.getElementById('reportsLineChart'), {
            type: 'line',
            data: {
                labels: <?= json_encode(array_column($reports_by_month, 'month')) ?>,
                datasets: [{
                    label: 'Reports',
                    data: <?= json_encode(array_column($reports_by_month, 'count')) ?>,
                    borderColor: '#3498db',
                    fill: false
                }]
            }
        });

        // Inspection Status Chart
        new Chart(document.getElementById('inspectionChart'), {
            type: 'doughnut',
            data: {
                labels: <?= json_encode(array_keys($inspection_status)) ?>,
                datasets: [{
                    data: <?= json_encode(array_values($inspection_status)) ?>,
                    backgroundColor: ['#2ecc71', '#f1c40f', '#e74c3c', '#3498db', '#9b59b6']
                }]
            }
        });

        // NEW: Spending by Category
        new Chart(document.getElementById('categoryChart'), {
            type: 'pie',
            data: {
                labels: <?= json_encode(array_keys($spending_by_category)) ?>,
                datasets: [{
                    data: <?= json_encode(array_values($spending_by_category)) ?>,
                    backgroundColor: ['#e67e22', '#3498db', '#2ecc71', '#f1c40f']
                }]
            }
        });

        // NEW: Monthly Spending Trend
        new Chart(document.getElementById('spendingLineChart'), {
            type: 'line',
            data: {
                labels: <?= json_encode(array_column($monthly_spending, 'month')) ?>,
                datasets: [{
                    label: 'Amount',
                    data: <?= json_encode(array_column($monthly_spending, 'total')) ?>,
                    borderColor: '#e74c3c',
                    fill: false
                }]
            }
        });
    </script>
</body>
</html>
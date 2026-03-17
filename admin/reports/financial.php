<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

// Budget summary
$budgets = $db->query("
    SELECT b.*, fy.fiscal_year_name,
           COALESCE((SELECT SUM(amount) FROM ugims_expense WHERE budget_id = b.budget_id), 0) as spent
    FROM ugims_budget b
    LEFT JOIN lkp_fiscal_year fy ON b.fiscal_year_id = fy.fiscal_year_id
    ORDER BY fy.start_date DESC, b.budget_name
")->fetchAll();

// Expenses by UGI
$expenses_by_ugi = $db->query("
    SELECT u.name, SUM(e.amount) as total
    FROM ugims_expense e
    LEFT JOIN ugims_ugi u ON e.ugi_id = u.ugi_id
    GROUP BY u.name
    ORDER BY total DESC
    LIMIT 10
")->fetchAll();

// Expenses by activity type
$expenses_by_activity = $db->query("
    SELECT a.activity_name, SUM(e.amount) as total
    FROM ugims_expense e
    LEFT JOIN lkp_activity_type a ON e.expense_type::integer = a.activity_type_id
    GROUP BY a.activity_name
    ORDER BY total DESC
")->fetchAll();

// Monthly totals
$monthly_totals = $db->query("
    SELECT TO_CHAR(expense_date, 'YYYY-MM') as month, SUM(amount) as total
    FROM ugims_expense
    GROUP BY month
    ORDER BY month DESC
    LIMIT 12
")->fetchAll();

// Current fiscal year spending vs allocated
$current_fy = $db->query("SELECT fiscal_year_id FROM lkp_fiscal_year WHERE is_current = true")->fetchColumn();
if ($current_fy) {
    $current_budgets = $db->prepare("
        SELECT SUM(allocated_amount) as total_allocated,
               COALESCE((SELECT SUM(amount) FROM ugims_expense WHERE budget_id IN (SELECT budget_id FROM ugims_budget WHERE fiscal_year_id = ?)), 0) as total_spent
        FROM ugims_budget
        WHERE fiscal_year_id = ?
    ");
    $current_budgets->execute([$current_fy, $current_fy]);
    $current = $current_budgets->fetch(PDO::FETCH_ASSOC);
} else {
    $current = ['total_allocated' => 0, 'total_spent' => 0];
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Financial Reports</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="header">
        <h2>Financial Reports</h2>
        <div>
            <a href="index.php">← Back to Reports</a>
        </div>
    </div>
    <div class="container">
        <!-- Summary Cards -->
        <div class="cards">
            <div class="card">
                <h3>Current FY Allocated</h3>
                <div class="number"><?= number_format($current['total_allocated'], 2) ?></div>
            </div>
            <div class="card">
                <h3>Current FY Spent</h3>
                <div class="number"><?= number_format($current['total_spent'], 2) ?></div>
            </div>
            <div class="card">
                <h3>Remaining</h3>
                <div class="number"><?= number_format($current['total_allocated'] - $current['total_spent'], 2) ?></div>
            </div>
        </div>

        <!-- Export Buttons -->
        <div style="margin: 20px 0;">
            <a href="export_financial_csv.php?type=budgets" class="btn">Export Budgets to CSV</a>
            <a href="export_financial_csv.php?type=expenses" class="btn">Export Expenses to CSV</a>
        </div>

        <!-- Budget vs Actual Table -->
        <h3>Budget vs Actual</h3>
        <table>
            <thead>
                <tr>
                    <th>Budget</th>
                    <th>Fiscal Year</th>
                    <th>Allocated</th>
                    <th>Spent</th>
                    <th>Remaining</th>
                    <th>Utilization %</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($budgets as $b): 
                    $remaining = $b['allocated_amount'] - $b['spent'];
                    $util = $b['allocated_amount'] > 0 ? round(($b['spent'] / $b['allocated_amount']) * 100, 1) : 0;
                ?>
                <tr>
                    <td><?= htmlspecialchars($b['budget_name']) ?></td>
                    <td><?= htmlspecialchars($b['fiscal_year_name']) ?></td>
                    <td><?= number_format($b['allocated_amount'], 2) ?></td>
                    <td><?= number_format($b['spent'], 2) ?></td>
                    <td><?= number_format($remaining, 2) ?></td>
                    <td><?= $util ?>%</td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>

        <!-- Charts -->
        <div class="chart-container">
            <div class="chart-card">
                <h3>Top 10 UGI by Expense</h3>
                <canvas id="ugiChart"></canvas>
            </div>
            <div class="chart-card">
                <h3>Expenses by Activity Type</h3>
                <canvas id="activityChart"></canvas>
            </div>
        </div>

        <div class="chart-card">
            <h3>Monthly Expenses (Last 12 Months)</h3>
            <canvas id="monthlyChart"></canvas>
        </div>
    </div>

    <script>
        new Chart(document.getElementById('ugiChart'), {
            type: 'bar',
            data: {
                labels: <?= json_encode(array_column($expenses_by_ugi, 'name')) ?>,
                datasets: [{
                    label: 'Amount',
                    data: <?= json_encode(array_column($expenses_by_ugi, 'total')) ?>,
                    backgroundColor: '#3498db'
                }]
            }
        });

        new Chart(document.getElementById('activityChart'), {
            type: 'pie',
            data: {
                labels: <?= json_encode(array_column($expenses_by_activity, 'activity_name')) ?>,
                datasets: [{
                    data: <?= json_encode(array_column($expenses_by_activity, 'total')) ?>,
                    backgroundColor: ['#2ecc71', '#f1c40f', '#e67e22', '#e74c3c', '#3498db', '#9b59b6']
                }]
            }
        });

        new Chart(document.getElementById('monthlyChart'), {
            type: 'line',
            data: {
                labels: <?= json_encode(array_column($monthly_totals, 'month')) ?>,
                datasets: [{
                    label: 'Expenses',
                    data: <?= json_encode(array_column($monthly_totals, 'total')) ?>,
                    borderColor: '#e74c3c',
                    fill: false
                }]
            }
        });
    </script>
</body>
</html>
<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$type = $_GET['type'] ?? 'budgets';

header('Content-Type: text/csv');
header('Content-Disposition: attachment; filename="' . $type . '_' . date('Y-m-d') . '.csv"');

$output = fopen('php://output', 'w');

if ($type === 'budgets') {
    // Budgets export
    fputcsv($output, ['Budget Name', 'Fiscal Year', 'Allocated', 'Spent', 'Status']);
    $stmt = $db->query("
        SELECT b.budget_name, fy.fiscal_year_name, b.allocated_amount, 
               COALESCE((SELECT SUM(amount) FROM ugims_expense WHERE budget_id = b.budget_id), 0) as spent,
               b.budget_status
        FROM ugims_budget b
        LEFT JOIN lkp_fiscal_year fy ON b.fiscal_year_id = fy.fiscal_year_id
        ORDER BY fy.start_date DESC
    ");
    while ($row = $stmt->fetch(PDO::FETCH_NUM)) {
        fputcsv($output, $row);
    }
} else {
    // Expenses export
    fputcsv($output, ['Date', 'Budget', 'Description', 'Amount', 'UGI', 'Vendor']);
    $stmt = $db->query("
        SELECT e.expense_date, b.budget_name, e.description, e.amount, u.name, e.vendor_name
        FROM ugims_expense e
        LEFT JOIN ugims_budget b ON e.budget_id = b.budget_id
        LEFT JOIN ugims_ugi u ON e.ugi_id = u.ugi_id
        ORDER BY e.expense_date DESC
    ");
    while ($row = $stmt->fetch(PDO::FETCH_NUM)) {
        fputcsv($output, $row);
    }
}

fclose($output);
exit;
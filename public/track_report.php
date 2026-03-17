<?php
require_once '../api/config/database.php';
$db = (new Database())->getConnection();

$results = [];
$search_performed = false;
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $report_number = trim($_POST['report_number'] ?? '');
    $email = trim($_POST['email'] ?? '');

    if (empty($report_number) && empty($email)) {
        $error = 'Please enter a report number or email address.';
    } else {
        $search_performed = true;
        $sql = "SELECT r.report_id, r.report_number, r.report_description, 
                       r.created_date, rs.status_name, rt.report_type_name,
                       r.reporter_name, r.reporter_email
                FROM ugims_citizen_report r
                LEFT JOIN lkp_citizen_report_status rs ON r.status_id = rs.status_id
                LEFT JOIN lkp_citizen_report_type rt ON r.report_type_id = rt.report_type_id
                WHERE 1=1";
        $params = [];

        if (!empty($report_number)) {
            $sql .= " AND r.report_number = ?";
            $params[] = $report_number;
        }
        if (!empty($email)) {
            $sql .= " AND r.reporter_email = ?";
            $params[] = $email;
        }

        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (empty($results)) {
            $error = 'No reports found matching your criteria.';
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Track Your Report – UGIMS</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <style>
        .public-header {
            background: #27ae60;
            color: white;
            padding: 15px;
            text-align: center;
        }
        .public-header a {
            color: white;
            text-decoration: none;
            margin: 0 15px;
        }
        .track-form {
            background: white;
            padding: 30px;
            border-radius: 8px;
            max-width: 600px;
            margin: 30px auto;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .results-table {
            margin-top: 30px;
            background: white;
            border-radius: 8px;
            overflow: hidden;
        }
        .status-badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 0.8rem;
            font-weight: bold;
            color: white;
        }
        .status-1 { background-color: #f39c12; } /* Submitted */
        .status-2 { background-color: #3498db; } /* Under Review */
        .status-3 { background-color: #2ecc71; } /* Acknowledged */
        .status-4 { background-color: #9b59b6; } /* Assigned */
        .status-5 { background-color: #f1c40f; } /* In Progress */
        .status-6 { background-color: #27ae60; } /* Resolved */
        .status-7 { background-color: #2c3e50; } /* Closed */
        .status-8 { background-color: #e74c3c; } /* Rejected */
    </style>
</head>
<body>
    <div class="public-header">
        <h2>Urban Green Infrastructure Management System</h2>
        <div>
            <a href="../index.html">Home</a>
            <a href="track_report.php">Track Your Report</a>
        </div>
    </div>

    <div class="container">
        <div class="track-form">
            <h2>Track Your Report</h2>
            <p>Enter your report number OR the email you used when submitting.</p>

            <?php if ($error): ?>
                <div class="error"><?= htmlspecialchars($error) ?></div>
            <?php endif; ?>

            <form method="post">
                <div class="form-group">
                    <label>Report Number</label>
                    <input type="text" name="report_number" placeholder="e.g., RPT-20250315-1234" value="<?= htmlspecialchars($_POST['report_number'] ?? '') ?>">
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" name="email" placeholder="you@example.com" value="<?= htmlspecialchars($_POST['email'] ?? '') ?>">
                </div>
                <button type="submit">Search</button>
            </form>
        </div>

        <?php if ($search_performed && !empty($results)): ?>
            <div class="results-table">
                <h3>Search Results</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Report #</th>
                            <th>Date</th>
                            <th>Type</th>
                            <th>Description</th>
                            <th>Status</th>
                            <th>Reporter</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($results as $r): ?>
                        <tr>
                            <td><?= htmlspecialchars($r['report_number']) ?></td>
                            <td><?= htmlspecialchars($r['created_date']) ?></td>
                            <td><?= htmlspecialchars($r['report_type_name']) ?></td>
                            <td><?= htmlspecialchars(substr($r['report_description'], 0, 50)) ?>...</td>
                            <td>
                                <span class="status-badge status-<?= $r['status_id'] ?>">
                                    <?= htmlspecialchars($r['status_name']) ?>
                                </span>
                            </td>
                            <td><?= htmlspecialchars($r['reporter_name'] ?? 'Anonymous') ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </div>
</body>
</html>
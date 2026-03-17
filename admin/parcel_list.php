<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

// Fetch all parcels with some basic info
$query = "SELECT p.parcel_id, p.parcel_number, p.parcel_registration_number,
                 l.land_use_name, o.ownership_name,
                 ST_Area(p.geometry) as area_sq_m,
                 p.registration_date, p.Woreda_id
          FROM ugims_parcel p
          LEFT JOIN lkp_land_use_type l ON p.land_use_type_id = l.land_use_id
          LEFT JOIN lkp_ownership_type o ON p.ownership_type_id = o.ownership_id
          ORDER BY p.parcel_number";
$parcels = $db->query($query)->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html>
<head>
    <title>Parcel Management</title>
    <link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Parcel Management</h2>
        <div>
            <a href="dashboard.php">Dashboard</a>
            <a href="logout.php">Logout</a>
        </div>
    </div>
    <div class="container">
        <a href="parcel_edit.php" class="btn btn-add">➕ Add New Parcel</a>

        <table>
            <thead>
                <tr>
                    <th>Parcel Number</th>
                    <th>Registration Number</th>
                    <th>Land Use</th>
                    <th>Ownership</th>
                    <th>Area (m²)</th>
                    <th>Registration Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($parcels as $p): ?>
                <tr>
                    <td><?= htmlspecialchars($p['parcel_number']) ?></td>
                    <td><?= htmlspecialchars($p['parcel_registration_number']) ?></td>
                    <td><?= htmlspecialchars($p['land_use_name']) ?></td>
                    <td><?= htmlspecialchars($p['ownership_name']) ?></td>
                    <td><?= number_format($p['area_sq_m'], 2) ?></td>
                    <td><?= htmlspecialchars($p['registration_date']) ?></td>
                    <td class="actions">
                        <a href="parcel_edit.php?id=<?= $p['parcel_id'] ?>" class="btn btn-small btn-edit">Edit</a>
                        <a href="parcel_delete.php?id=<?= $p['parcel_id'] ?>" class="btn btn-small btn-delete" onclick="return confirm('Delete this parcel? This will affect all related UGI assets.')">Delete</a>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
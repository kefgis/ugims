<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Import Help</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Import Help & Guidelines</h2>
        <div>
            <a href="index.php">Back to Import</a>
        </div>
    </div>
    <div class="container">
        <div style="background: white; padding: 30px; border-radius: 8px;">
            <h3>Preparing Your Shapefile for Import</h3>
            
            <h4>1. Field Names</h4>
            <p>Your shapefile's attribute table should contain fields that match the database columns. Use the template exporter to download a CSV with the correct field names.</p>
            
            <h4>2. Coordinate System</h4>
            <p>All geometries must be in <strong>EPSG:20137 (UTM zone 37S)</strong>. If your data is in another projection, reproject it before importing.</p>
            
            <h4>3. Data Types</h4>
            <ul>
                <li><strong>Integer fields</strong>: Use whole numbers (e.g., 1, 2, 3)</li>
                <li><strong>Boolean fields</strong>: Use 'true'/'false', '1'/'0', or 'yes'/'no'</li>
                <li><strong>Date fields</strong>: Use YYYY-MM-DD format (e.g., 2024-01-31)</li>
                <li><strong>UUID fields</strong>: For parcel_id in UGI imports, use the exact UUID from the parcels table</li>
            </ul>
            
            <h4>4. Required Fields</h4>
            <ul>
                <li><strong>Parcels</strong>: parcel_number (unique identifier)</li>
                <li><strong>UGI</strong>: name, ugi_type_id, parcel_id (must exist in database)</li>
            </ul>
            
            <h4>5. File Packaging</h4>
            <p>Package all shapefile components (.shp, .shx, .dbf, .prj) into a single ZIP file for upload.</p>
            
            <h4>6. Data Validation</h4>
            <p>Always use the preview feature before confirming import. This shows you how your data will be interpreted.</p>
            
            <h4>7. Lookup Values</h4>
            <p>Refer to the lookup tables in the mapping interface for correct ID values.</p>
        </div>
    </div>
</body>
</html>
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
    <title>Export Help</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Export Help & Guidelines</h2>
        <div>
            <a href="index.php">Back to Export</a>
            <a href="../dashboard.php">Dashboard</a>
        </div>
    </div>
    <div class="container">
        <div style="background: white; padding: 30px; border-radius: 8px;">
            <h3>Export Options</h3>
            
            <h4>1. CSV Templates (Recommended)</h4>
            <p>Simple spreadsheet format that can be opened in Excel or any text editor. Each download includes:</p>
            <ul>
                <li>A CSV file with column headers matching database fields</li>
                <li>A sample row showing example data</li>
                <li>Empty rows for your data</li>
                <li>README with field descriptions</li>
            </ul>
            
            <h4>2. GeoJSON Templates</h4>
            <p>For users working with web mapping libraries or modern GIS software. Includes:</p>
            <ul>
                <li>A sample feature with geometry</li>
                <li>Coordinate system information (EPSG:20137)</li>
                <li>Proper GeoJSON structure</li>
            </ul>
            
            <h4>3. Shapefile Templates</h4>
            <p>For users with traditional GIS software. Currently provides CSV with instructions for creating shapefiles manually.</p>
            
            <h4>Coordinate System</h4>
            <p>All exports use <strong>EPSG:20137 (UTM zone 37S)</strong> – the standard for Ethiopian spatial data.</p>
            
            <h4>Field Types</h4>
            <table class="table">
                <tr><th>Type</th><th>Description</th><th>Example</th></tr>
                <tr><td>character</td><td>Text/string values</td><td>'Park Name'</td></tr>
                <tr><td>integer</td><td>Whole numbers</td><td>123</td></tr>
                <tr><td>boolean</td><td>True/false values</td><td>true, false, 1, 0</td></tr>
                <tr><td>date</td><td>YYYY-MM-DD format</td><td>2024-01-31</td></tr>
                <tr><td>timestamp</td><td>YYYY-MM-DD HH:MM:SS</td><td>2024-01-31 14:30:00</td></tr>
                <tr><td>numeric</td><td>Decimal numbers</td><td>123.45</td></tr>
            </table>
            
            <h4>Next Steps After Export</h4>
            <ol>
                <li>Populate the template with your data</li>
                <li>Save in the appropriate format</li>
                <li>Use the <a href="../import/index.php">Import System</a> to upload your data</li>
            </ol>
        </div>
    </div>
</body>
</html>
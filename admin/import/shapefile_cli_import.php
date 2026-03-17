<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['shapefile_zip'])) {
    $import_type = $_POST['import_type'];
    $srid = $_POST['srid'] ?? '20137'; // Default to UTM 37S
    $target_table = ($import_type === 'parcel') ? 'ugims_parcel' : 'ugims_ugi';
    $duplicate_handling = $_POST['duplicate_handling'] ?? '-a'; // -a = append, -d = drop, -c = create new
    
    // Convert duplicate handling to shp2pgsql flag
    $shp2pgsql_flag = '-a'; // append by default
    if ($duplicate_handling === 'replace') {
        $shp2pgsql_flag = '-d'; // drop and recreate
    } elseif ($duplicate_handling === 'create') {
        $shp2pgsql_flag = '-c'; // create new table
    }
    
    // Handle ZIP upload
    $zip_file = $_FILES['shapefile_zip']['tmp_name'];
    $upload_dir = sys_get_temp_dir() . '/shp_import_' . uniqid();
    mkdir($upload_dir);
    
    $zip = new ZipArchive;
    if ($zip->open($zip_file) === true) {
        $zip->extractTo($upload_dir);
        $zip->close();
        
        // Find the .shp file
        $shp_file = null;
        foreach (scandir($upload_dir) as $file) {
            if (pathinfo($file, PATHINFO_EXTENSION) === 'shp') {
                $shp_file = $upload_dir . '/' . $file;
                break;
            }
        }
        
        if (!$shp_file) {
            $error = 'No .shp file found in the ZIP archive';
        } else {
            // Build shp2pgsql command
            $db_config = require '../../api/config/database.php';
            $command = sprintf(
                'shp2pgsql -s %s %s %s %s | psql -h %s -p %s -U %s -d %s',
                escapeshellarg($srid),
                $shp2pgsql_flag,
                escapeshellarg($shp_file),
                escapeshellarg($target_table),
                escapeshellarg($db_config['host']),
                escapeshellarg($db_config['port']),
                escapeshellarg($db_config['user']),
                escapeshellarg($db_config['dbname'])
            );
            
            // Set PGPASSWORD environment variable
            putenv('PGPASSWORD=' . $db_config['password']);
            
            // Execute command
            $output = [];
            $return_var = 0;
            exec($command . ' 2>&1', $output, $return_var);
            
            if ($return_var === 0) {
                $message = "Import successful! " . implode("\n", $output);
                
                // Log the import
                $db = (new Database())->getConnection();
                $log = $db->prepare("INSERT INTO ugims_import_log 
                                    (import_type, filename, records_processed, imported_by_user_id, status)
                                    VALUES (?, ?, ?, ?, 'completed')");
                $log->execute([
                    $import_type,
                    $_FILES['shapefile_zip']['name'],
                    count($output), // approximate
                    $_SESSION['user_id']
                ]);
            } else {
                $error = "Import failed: " . implode("\n", $output);
            }
        }
        
        // Clean up
        array_map('unlink', glob($upload_dir . '/*'));
        rmdir($upload_dir);
        
    } else {
        $error = 'Failed to open ZIP file';
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Shapefile Import (Command-line)</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="header">
        <h2>Shapefile Import - Command Line Method</h2>
        <div>
            <a href="../dashboard.php">Dashboard</a>
        </div>
    </div>
    <div class="container">
        <?php if ($message): ?>
            <div class="message"><?= nl2br(htmlspecialchars($message)) ?></div>
        <?php endif; ?>
        <?php if ($error): ?>
            <div class="error"><?= nl2br(htmlspecialchars($error)) ?></div>
        <?php endif; ?>

        <div class="info-box">
            <h3>Using PostgreSQL shp2pgsql</h3>
            <p>This method requires the <code>shp2pgsql</code> command-line tool to be installed and accessible.</p>
            <p>It is faster for large files but requires shell access.</p>
        </div>

        <form method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label>Import Type</label>
                <select name="import_type" required>
                    <option value="parcel">Parcels</option>
                    <option value="ugi">UGI Assets</option>
                </select>
            </div>

            <div class="form-group">
                <label>Shapefile (ZIP archive containing .shp, .shx, .dbf)</label>
                <input type="file" name="shapefile_zip" accept=".zip" required>
            </div>

            <div class="form-group">
                <label>SRID (Coordinate System)</label>
                <input type="text" name="srid" value="20137" required>
                <small>Default: 20137 (UTM zone 37S for Ethiopia)</small>
            </div>

            <div class="form-group">
                <label>Duplicate Handling</label>
                <select name="duplicate_handling">
                    <option value="append">Append (keep existing, add new)</option>
                    <option value="replace">Replace (drop and recreate table)</option>
                    <option value="create">Create new table (rename required)</option>
                </select>
            </div>

            <button type="submit" class="btn btn-primary">Import Shapefile</button>
        </form>

        <div style="margin-top: 30px;">
            <h3>Manual Command Example</h3>
            <pre style="background: #f5f5f5; padding: 15px; border-radius: 5px;">
shp2pgsql -s 20137 -a your_shapefile.shp public.ugims_parcel | psql -h localhost -p 5432 -U postgres -d ugims
            </pre>
        </div>
    </div>
</body>
</html>
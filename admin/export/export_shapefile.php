<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';

$table = $_GET['table'] ?? '';
$format = $_GET['format'] ?? 'shp';

// Get database connection and config
$db = new Database();
$conn = $db->getConnection();
$db_config = $db->getConfig();

// Get table information from PostgreSQL
$stmt = $conn->prepare("
    SELECT 
        c.column_name,
        c.data_type,
        c.udt_name,
        c.character_maximum_length
    FROM information_schema.columns c
    WHERE c.table_name = ?
    ORDER BY c.ordinal_position
");
$stmt->execute([$table]);
$columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (empty($columns)) {
    die("Table '$table' not found in database");
}

// Get geometry column information
$geom_stmt = $conn->prepare("
    SELECT f_geometry_column, type, srid 
    FROM geometry_columns 
    WHERE f_table_name = ?
");
$geom_stmt->execute([$table]);
$geom_info = $geom_stmt->fetch(PDO::FETCH_ASSOC);

if (!$geom_info) {
    die("Table '$table' has no geometry column");
}

$geometry_column = $geom_info['f_geometry_column'];
$geometry_type = $geom_info['type'];
$srid = $geom_info['srid'];

// Create temporary directory
$temp_dir = sys_get_temp_dir() . '/export_' . uniqid();
if (!mkdir($temp_dir)) {
    die("Failed to create temporary directory");
}

try {
    if ($format == 'csv') {
        exportCSV($temp_dir, $table, $columns, $conn);
    } elseif ($format == 'geojson') {
        exportGeoJSON($temp_dir, $table, $columns, $geometry_column, $srid, $conn);
    } else {
        // Export as shapefile using pgsql2shp
        exportShapefilePostgreSQL($temp_dir, $table, $geometry_column, $db_config);
    }
} catch (Exception $e) {
    cleanup($temp_dir);
    die('Error creating export: ' . $e->getMessage());
}

function exportShapefilePostgreSQL($temp_dir, $table, $geometry_column, $db_config) {
    // Full path to pgsql2shp.exe in XAMPP PostgreSQL installation
    $pgsql2shp = 'C:\xampp\pgsql\16\bin\pgsql2shp.exe';
    
    if (!file_exists($pgsql2shp)) {
        throw new Exception("pgsql2shp not found at: $pgsql2shp");
    }
    
    $output_file = $temp_dir . '/' . $table;
    
    // Build command according to the help output
    $cmd = sprintf(
        '"%s" -h %s -p %s -u %s -P %s -f "%s" %s "%s"',
        $pgsql2shp,
        $db_config['host'],
        $db_config['port'],
        $db_config['user'],
        $db_config['password'],
        $output_file,
        $db_config['dbname'],
        $table
    );
    
    // Execute command and capture output
    $output = [];
    $return_var = 0;
    exec($cmd . ' 2>&1', $output, $return_var);
    
    // Check if command succeeded
    if ($return_var !== 0 || !file_exists($output_file . '.shp')) {
        // Try alternative format with -g geometry column
        $cmd2 = sprintf(
            '"%s" -h %s -p %s -u %s -P %s -g %s -f "%s" %s "%s"',
            $pgsql2shp,
            $db_config['host'],
            $db_config['port'],
            $db_config['user'],
            $db_config['password'],
            $geometry_column,
            $output_file,
            $db_config['dbname'],
            $table
        );
        
        exec($cmd2 . ' 2>&1', $output, $return_var);
        
        if ($return_var !== 0 || !file_exists($output_file . '.shp')) {
            throw new Exception("pgsql2shp failed: " . implode("\n", array_slice($output, -5)));
        }
    }
    
    // Verify shapefile was created
    if (!file_exists($output_file . '.shp')) {
        throw new Exception("Shapefile was not created");
    }
    
    // Create README
    $readme = $temp_dir . '/README.txt';
    $readme_content = "Shapefile Export from UGIMS\n" .
                      "============================\n\n" .
                      "Table: $table\n" .
                      "Geometry Column: $geometry_column\n" .
                      "Geometry Type: $geometry_type\n" .
                      "Coordinate System: EPSG:$srid\n" .
                      "Export Date: " . date('Y-m-d H:i:s') . "\n\n" .
                      "Files included:\n" .
                      "- {$table}.shp (geometry)\n" .
                      "- {$table}.shx (index)\n" .
                      "- {$table}.dbf (attributes)\n" .
                      "- {$table}.prj (projection)\n\n" .
                      "This shapefile was exported directly from your PostgreSQL database\n" .
                      "using pgsql2shp (PostGIS utility).\n";
    
    file_put_contents($readme, $readme_content);
    
    // Create ZIP with all shapefile components
    $zip_file = $temp_dir . '/' . $table . '_shapefile.zip';
    $zip = new ZipArchive();
    if ($zip->open($zip_file, ZipArchive::CREATE) !== true) {
        throw new Exception("Cannot create ZIP file");
    }
    
    // Add all shapefile components
    $extensions = ['.shp', '.shx', '.dbf', '.prj'];
    $files_added = 0;
    foreach ($extensions as $ext) {
        $file = $output_file . $ext;
        if (file_exists($file)) {
            $zip->addFile($file, $table . $ext);
            $files_added++;
        }
    }
    
    if ($files_added == 0) {
        throw new Exception("No shapefile components were created");
    }
    
    $zip->addFile($readme, 'README.txt');
    $zip->close();
    
    // Serve file
    header('Content-Type: application/zip');
    header('Content-Disposition: attachment; filename="' . $table . '_shapefile.zip"');
    header('Content-Length: ' . filesize($zip_file));
    header('Cache-Control: no-cache');
    readfile($zip_file);
}

function exportCSV($temp_dir, $table, $columns, $conn) {
    $filename = $table . '_export.csv';
    $filepath = $temp_dir . '/' . $filename;
    
    // Get all data from table
    $stmt = $conn->prepare("SELECT * FROM \"$table\"");
    $stmt->execute();
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $fp = fopen($filepath, 'w');
    
    // Write headers
    $headers = array_column($columns, 'column_name');
    fputcsv($fp, $headers);
    
    // Write data
    foreach ($data as $row) {
        // Clean up any binary data
        foreach ($row as $key => $value) {
            if (is_resource($value)) {
                $row[$key] = '[BINARY DATA]';
            } elseif ($value === null) {
                $row[$key] = '';
            }
        }
        fputcsv($fp, $row);
    }
    
    fclose($fp);
    
    // Create ZIP
    $zip_file = $temp_dir . '/' . $table . '_export.zip';
    $zip = new ZipArchive();
    $zip->open($zip_file, ZipArchive::CREATE);
    $zip->addFile($filepath, $filename);
    $zip->close();
    
    // Serve file
    header('Content-Type: application/zip');
    header('Content-Disposition: attachment; filename="' . $table . '_export.zip"');
    header('Content-Length: ' . filesize($zip_file));
    readfile($zip_file);
}

function exportGeoJSON($temp_dir, $table, $columns, $geometry_column, $srid, $conn) {
    $filename = $table . '_export.geojson';
    $filepath = $temp_dir . '/' . $filename;
    
    // Get all data with geometry as GeoJSON
    $stmt = $conn->prepare("
        SELECT *, ST_AsGeoJSON($geometry_column) as geom_json 
        FROM \"$table\"
    ");
    $stmt->execute();
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $geojson = [
        'type' => 'FeatureCollection',
        'name' => $table,
        'crs' => [
            'type' => 'name',
            'properties' => [
                'name' => 'urn:ogc:def:crs:EPSG::' . $srid
            ]
        ],
        'features' => []
    ];
    
    foreach ($data as $row) {
        $geometry = json_decode($row['geom_json'], true);
        unset($row['geom_json']);
        
        // Clean up any binary fields
        foreach ($row as $key => $value) {
            if (is_resource($value)) {
                $row[$key] = null;
            }
        }
        
        $feature = [
            'type' => 'Feature',
            'properties' => $row,
            'geometry' => $geometry
        ];
        $geojson['features'][] = $feature;
    }
    
    file_put_contents($filepath, json_encode($geojson, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
    
    // Create ZIP
    $zip_file = $temp_dir . '/' . $table . '_export.zip';
    $zip = new ZipArchive();
    $zip->open($zip_file, ZipArchive::CREATE);
    $zip->addFile($filepath, $filename);
    $zip->close();
    
    // Serve file
    header('Content-Type: application/zip');
    header('Content-Disposition: attachment; filename="' . $table . '_export.zip"');
    header('Content-Length: ' . filesize($zip_file));
    readfile($zip_file);
}

function cleanup($dir) {
    if (file_exists($dir)) {
        $files = glob($dir . '/*');
        foreach ($files as $file) {
            if (is_file($file)) {
                unlink($file);
            }
        }
        rmdir($dir);
    }
}
?>
<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

// Correct path to database.php - go up two levels from admin/import/
require_once '../../api/config/database.php';

$type = $_GET['type'] ?? 'parcel';

// Define schema for each type
$schemas = [
    'parcel' => [
        'fields' => [
            ['name' => 'PARCEL_NO', 'type' => 'character', 'length' => 50],
            ['name' => 'REG_NO', 'type' => 'character', 'length' => 50],
            ['name' => 'LAND_USE', 'type' => 'integer', 'length' => 4],
            ['name' => 'OWNERSHIP', 'type' => 'integer', 'length' => 4],
            ['name' => 'OWNER_NAME', 'type' => 'character', 'length' => 255],
            ['name' => 'OWNER_ID', 'type' => 'character', 'length' => 50],
            ['name' => 'OWNER_CONT', 'type' => 'character', 'length' => 100],
            ['name' => 'REGION_ID', 'type' => 'integer', 'length' => 4],
            ['name' => 'CITY_ID', 'type' => 'integer', 'length' => 4],
            ['name' => 'Woreda_ID', 'type' => 'integer', 'length' => 4],
            ['name' => 'STREET', 'type' => 'character', 'length' => 255],
            ['name' => 'HOUSE_NO', 'type' => 'character', 'length' => 50],
            ['name' => 'LANDMARK', 'type' => 'character', 'length' => 255],
            ['name' => 'REG_DATE', 'type' => 'date', 'length' => 8],
            ['name' => 'ACCURACY', 'type' => 'character', 'length' => 50],
            ['name' => 'SURV_DATE', 'type' => 'date', 'length' => 8],
            ['name' => 'SURV_METH', 'type' => 'character', 'length' => 100]
        ],
        'filename' => 'parcel_template'
    ],
    'ugi' => [
        'fields' => [
            ['name' => 'UGI_NAME', 'type' => 'character', 'length' => 255],
            ['name' => 'AMH_NAME', 'type' => 'character', 'length' => 255],
            ['name' => 'UGI_TYPE', 'type' => 'integer', 'length' => 4],
            ['name' => 'PARCEL_ID', 'type' => 'character', 'length' => 36], // UUID
            ['name' => 'CONDITION', 'type' => 'integer', 'length' => 4],
            ['name' => 'OPER_STAT', 'type' => 'integer', 'length' => 4],
            ['name' => 'LIGHTING', 'type' => 'logical', 'length' => 1],
            ['name' => 'IRRIGAT', 'type' => 'logical', 'length' => 1],
            ['name' => 'FENCING', 'type' => 'logical', 'length' => 1],
            ['name' => 'VISIT_CAP', 'type' => 'integer', 'length' => 8],
            ['name' => 'CONTACT_P', 'type' => 'character', 'length' => 255],
            ['name' => 'CONTACT_PH', 'type' => 'character', 'length' => 50],
            ['name' => 'CONTACT_EM', 'type' => 'character', 'length' => 100],
            ['name' => 'TREE_CNT', 'type' => 'integer', 'length' => 8]
        ],
        'filename' => 'ugi_template'
    ]
];

$schema = $schemas[$type];

// Create temporary directory
$temp_dir = sys_get_temp_dir() . '/shapefile_export_' . uniqid();
mkdir($temp_dir);

try {
    // Create a simple CSV first
    $csv_file = $temp_dir . '/' . $schema['filename'] . '_template.csv';
    $fp = fopen($csv_file, 'w');
    
    // Write headers
    $headers = array_column($schema['fields'], 'name');
    fputcsv($fp, $headers);
    
    // Write one sample row with instructions
    $sample = [];
    foreach ($schema['fields'] as $field) {
        if ($field['type'] == 'character') {
            $sample[] = 'Example value';
        } elseif ($field['type'] == 'integer') {
            $sample[] = '1';
        } elseif ($field['type'] == 'date') {
            $sample[] = '2024-01-01';
        } elseif ($field['type'] == 'logical') {
            $sample[] = 'true';
        } else {
            $sample[] = '';
        }
    }
    fputcsv($fp, $sample);
    fclose($fp);
    
    // Create README file
    $fp = fopen($temp_dir . '/README.txt', 'w');
    fwrite($fp, "UGIMS Shapefile Template - " . strtoupper($type) . "\n");
    fwrite($fp, "================================\n\n");
    fwrite($fp, "Field Descriptions:\n");
    foreach ($schema['fields'] as $field) {
        fwrite($fp, sprintf("  %-15s : %s\n", $field['name'], getFieldDescription($field['name'], $type)));
    }
    fwrite($fp, "\n\nCoordinate System: EPSG:20137 (UTM zone 37S)\n");
    fwrite($fp, "Geometry Type: Polygon\n\n");
    fwrite($fp, "Instructions:\n");
    fwrite($fp, "1. Create a shapefile with the fields listed above\n");
    fwrite($fp, "2. Use the CSV file as a guide for field names and data types\n");
    fwrite($fp, "3. Draw polygons in UTM zone 37S coordinates\n");
    fwrite($fp, "4. Save and ZIP all shapefile components (.shp, .shx, .dbf, .prj)\n");
    fwrite($fp, "5. Upload the ZIP file through the import interface\n");
    fclose($fp);
    
    // Create ZIP archive
    $zip_file = $temp_dir . '/' . $schema['filename'] . '_template.zip';
    $zip = new ZipArchive();
    $zip->open($zip_file, ZipArchive::CREATE);
    $zip->addFile($csv_file, $schema['filename'] . '_template.csv');
    $zip->addFile($temp_dir . '/README.txt', 'README.txt');
    $zip->close();
    
    // Serve the ZIP file
    header('Content-Type: application/zip');
    header('Content-Disposition: attachment; filename="' . $schema['filename'] . '_template.zip"');
    header('Content-Length: ' . filesize($zip_file));
    readfile($zip_file);
    
    // Clean up
    unlink($csv_file);
    unlink($temp_dir . '/README.txt');
    unlink($zip_file);
    rmdir($temp_dir);
    
} catch (Exception $e) {
    // Clean up on error
    if (file_exists($temp_dir)) {
        array_map('unlink', glob($temp_dir . '/*'));
        rmdir($temp_dir);
    }
    die('Error creating template: ' . $e->getMessage());
}

function getFieldDescription($field, $type) {
    $descriptions = [
        'parcel' => [
            'PARCEL_NO' => 'Unique parcel identifier (required)',
            'REG_NO' => 'Official registration number',
            'LAND_USE' => 'Land use type ID (see lookup table)',
            'OWNERSHIP' => 'Ownership type ID (see lookup table)',
            'OWNER_NAME' => 'Name of owner',
            'OWNER_ID' => 'Owner ID number',
            'OWNER_CONT' => 'Owner contact info',
            'REGION_ID' => 'Region ID',
            'CITY_ID' => 'City ID',
            'Woreda_ID' => 'Woreda ID',
            'STREET' => 'Street name',
            'HOUSE_NO' => 'House number',
            'LANDMARK' => 'Nearby landmark',
            'REG_DATE' => 'Registration date (YYYY-MM-DD)',
            'ACCURACY' => 'Spatial accuracy (e.g., High, Medium)',
            'SURV_DATE' => 'Survey date',
            'SURV_METH' => 'Survey method (GPS, Digitized, etc.)'
        ],
        'ugi' => [
            'UGI_NAME' => 'Name of the green infrastructure asset (required)',
            'AMH_NAME' => 'Name in Amharic',
            'UGI_TYPE' => 'UGI type ID (see lookup table)',
            'PARCEL_ID' => 'UUID of containing parcel (required)',
            'CONDITION' => 'Condition status ID',
            'OPER_STAT' => 'Operational status ID',
            'LIGHTING' => 'Has lighting (true/false)',
            'IRRIGAT' => 'Has irrigation (true/false)',
            'FENCING' => 'Has fencing (true/false)',
            'VISIT_CAP' => 'Visitor capacity',
            'CONTACT_P' => 'Contact person name',
            'CONTACT_PH' => 'Contact phone',
            'CONTACT_EM' => 'Contact email',
            'TREE_CNT' => 'Number of trees'
        ]
    ];
    return $descriptions[$type][$field] ?? 'No description available';
}
?>
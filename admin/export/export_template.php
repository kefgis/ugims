<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$type = $_GET['type'] ?? 'parcel';

// Fetch all lookup values for the selected type
$lookup_data = [];

if ($type == 'parcel') {
    // Fetch land use types
    $lookup_data['land_use'] = $db->query("
        SELECT land_use_id, land_use_name, land_use_category 
        FROM lkp_land_use_type 
        ORDER BY land_use_id
    ")->fetchAll(PDO::FETCH_ASSOC);
    
    // Fetch ownership types
    $lookup_data['ownership'] = $db->query("
        SELECT ownership_id, ownership_name 
        FROM lkp_ownership_type 
        ORDER BY ownership_id
    ")->fetchAll(PDO::FETCH_ASSOC);
    
    // Fetch regions
    $lookup_data['regions'] = $db->query("
        SELECT region_id, region_name, region_code 
        FROM lkq_region 
        ORDER BY region_id
    ")->fetchAll(PDO::FETCH_ASSOC);
    
    // Fetch cities
    $lookup_data['cities'] = $db->query("
        SELECT city_id, city_name, region_id 
        FROM lkq_city 
        ORDER BY city_id
    ")->fetchAll(PDO::FETCH_ASSOC);
    
    // Fetch subcities
    $lookup_data['subcities'] = $db->query("
        SELECT subcity_id, subcity_name, city_id 
        FROM lkq_subcity 
        ORDER BY subcity_id
    ")->fetchAll(PDO::FETCH_ASSOC);
    
    // Fetch woredas
    $lookup_data['woredas'] = $db->query("
        SELECT woreda_id, woreda_name, woreda_number, subcity_id 
        FROM lkq_woreda 
        ORDER BY woreda_id
    ")->fetchAll(PDO::FETCH_ASSOC);
    
    // Fetch kebeles
    $lookup_data['kebeles'] = $db->query("
        SELECT kebele_id, kebele_number, kebele_name, woreda_id 
        FROM lkq_kebele 
        ORDER BY kebele_id
    ")->fetchAll(PDO::FETCH_ASSOC);
    
} elseif ($type == 'ugi') {
    // Fetch UGI types
    $lookup_data['ugi_types'] = $db->query("
        SELECT ugi_type_id, type_name, type_category, amharic_name 
        FROM lkp_ethiopia_ugi_type 
        ORDER BY ugi_type_id
    ")->fetchAll(PDO::FETCH_ASSOC);
    
    // Fetch condition statuses
    $lookup_data['conditions'] = $db->query("
        SELECT status_id, status_name, status_code 
        FROM lkp_condition_status 
        ORDER BY status_id
    ")->fetchAll(PDO::FETCH_ASSOC);
    
    // Fetch operational statuses
    $lookup_data['operational'] = $db->query("
        SELECT status_id, status_name, status_code 
        FROM lkp_operational_status 
        ORDER BY status_id
    ")->fetchAll(PDO::FETCH_ASSOC);
    
    // Fetch accessibility types
    $lookup_data['accessibility'] = $db->query("
        SELECT access_id, access_name 
        FROM lkp_accessibility_type 
        ORDER BY access_id
    ")->fetchAll(PDO::FETCH_ASSOC);
    
    // Fetch sample parcels for parcel_id reference
    $lookup_data['sample_parcels'] = $db->query("
        SELECT parcel_id, parcel_number 
        FROM ugims_parcel 
        ORDER BY parcel_number 
        LIMIT 10
    ")->fetchAll(PDO::FETCH_ASSOC);
}

// Define field structures
$schemas = [
    'parcel' => [
        'filename' => 'parcel_template',
        'description' => 'Land Parcel Template',
        'fields' => [
            'parcel_number' => [
                'type' => 'character',
                'length' => 50,
                'required' => true,
                'description' => 'Unique parcel identifier',
                'sample' => 'PARC-2024-001'
            ],
            'parcel_registration_number' => [
                'type' => 'character',
                'length' => 50,
                'required' => false,
                'description' => 'Official registration number',
                'sample' => 'REG/2024/12345'
            ],
            'land_use_type_id' => [
                'type' => 'integer',
                'length' => 4,
                'required' => false,
                'description' => 'Land use type ID (see Land Use Types sheet)',
                'sample' => '7',
                'lookup' => 'land_use'
            ],
            'ownership_type_id' => [
                'type' => 'integer',
                'length' => 4,
                'required' => false,
                'description' => 'Ownership type ID (see Ownership Types sheet)',
                'sample' => '3',
                'lookup' => 'ownership'
            ],
            'owner_name' => [
                'type' => 'character',
                'length' => 255,
                'required' => false,
                'description' => 'Name of owner',
                'sample' => 'Addis Ababa City Administration'
            ],
            'owner_id_number' => [
                'type' => 'character',
                'length' => 50,
                'required' => false,
                'description' => 'Owner ID number',
                'sample' => 'ID-12345-AA'
            ],
            'owner_contact' => [
                'type' => 'character',
                'length' => 100,
                'required' => false,
                'description' => 'Owner contact information',
                'sample' => '+251-11-123-4567'
            ],
            'region_id' => [
                'type' => 'integer',
                'length' => 4,
                'required' => false,
                'description' => 'Region ID (see Regions sheet)',
                'sample' => '1',
                'lookup' => 'regions'
            ],
            'city_id' => [
                'type' => 'integer',
                'length' => 4,
                'required' => false,
                'description' => 'City ID (see Cities sheet)',
                'sample' => '1',
                'lookup' => 'cities'
            ],
            'subcity_id' => [
                'type' => 'integer',
                'length' => 4,
                'required' => false,
                'description' => 'Sub-city ID (see Sub-cities sheet)',
                'sample' => '101',
                'lookup' => 'subcities'
            ],
            'woreda_id' => [
                'type' => 'integer',
                'length' => 4,
                'required' => false,
                'description' => 'Woreda ID (see Woredas sheet)',
                'sample' => '1001',
                'lookup' => 'woredas'
            ],
            'kebele_id' => [
                'type' => 'integer',
                'length' => 4,
                'required' => false,
                'description' => 'Kebele ID (see Kebeles sheet)',
                'sample' => '10001',
                'lookup' => 'kebeles'
            ],
            'street_name' => [
                'type' => 'character',
                'length' => 255,
                'required' => false,
                'description' => 'Street name',
                'sample' => 'Bole Road'
            ],
            'house_number' => [
                'type' => 'character',
                'length' => 50,
                'required' => false,
                'description' => 'House number',
                'sample' => '123'
            ],
            'landmark' => [
                'type' => 'character',
                'length' => 255,
                'required' => false,
                'description' => 'Nearby landmark',
                'sample' => 'Near Mexico Square'
            ],
            'registration_date' => [
                'type' => 'date',
                'length' => 8,
                'required' => false,
                'description' => 'Registration date (YYYY-MM-DD)',
                'sample' => '2024-01-15'
            ],
            'area_sq_m' => [
                'type' => 'numeric',
                'length' => 12,
                'required' => false,
                'description' => 'Area in square meters',
                'sample' => '1250.50'
            ],
            'spatial_accuracy' => [
                'type' => 'character',
                'length' => 50,
                'required' => false,
                'description' => 'Spatial accuracy (High, Medium, Low)',
                'sample' => 'High'
            ],
            'survey_date' => [
                'type' => 'date',
                'length' => 8,
                'required' => false,
                'description' => 'Survey date',
                'sample' => '2023-12-10'
            ],
            'survey_method' => [
                'type' => 'character',
                'length' => 100,
                'required' => false,
                'description' => 'Survey method (GPS, Digitized, Total Station)',
                'sample' => 'GPS'
            ]
        ]
    ],
    'ugi' => [
        'filename' => 'ugi_template',
        'description' => 'UGI Asset Template',
        'fields' => [
            'name' => [
                'type' => 'character',
                'length' => 255,
                'required' => true,
                'description' => 'UGI asset name',
                'sample' => 'Friendship Park'
            ],
            'amharic_name' => [
                'type' => 'character',
                'length' => 255,
                'required' => false,
                'description' => 'Name in Amharic',
                'sample' => 'የጓደኝነት ፓርክ'
            ],
            'ugi_type_id' => [
                'type' => 'integer',
                'length' => 4,
                'required' => true,
                'description' => 'UGI type ID (see UGI Types sheet)',
                'sample' => '1',
                'lookup' => 'ugi_types'
            ],
            'parcel_id' => [
                'type' => 'uuid',
                'length' => 36,
                'required' => true,
                'description' => 'Parcel UUID (see Sample Parcels sheet)',
                'sample' => !empty($lookup_data['sample_parcels']) ? $lookup_data['sample_parcels'][0]['parcel_id'] : '123e4567-e89b-12d3-a456-426614174000'
            ],
            'condition_status_id' => [
                'type' => 'integer',
                'length' => 4,
                'required' => false,
                'description' => 'Condition status ID (see Conditions sheet)',
                'sample' => '2',
                'lookup' => 'conditions'
            ],
            'operational_status_id' => [
                'type' => 'integer',
                'length' => 4,
                'required' => false,
                'description' => 'Operational status ID (see Operational Status sheet)',
                'sample' => '1',
                'lookup' => 'operational'
            ],
            'has_lighting' => [
                'type' => 'boolean',
                'length' => 1,
                'required' => false,
                'description' => 'Has lighting (true/false)',
                'sample' => 'true'
            ],
            'has_irrigation' => [
                'type' => 'boolean',
                'length' => 1,
                'required' => false,
                'description' => 'Has irrigation (true/false)',
                'sample' => 'false'
            ],
            'has_fencing' => [
                'type' => 'boolean',
                'length' => 1,
                'required' => false,
                'description' => 'Has fencing (true/false)',
                'sample' => 'true'
            ],
            'accessibility_type_id' => [
                'type' => 'integer',
                'length' => 4,
                'required' => false,
                'description' => 'Accessibility type ID (see Accessibility sheet)',
                'sample' => '1',
                'lookup' => 'accessibility'
            ],
            'visitor_capacity' => [
                'type' => 'integer',
                'length' => 8,
                'required' => false,
                'description' => 'Estimated visitor capacity',
                'sample' => '500'
            ],
            'contact_person' => [
                'type' => 'character',
                'length' => 255,
                'required' => false,
                'description' => 'Contact person name',
                'sample' => 'Abebe Kebede'
            ],
            'contact_phone' => [
                'type' => 'character',
                'length' => 50,
                'required' => false,
                'description' => 'Contact phone number',
                'sample' => '+251-911-123-456'
            ],
            'contact_email' => [
                'type' => 'character',
                'length' => 100,
                'required' => false,
                'description' => 'Contact email',
                'sample' => 'park.manager@example.com'
            ],
            'tree_count' => [
                'type' => 'integer',
                'length' => 8,
                'required' => false,
                'description' => 'Number of trees',
                'sample' => '120'
            ],
            'area_sq_m' => [
                'type' => 'numeric',
                'length' => 12,
                'required' => false,
                'description' => 'Area in square meters',
                'sample' => '25000.00'
            ],
            'establishment_date' => [
                'type' => 'date',
                'length' => 8,
                'required' => false,
                'description' => 'Establishment date',
                'sample' => '2010-05-20'
            ],
            'last_inspected_date' => [
                'type' => 'date',
                'length' => 8,
                'required' => false,
                'description' => 'Last inspection date',
                'sample' => '2024-02-15'
            ]
        ]
    ]
];

$schema = $schemas[$type];

// Create temporary directory
$temp_dir = sys_get_temp_dir() . '/template_export_' . uniqid();
mkdir($temp_dir);

try {
    // Create main data CSV
    $csv_file = $temp_dir . '/' . $schema['filename'] . '_data.csv';
    $fp = fopen($csv_file, 'w');
    
    // Write headers
    $headers = array_keys($schema['fields']);
    fputcsv($fp, $headers);
    
    // Generate multiple sample rows with realistic data
    $sample_rows = generateSampleRows($type, $lookup_data, 20); // Generate 20 sample rows
    
    foreach ($sample_rows as $row) {
        fputcsv($fp, $row);
    }
    
    fclose($fp);
    
    // Create lookup value sheets (as separate CSV files)
    if ($type == 'parcel') {
        createLookupCSV($temp_dir, 'land_use_types', ['ID', 'Name', 'Category'], $lookup_data['land_use'] ?? []);
        createLookupCSV($temp_dir, 'ownership_types', ['ID', 'Name'], $lookup_data['ownership'] ?? []);
        createLookupCSV($temp_dir, 'regions', ['ID', 'Name', 'Code'], $lookup_data['regions'] ?? []);
        createLookupCSV($temp_dir, 'cities', ['ID', 'Name', 'Region ID'], $lookup_data['cities'] ?? []);
        createLookupCSV($temp_dir, 'subcities', ['ID', 'Name', 'City ID'], $lookup_data['subcities'] ?? []);
        createLookupCSV($temp_dir, 'woredas', ['ID', 'Name', 'Number', 'Subcity ID'], $lookup_data['woredas'] ?? []);
        createLookupCSV($temp_dir, 'kebeles', ['ID', 'Number', 'Name', 'Woreda ID'], $lookup_data['kebeles'] ?? []);
    } elseif ($type == 'ugi') {
        createLookupCSV($temp_dir, 'ugi_types', ['ID', 'Type Name', 'Category', 'Amharic Name'], $lookup_data['ugi_types'] ?? []);
        createLookupCSV($temp_dir, 'conditions', ['ID', 'Status Name', 'Code'], $lookup_data['conditions'] ?? []);
        createLookupCSV($temp_dir, 'operational_status', ['ID', 'Status Name', 'Code'], $lookup_data['operational'] ?? []);
        createLookupCSV($temp_dir, 'accessibility_types', ['ID', 'Access Name'], $lookup_data['accessibility'] ?? []);
        
        if (!empty($lookup_data['sample_parcels'])) {
            createLookupCSV($temp_dir, 'sample_parcels', ['Parcel ID', 'Parcel Number'], $lookup_data['sample_parcels']);
        }
    }
    
    // Create comprehensive README
    $readme = $temp_dir . '/README.txt';
    $rp = fopen($readme, 'w');
    fwrite($rp, $schema['description'] . "\n");
    fwrite($rp, str_repeat("=", 50) . "\n\n");
    
    fwrite($rp, "FILE STRUCTURE\n");
    fwrite($rp, "--------------\n");
    fwrite($rp, "1. {$schema['filename']}_data.csv - Main data file with " . count($sample_rows) . " sample rows\n");
    fwrite($rp, "2. Multiple lookup CSV files - Reference tables with valid ID values\n\n");
    
    fwrite($rp, "FIELD DESCRIPTIONS\n");
    fwrite($rp, "------------------\n");
    foreach ($schema['fields'] as $field => $def) {
        $required = $def['required'] ? 'REQUIRED' : 'optional';
        fwrite($rp, sprintf("%-25s : %s (%s)\n", $field, $def['description'], $required));
        fwrite($rp, sprintf("%-25s   Example: %s\n", '', $def['sample']));
        if (isset($def['lookup'])) {
            fwrite($rp, sprintf("%-25s   See %s.csv for valid values\n", '', $def['lookup']));
        }
        fwrite($rp, "\n");
    }
    
    fwrite($rp, "\nIMPORTANT NOTES\n");
    fwrite($rp, "---------------\n");
    fwrite($rp, "1. Coordinate System: EPSG:20137 (UTM zone 37S for Ethiopia)\n");
    fwrite($rp, "2. Geometry Type: Polygon/MultiPolygon\n");
    fwrite($rp, "3. Use the sample rows as a guide for data format\n");
    fwrite($rp, "4. All ID fields must reference existing values in lookup tables\n");
    fwrite($rp, "5. Boolean fields accept: true/false, 1/0, yes/no\n");
    fwrite($rp, "6. Date format: YYYY-MM-DD\n");
    fwrite($rp, "7. UUID format: 123e4567-e89b-12d3-a456-426614174000\n\n");
    
    fwrite($rp, "INSTRUCTIONS\n");
    fwrite($rp, "------------\n");
    fwrite($rp, "1. Review the lookup CSV files to understand valid ID values\n");
    fwrite($rp, "2. Use the sample rows as templates for your data\n");
    fwrite($rp, "3. Create your shapefile with the same field names\n");
    fwrite($rp, "4. Ensure geometry is in EPSG:20137\n");
    fwrite($rp, "5. Save all shapefile components (.shp, .shx, .dbf, .prj)\n");
    fwrite($rp, "6. ZIP all files and upload through the import interface\n");
    
    fclose($rp);
    
    // Create ZIP archive with all files
    $zip_file = $temp_dir . '/' . $schema['filename'] . '_complete_template.zip';
    $zip = new ZipArchive();
    $zip->open($zip_file, ZipArchive::CREATE);
    
    // Add all CSV files
    $files = glob($temp_dir . '/*.csv');
    foreach ($files as $file) {
        $zip->addFile($file, basename($file));
    }
    $zip->addFile($readme, 'README.txt');
    $zip->close();
    
    // Serve the ZIP file
    header('Content-Type: application/zip');
    header('Content-Disposition: attachment; filename="' . $schema['filename'] . '_complete_template.zip"');
    header('Content-Length: ' . filesize($zip_file));
    header('Cache-Control: no-cache');
    readfile($zip_file);
    
    // Clean up
    cleanup($temp_dir);
    
} catch (Exception $e) {
    cleanup($temp_dir);
    die('Error creating template: ' . $e->getMessage());
}

/**
 * Generate multiple sample rows with realistic data
 */
function generateSampleRows($type, $lookup_data, $count = 20) {
    $rows = [];
    
    if ($type == 'parcel') {
        $parcel_numbers = ['PARC-2024-001', 'PARC-2024-002', 'PARC-2024-003', 'PARC-2024-004', 'PARC-2024-005'];
        $owners = ['Addis Ababa City Administration', 'Ministry of Urban Development', 'Ethiopian Railway Corporation', 'Private Owner', 'Community Association'];
        $streets = ['Bole Road', 'Churchill Avenue', 'Mexico Square', 'Africa Avenue', 'Gotera Road'];
        
        for ($i = 0; $i < $count; $i++) {
            $row = [];
            $row[] = $parcel_numbers[$i % count($parcel_numbers)] . '-' . str_pad($i + 1, 3, '0', STR_PAD_LEFT);
            $row[] = 'REG/' . date('Y') . '/' . str_pad(rand(1000, 9999), 4, '0', STR_PAD_LEFT);
            $row[] = rand(1, 15); // land_use_type_id
            $row[] = rand(1, 11); // ownership_type_id
            $row[] = $owners[$i % count($owners)];
            $row[] = 'ID-' . rand(10000, 99999);
            $row[] = '+251-11-' . rand(100, 999) . '-' . rand(1000, 9999);
            $row[] = 1; // region_id (Addis Ababa)
            $row[] = 1; // city_id (Addis Ababa)
            $row[] = rand(101, 110); // subcity_id
            $row[] = rand(1001, 1010); // woreda_id
            $row[] = rand(10001, 10010); // kebele_id
            $row[] = $streets[$i % count($streets)];
            $row[] = (string) rand(1, 999);
            $row[] = 'Near ' . ['Mexico', 'Bole', 'Piazza', 'Merkato', 'Kazanchis'][$i % 5];
            $row[] = date('Y-m-d', strtotime('-' . rand(0, 365) . ' days'));
            $row[] = round(rand(500, 5000) + rand(0, 99) / 100, 2);
            $row[] = ['High', 'Medium', 'Low'][$i % 3];
            $row[] = date('Y-m-d', strtotime('-' . rand(30, 730) . ' days'));
            $row[] = ['GPS', 'Total Station', 'Digitized', 'Field Survey'][$i % 4];
            $rows[] = $row;
        }
    } elseif ($type == 'ugi') {
        $names = ['Friendship Park', 'Addis Stadium', 'Children\'s Playground', 'Bole Roundabout', 'Mexico Square Garden', 
                  'University Arboretum', 'City Sport Field', 'Riverside Park', 'Community Garden', 'Botanical Garden'];
        $amharic_names = ['የጓደኝነት ፓርክ', 'አዲስ ስታዲየም', 'የልጆች መጫወቻ', 'ቦሌ ክብ መንገድ', 'ሜክሲኮ አደባባይ ጋርደን',
                         'ዩኒቨርሲቲ አርቦሬተም', 'ከተማ ስፖርት ሜዳ', 'ወንዝ ዳር ፓርክ', 'ማህበረሰብ አትክልት', 'እፅዋት አትክልት'];
        
        for ($i = 0; $i < $count; $i++) {
            $row = [];
            $row[] = $names[$i % count($names)] . ' ' . ($i + 1);
            $row[] = $amharic_names[$i % count($amharic_names)];
            $row[] = rand(1, 15); // ugi_type_id
            $row[] = !empty($lookup_data['sample_parcels'][$i % count($lookup_data['sample_parcels'])]['parcel_id']) 
                    ? $lookup_data['sample_parcels'][$i % count($lookup_data['sample_parcels'])]['parcel_id'] 
                    : '123e4567-e89b-12d3-a456-426614174000';
            $row[] = rand(1, 5); // condition_status_id
            $row[] = rand(1, 3); // operational_status_id
            $row[] = rand(0, 1) ? 'true' : 'false'; // has_lighting
            $row[] = rand(0, 1) ? 'true' : 'false'; // has_irrigation
            $row[] = rand(0, 1) ? 'true' : 'false'; // has_fencing
            $row[] = rand(1, 7); // accessibility_type_id
            $row[] = rand(100, 5000); // visitor_capacity
            $row[] = ['Abebe Kebede', 'Tigist Haile', 'Alemu Tadesse', 'Meron Ayele', 'Yonas Desta'][$i % 5];
            $row[] = '+251-911-' . rand(100, 999) . '-' . rand(1000, 9999);
            $row[] = strtolower(str_replace(' ', '.', $names[$i % count($names)])) . '@example.com';
            $row[] = rand(10, 500); // tree_count
            $row[] = round(rand(1000, 50000) + rand(0, 99) / 100, 2); // area_sq_m
            $row[] = date('Y-m-d', strtotime('-' . rand(365, 3650) . ' days')); // establishment_date
            $row[] = date('Y-m-d', strtotime('-' . rand(1, 180) . ' days')); // last_inspected_date
            $rows[] = $row;
        }
    }
    
    return $rows;
}

/**
 * Create a lookup CSV file
 */
function createLookupCSV($dir, $filename, $headers, $data) {
    $filepath = $dir . '/' . $filename . '.csv';
    $fp = fopen($filepath, 'w');
    
    // Write headers
    fputcsv($fp, $headers);
    
    // Write data rows
    foreach ($data as $row) {
        fputcsv($fp, array_values($row));
    }
    
    fclose($fp);
}

/**
 * Clean up temporary directory
 */
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
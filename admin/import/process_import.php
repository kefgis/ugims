<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized']);
    exit;
}

require_once '../../api/config/database.php';
require_once '../../vendor/autoload.php';

use ShapeFile\ShapeFile;

$db = (new Database())->getConnection();

$data = json_decode(file_get_contents('php://input'), true);
$action = $data['action'] ?? $_POST['action'] ?? '';

try {
    if ($action === 'start' || $action === 'confirm') {
        $session_id = $data['session_id'];
        $mapping = $data['mapping'];
        
        // Get session info
        $stmt = $db->prepare("SELECT * FROM ugims_import_session WHERE session_id = ?");
        $stmt->execute([$session_id]);
        $session = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$session) {
            throw new Exception('Import session expired');
        }
        
        $temp_dir = $session['temp_dir'];
        $import_type = $session['import_type'];
        
        // Find shapefile
        $shp_file = null;
        foreach (scandir($temp_dir) as $file) {
            if (pathinfo($file, PATHINFO_EXTENSION) === 'shp') {
                $shp_file = $temp_dir . '/' . $file;
                break;
            }
        }
        
        if (!$shp_file) {
            throw new Exception('Shapefile not found');
        }
        
        // Read shapefile
        $shp = new ShapeFile(0);
        $base_name = pathinfo($shp_file, PATHINFO_FILENAME);
        $shp->loadFromFile($temp_dir . '/' . $base_name . '.*');
        
        // Start transaction
        $db->beginTransaction();
        
        $imported = 0;
        $failed = 0;
        $errors = [];
        
        while ($record = $shp->getRecord()) {
            try {
                $dbf_data = $record->getDbfData();
                $geometry = $record->getGeometry();
                $wkt = $geometry->getWKT();
                
                // Build insert based on mapping
                $fields = [];
                $placeholders = [];
                $values = [];
                
                foreach ($mapping as $db_field => $shape_field) {
                    if ($shape_field && isset($dbf_data[$shape_field])) {
                        $fields[] = $db_field;
                        $placeholders[] = '?';
                        
                        // Handle special conversions
                        if (in_array($db_field, ['has_lighting', 'has_irrigation', 'has_fencing'])) {
                            // Convert to boolean
                            $val = strtolower($dbf_data[$shape_field]);
                            $values[] = ($val === 'true' || $val === '1' || $val === 'yes') ? 'true' : 'false';
                        } elseif (in_array($db_field, ['registration_date', 'survey_date'])) {
                            // Convert to proper date format
                            $values[] = date('Y-m-d', strtotime($dbf_data[$shape_field]));
                        } else {
                            $values[] = $dbf_data[$shape_field];
                        }
                    }
                }
                
                // Always add geometry
                $fields[] = 'geometry';
                $placeholders[] = 'ST_GeomFromText(?, 20137)';
                $values[] = $wkt;
                
                // Build SQL
                $sql = "INSERT INTO " . ($import_type === 'parcel' ? 'ugims_parcel' : 'ugims_ugi') . " 
                        (" . implode(', ', $fields) . ", created_date, last_updated)
                        VALUES (" . implode(', ', $placeholders) . ", NOW(), NOW())";
                
                $stmt = $db->prepare($sql);
                $stmt->execute($values);
                
                $imported++;
                
            } catch (Exception $e) {
                $failed++;
                $errors[] = "Record " . ($imported + $failed) . ": " . $e->getMessage();
            }
        }
        
        $db->commit();
        
        // Log import
        $log = $db->prepare("INSERT INTO ugims_import_log 
                            (import_type, filename, records_processed, records_success, records_failed, error_log, imported_by_user_id, status)
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $log->execute([
            $import_type,
            $session['shapefile_name'],
            $imported + $failed,
            $imported,
            $failed,
            implode("\n", $errors),
            $_SESSION['user_id'],
            $failed > 0 ? 'completed_with_errors' : 'completed'
        ]);
        
        // Clean up
        array_map('unlink', glob($temp_dir . '/*'));
        rmdir($temp_dir);
        
        // Delete session
        $db->prepare("DELETE FROM ugims_import_session WHERE session_id = ?")->execute([$session_id]);
        
        echo json_encode([
            'success' => true,
            'records_imported' => $imported,
            'records_failed' => $failed,
            'errors' => $errors
        ]);
        
    } elseif ($action === 'preview') {
        // Preview logic here
        $session_id = $data['session_id'];
        $mapping = $data['mapping'];
        
        // Similar to import but without actual insert
        // Return HTML table preview
    }
    
} catch (Exception $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
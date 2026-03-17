<?php
require_once __DIR__ . '/../config/database.php';

class CitizenReport {
    private $conn;
    private $table = 'ugims_citizen_report';

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    public function create($data) {
        // Generate a report number
        $report_number = 'RPT-' . date('Ymd') . '-' . rand(1000, 9999);
        
        // Create point geometry from lat/lng
        $point_sql = "ST_SetSRID(ST_MakePoint(:lng, :lat), 20137)";
        
        $query = "INSERT INTO " . $this->table . "
                  (report_number, report_type_id, report_description, 
                   location_point, location_description, photo_urls,
                   reporter_name, reporter_email, reporter_phone, is_anonymous)
                  VALUES
                  (:report_number, :report_type_id, :description,
                   $point_sql, :location_desc, :photos,
                   :reporter_name, :email, :phone, :anonymous)";
        
        $stmt = $this->conn->prepare($query);
        
        // Bind parameters
        $stmt->bindParam(':report_number', $report_number);
        $stmt->bindParam(':report_type_id', $data['type_id']);
        $stmt->bindParam(':description', $data['description']);
        $stmt->bindParam(':lng', $data['longitude']);
        $stmt->bindParam(':lat', $data['latitude']);
        $stmt->bindParam(':location_desc', $data['location_description']);
        $stmt->bindParam(':photos', $data['photos']); // Should be JSON array
        $stmt->bindParam(':reporter_name', $data['name']);
        $stmt->bindParam(':email', $data['email']);
        $stmt->bindParam(':phone', $data['phone']);
        $stmt->bindParam(':anonymous', $data['anonymous']);
        
        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        
        return false;
    }

    public function getByStatus($status_id) {
        $query = "SELECT 
                    report_id, report_number, report_type_id,
                    report_description,
                    ST_AsGeoJSON(location_point) as geojson,
                    status_id, created_date
                  FROM " . $this->table . "
                  WHERE status_id = :status_id
                  ORDER BY created_date DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':status_id', $status_id);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
?>
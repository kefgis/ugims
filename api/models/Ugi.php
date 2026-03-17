<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../../vendor/autoload.php'; // If using Composer

use geoPHP as geoPHP;

class Ugi {
    private $conn;
    private $table = 'ugims_ugi';

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    // Get all UGI assets (with GeoJSON output for maps)
    public function getAllAsGeoJSON() {
        $query = "SELECT 
                    ugi_id,
                    name,
                    ugi_type_id,
                    ST_AsGeoJSON(geometry) as geojson,
                    area_sq_m,
                    condition_status_id
                  FROM " . $this->table;
        
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        
        $features = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $feature = [
                'type' => 'Feature',
                'id' => $row['ugi_id'],
                'geometry' => json_decode($row['geojson']),
                'properties' => [
                    'name' => $row['name'],
                    'type_id' => $row['ugi_type_id'],
                    'area' => $row['area_sq_m'],
                    'condition' => $row['condition_status_id']
                ]
            ];
            $features[] = $feature;
        }
        
        return [
            'type' => 'FeatureCollection',
            'features' => $features
        ];
    }

    // Get UGI by ID
    public function getById($ugi_id) {
        $query = "SELECT 
                    ugi_id, name, amharic_name, ugi_type_id,
                    ST_AsText(geometry) as wkt,
                    area_sq_m, has_lighting, has_irrigation,
                    condition_status_id, operational_status_id
                  FROM " . $this->table . "
                  WHERE ugi_id = :ugi_id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':ugi_id', $ugi_id);
        $stmt->execute();
        
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Find UGI within bounding box (for map panning)
    public function getInBBox($min_lng, $min_lat, $max_lng, $max_lat) {
        $query = "SELECT 
                    ugi_id, name,
                    ST_AsGeoJSON(geometry) as geojson
                  FROM " . $this->table . "
                  WHERE geometry && ST_MakeEnvelope(:min_lng, :min_lat, :max_lng, :max_lat, 20137)";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':min_lng', $min_lng);
        $stmt->bindParam(':min_lat', $min_lat);
        $stmt->bindParam(':max_lng', $max_lng);
        $stmt->bindParam(':max_lat', $max_lat);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
?>
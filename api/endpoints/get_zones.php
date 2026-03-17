<?php
header('Content-Type: application/json');
require_once '../config/database.php';

$db = (new Database())->getConnection();

// Transform geometry from 20137 to 4326 for Leaflet
$query = "SELECT 
            zone_id,
            zone_name,
            zone_code,
            priority_level,
            description,
            area_sq_m,
            ST_AsGeoJSON(ST_Transform(geometry, 4326)) as geojson
          FROM ugims_maintenance_zone";

$stmt = $db->query($query);
$features = [];

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $geometry = json_decode($row['geojson']);
    unset($row['geojson']);
    
    // Add centroid coordinates for searching
    $centroid = $db->query("SELECT ST_X(ST_Centroid(ST_Transform(geometry, 4326))) as lng, 
                                   ST_Y(ST_Centroid(ST_Transform(geometry, 4326))) as lat
                            FROM ugims_maintenance_zone 
                            WHERE zone_id = '{$row['zone_id']}'")->fetch(PDO::FETCH_ASSOC);
    
    $row['centroid_lng'] = $centroid['lng'];
    $row['centroid_lat'] = $centroid['lat'];
    
    $features[] = [
        'type' => 'Feature',
        'id' => $row['zone_id'],
        'geometry' => $geometry,
        'properties' => $row
    ];
}

echo json_encode([
    'type' => 'FeatureCollection',
    'features' => $features,
    'crs' => [
        'type' => 'name',
        'properties' => [
            'name' => 'EPSG:4326'
        ]
    ]
]);
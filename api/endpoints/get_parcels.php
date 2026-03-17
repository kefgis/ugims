<?php
header('Content-Type: application/json');
require_once '../config/database.php';

$db = (new Database())->getConnection();

// Transform geometry from 20137 to 4326 for Leaflet
$query = "SELECT 
            p.parcel_id,
            p.parcel_number,
            p.parcel_registration_number,
            p.owner_name,
            p.street_name,
            p.house_number,
            p.area_sq_m,
            l.land_use_name,
            ST_AsGeoJSON(ST_Transform(p.geometry, 4326)) as geojson
          FROM ugims_parcel p
          LEFT JOIN lkp_land_use_type l ON p.land_use_type_id = l.land_use_id";

$stmt = $db->query($query);
$features = [];

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $geometry = json_decode($row['geojson']);
    unset($row['geojson']);
    
    // Add centroid coordinates for searching
    $centroid = $db->query("SELECT ST_X(ST_Centroid(ST_Transform(p.geometry, 4326))) as lng, 
                                   ST_Y(ST_Centroid(ST_Transform(p.geometry, 4326))) as lat
                            FROM ugims_parcel p 
                            WHERE p.parcel_id = '{$row['parcel_id']}'")->fetch(PDO::FETCH_ASSOC);
    
    $row['centroid_lng'] = $centroid['lng'];
    $row['centroid_lat'] = $centroid['lat'];
    
    $features[] = [
        'type' => 'Feature',
        'id' => $row['parcel_id'],
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
<?php
header('Content-Type: application/json');
require_once '../config/database.php';

$db = (new Database())->getConnection();

$type_filter = isset($_GET['type']) && $_GET['type'] !== '' 
    ? " AND u.ugi_type_id = " . intval($_GET['type']) 
    : "";

// Transform geometry from 20137 to 4326 for Leaflet
$query = "SELECT 
            u.ugi_id,
            u.name,
            u.amharic_name,
            u.ugi_type_id,
            t.type_name,
            u.area_sq_m,
            u.condition_status_id,
            c.status_name as condition_name,
            u.operational_status_id,
            o.status_name as operational_name,
            u.has_lighting,
            u.has_irrigation,
            u.has_fencing,
            u.visitor_capacity,
            u.contact_person,
            u.contact_phone,
            u.tree_count,
            ST_AsGeoJSON(ST_Transform(u.geometry, 4326)) as geojson
          FROM ugims_ugi u
          LEFT JOIN lkp_ethiopia_ugi_type t ON u.ugi_type_id = t.ugi_type_id
          LEFT JOIN lkp_condition_status c ON u.condition_status_id = c.status_id
          LEFT JOIN lkp_operational_status o ON u.operational_status_id = o.status_id
          WHERE 1=1 $type_filter";

$stmt = $db->query($query);
$features = [];

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $geometry = json_decode($row['geojson']);
    unset($row['geojson']);
    
    // Add centroid coordinates for searching
    $centroid = $db->query("SELECT ST_X(ST_Centroid(ST_Transform(u.geometry, 4326))) as lng, 
                                   ST_Y(ST_Centroid(ST_Transform(u.geometry, 4326))) as lat
                            FROM ugims_ugi u 
                            WHERE u.ugi_id = '{$row['ugi_id']}'")->fetch(PDO::FETCH_ASSOC);
    
    $row['centroid_lng'] = $centroid['lng'];
    $row['centroid_lat'] = $centroid['lat'];
    
    $features[] = [
        'type' => 'Feature',
        'id' => $row['ugi_id'],
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
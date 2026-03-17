<?php
/**
 * Convert GeoJSON geometry to WKT for PostGIS
 * @param array $geojson Associative array decoded from JSON
 * @return string WKT representation
 */
function geojsonToWKT($geojson) {
    if (!$geojson || !isset($geojson['type'])) {
        return null;
    }
    
    $type = $geojson['type'];
    $coords = $geojson['coordinates'];
    
    switch ($type) {
        case 'Polygon':
            // Format: POLYGON((x1 y1, x2 y2, ...))
            $rings = [];
            foreach ($coords as $ring) {
                $points = [];
                foreach ($ring as $point) {
                    $points[] = $point[0] . ' ' . $point[1];
                }
                $rings[] = '(' . implode(', ', $points) . ')';
            }
            return 'POLYGON(' . implode(', ', $rings) . ')';
            
        case 'MultiPolygon':
            // More complex – we'll handle single polygon for simplicity
            // For MultiPolygon, you'd loop over polygons
            // We'll just take the first polygon for now
            if (count($coords) > 0) {
                $poly = $coords[0];
                $rings = [];
                foreach ($poly as $ring) {
                    $points = [];
                    foreach ($ring as $point) {
                        $points[] = $point[0] . ' ' . $point[1];
                    }
                    $rings[] = '(' . implode(', ', $points) . ')';
                }
                return 'POLYGON(' . implode(', ', $rings) . ')';
            }
            return null;
            
        default:
            return null;
    }
}
?>
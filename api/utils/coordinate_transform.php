<?php
/**
 * Coordinate Transformation Utility
 * Transforms between EPSG:20137 and EPSG:4326
 */

function transformToLeaflet($geometry_geojson) {
    // If no geometry, return as is
    if (!$geometry_geojson) {
        return null;
    }
    
    $geom = json_decode($geometry_geojson, true);
    if (!$geom) {
        return null;
    }
    
    // Transform coordinates based on geometry type
    if (isset($geom['coordinates'])) {
        transformCoordinates($geom['coordinates'], $geom['type']);
    }
    
    return json_encode($geom);
}

function transformToDatabase($geometry_geojson) {
    // If no geometry, return as is
    if (!$geometry_geojson) {
        return null;
    }
    
    $geom = json_decode($geometry_geojson, true);
    if (!$geom) {
        return null;
    }
    
    // Transform coordinates based on geometry type
    if (isset($geom['coordinates'])) {
        transformCoordinates($geom['coordinates'], $geom['type'], true);
    }
    
    return json_encode($geom);
}

function transformCoordinates(&$coords, $type, $reverse = false) {
    switch ($type) {
        case 'Point':
            if ($reverse) {
                // Database (20137) to Leaflet (4326)
                $coords = convert20137To4326($coords[0], $coords[1]);
            } else {
                // Leaflet (4326) to Database (20137)
                $coords = convert4326To20137($coords[0], $coords[1]);
            }
            break;
            
        case 'LineString':
            foreach ($coords as &$point) {
                if ($reverse) {
                    $point = convert20137To4326($point[0], $point[1]);
                } else {
                    $point = convert4326To20137($point[0], $point[1]);
                }
            }
            break;
            
        case 'Polygon':
            foreach ($coords as &$ring) {
                foreach ($ring as &$point) {
                    if ($reverse) {
                        $point = convert20137To4326($point[0], $point[1]);
                    } else {
                        $point = convert4326To20137($point[0], $point[1]);
                    }
                }
            }
            break;
            
        case 'MultiPolygon':
            foreach ($coords as &$polygon) {
                foreach ($polygon as &$ring) {
                    foreach ($ring as &$point) {
                        if ($reverse) {
                            $point = convert20137To4326($point[0], $point[1]);
                        } else {
                            $point = convert4326To20137($point[0], $point[1]);
                        }
                    }
                }
            }
            break;
    }
}

function convert4326To20137($lng, $lat) {
    // Approximate transformation for Addis Ababa area
    // This is a simplified transformation - for production, use PROJ library
    
    // UTM zone 37S parameters for Addis Ababa area (approximate)
    // These are rough conversions - in production, use proper PROJ
    
    // Central meridian for UTM zone 37S is 39°E
    $central_meridian = 39;
    
    // Convert degrees to radians
    $lat_rad = deg2rad($lat);
    $lng_rad = deg2rad($lng);
    $central_meridian_rad = deg2rad($central_meridian);
    
    // WGS84 ellipsoid parameters
    $a = 6378137; // semi-major axis
    $f = 1/298.257223563; // flattening
    $e2 = 2*$f - $f*$f; // eccentricity squared
    
    // Meridional arc
    $sin_lat = sin($lat_rad);
    $cos_lat = cos($lat_rad);
    $tan_lat = tan($lat_rad);
    
    $N = $a / sqrt(1 - $e2 * $sin_lat * $sin_lat);
    
    $T = $tan_lat * $tan_lat;
    $C = $e2 * $cos_lat * $cos_lat / (1 - $e2);
    $A = ($lng_rad - $central_meridian_rad) * $cos_lat;
    
    // Calculate easting
    $M = $a * ((1 - $e2/4 - 3*$e2*$e2/64 - 5*$e2*$e2*$e2/256) * $lat_rad
        - (3*$e2/8 + 3*$e2*$e2/32 + 45*$e2*$e2*$e2/1024) * sin(2*$lat_rad)
        + (15*$e2*$e2/256 + 45*$e2*$e2*$e2/1024) * sin(4*$lat_rad)
        - (35*$e2*$e2*$e2/3072) * sin(6*$lat_rad));
    
    $easting = 500000 + $N * ($A + (1 - $T + $C) * $A*$A*$A/6 
        + (5 - 18*$T + $T*$T + 72*$C - 58*$e2) * $A*$A*$A*$A*$A/120);
    
    // Calculate northing
    $northing = $M + $N * $tan_lat * ($A*$A/2 
        + (5 - $T + 9*$C + 4*$C*$C) * $A*$A*$A*$A/24 
        + (61 - 58*$T + $T*$T + 600*$C - 330*$e2) * $A*$A*$A*$A*$A*$A/720);
    
    // For southern hemisphere, add 10,000,000m
    if ($lat < 0) {
        $northing += 10000000;
    }
    
    return [$easting, $northing];
}

function convert20137To4326($easting, $northing) {
    // Approximate transformation for Addis Ababa area
    // This is a simplified inverse transformation
    
    $central_meridian = 39;
    $a = 6378137;
    $f = 1/298.257223563;
    $e2 = 2*$f - $f*$f;
    
    // Remove false easting and northing
    $x = $easting - 500000;
    $y = $northing;
    
    // For southern hemisphere
    if ($y > 10000000) {
        $y -= 10000000;
    }
    
    // Meridional arc
    $M = $y;
    
    // First approximation
    $mu = $M / ($a * (1 - $e2/4 - 3*$e2*$e2/64 - 5*$e2*$e2*$e2/256));
    
    $e1 = (1 - sqrt(1 - $e2)) / (1 + sqrt(1 - $e2));
    
    $lat1 = $mu + (3*$e1/2 - 27*$e1*$e1*$e1/32) * sin(2*$mu)
        + (21*$e1*$e1/16 - 55*$e1*$e1*$e1*$e1/32) * sin(4*$mu)
        + (151*$e1*$e1*$e1/96) * sin(6*$mu);
    
    $sin_lat = sin($lat1);
    $cos_lat = cos($lat1);
    $tan_lat = tan($lat1);
    
    $N = $a / sqrt(1 - $e2 * $sin_lat * $sin_lat);
    
    $T = $tan_lat * $tan_lat;
    $C = $e2 * $cos_lat * $cos_lat / (1 - $e2);
    
    $R = $a * (1 - $e2) / pow(1 - $e2 * $sin_lat * $sin_lat, 1.5);
    
    $D = $x / ($N * $cos_lat);
    
    // Calculate latitude
    $lat_rad = $lat1 - ($N * $tan_lat / $R) * ($D*$D/2 
        - (5 + 3*$T + 10*$C - 4*$C*$C - 9*$e2) * $D*$D*$D*$D/24 
        + (61 + 90*$T + 298*$C + 45*$T*$T - 252*$e2 - 3*$C*$C) * $D*$D*$D*$D*$D*$D/720);
    
    // Calculate longitude
    $lng_rad = $central_meridian * M_PI/180 + ($D 
        - (1 + 2*$T + $C) * $D*$D*$D/6 
        + (5 - 2*$C + 28*$T - 3*$C*$C + 8*$e2 + 24*$T*$T) * $D*$D*$D*$D*$D/120) / $cos_lat;
    
    return [rad2deg($lng_rad), rad2deg($lat_rad)];
}
?>
<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

require_once '../api/config/database.php';
$db = (new Database())->getConnection();

// Fetch all UGI assets for search dropdown with transformed centroids
$ugis = $db->query("
    SELECT u.ugi_id, u.name, u.ugi_type_id, t.type_name,
           ST_X(ST_Centroid(ST_Transform(u.geometry, 4326))) as lng, 
           ST_Y(ST_Centroid(ST_Transform(u.geometry, 4326))) as lat
    FROM ugims_ugi u
    LEFT JOIN lkp_ethiopia_ugi_type t ON u.ugi_type_id = t.ugi_type_id
    WHERE u.geometry IS NOT NULL
    ORDER BY u.name
")->fetchAll();

// Fetch all parcels for search dropdown with transformed centroids
$parcels = $db->query("
    SELECT parcel_id, parcel_number, 
           ST_X(ST_Centroid(ST_Transform(geometry, 4326))) as lng, 
           ST_Y(ST_Centroid(ST_Transform(geometry, 4326))) as lat
    FROM ugims_parcel
    WHERE geometry IS NOT NULL
    ORDER BY parcel_number
")->fetchAll();

// Fetch all maintenance zones with transformed centroids
$zones = $db->query("
    SELECT zone_id, zone_name, 
           ST_X(ST_Centroid(ST_Transform(geometry, 4326))) as lng, 
           ST_Y(ST_Centroid(ST_Transform(geometry, 4326))) as lat
    FROM ugims_maintenance_zone
    WHERE geometry IS NOT NULL
    ORDER BY zone_name
")->fetchAll();

// Fetch UGI types for filter
$ugi_types = $db->query("SELECT ugi_type_id, type_name FROM lkp_ethiopia_ugi_type ORDER BY type_name")->fetchAll();
?>
<!DOCTYPE html>
<html>
<head>
    <title>UGIMS Explorer</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            overflow: hidden;
            height: 100vh;
            display: flex;
            flex-direction: column;
            background: #f4f6f9;
        }
        
        .header {
            background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
            color: white;
            padding: 0 20px;
            height: 60px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            z-index: 1000;
        }
        
        .header h2 {
            font-size: 1.5rem;
            font-weight: 400;
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 0;
            color: white;
        }
        
        .header h2 i {
            color: #2ecc71;
        }
        
        .header-links {
            display: flex;
            gap: 10px;
        }
        
        .header-links a {
            color: white;
            text-decoration: none;
            padding: 8px 15px;
            border-radius: 4px;
            transition: background 0.3s;
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 0.9rem;
        }
        
        .header-links a:hover {
            background: rgba(255, 255, 255, 0.1);
            text-decoration: none;
        }
        
        .main-container {
            display: flex;
            flex: 1;
            overflow: hidden;
        }
        
        /* Side Panel */
        .side-panel {
            width: 380px;
            background: white;
            border-right: 1px solid #ddd;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            box-shadow: 2px 0 5px rgba(0,0,0,0.1);
            z-index: 500;
        }
        
        .panel-header {
            padding: 20px;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-bottom: 1px solid #ddd;
        }
        
        .panel-header h3 {
            margin-bottom: 5px;
            color: #2c3e50;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .panel-section {
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
        }
        
        .panel-section h4 {
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #7f8c8d;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .panel-section h4 i {
            color: #3498db;
        }
        
        .search-select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-bottom: 10px;
            font-size: 0.9rem;
            background: white;
            cursor: pointer;
        }
        
        .search-select:hover {
            border-color: #3498db;
        }
        
        .filter-group {
            display: flex;
            gap: 10px;
            margin-bottom: 10px;
        }
        
        .filter-group select {
            flex: 1;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        
        .btn-search {
            background: #3498db;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 4px;
            cursor: pointer;
            width: 100%;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: background 0.2s;
        }
        
        .btn-search:hover {
            background: #2980b9;
        }
        
        .btn-reset {
            background: #95a5a6;
            margin-top: 5px;
        }
        
        .btn-reset:hover {
            background: #7f8c8d;
        }
        
        .layer-controls {
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
        }
        
        .layer-item {
            display: flex;
            align-items: center;
            margin-bottom: 12px;
            padding: 5px;
            border-radius: 4px;
            transition: background 0.2s;
        }
        
        .layer-item:hover {
            background: #f5f5f5;
        }
        
        .layer-item input[type="checkbox"] {
            margin-right: 12px;
            width: 18px;
            height: 18px;
            cursor: pointer;
        }
        
        .layer-color {
            width: 20px;
            height: 20px;
            border-radius: 4px;
            margin-right: 12px;
        }
        
        .layer-name {
            flex: 1;
            font-size: 0.95rem;
        }
        
        .layer-count {
            background: #e0e0e0;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8rem;
            color: #555;
        }
        
        .legend {
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            margin-bottom: 8px;
            font-size: 0.9rem;
        }
        
        .legend-color {
            width: 16px;
            height: 16px;
            border-radius: 3px;
            margin-right: 10px;
        }
        
        .feature-info {
            padding: 20px;
            background: #f8f9fa;
            border-top: 1px solid #ddd;
            margin-top: auto;
            max-height: 300px;
            overflow-y: auto;
        }
        
        .feature-info h4 {
            margin-bottom: 15px;
            color: #2c3e50;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .info-content {
            font-size: 0.9rem;
        }
        
        .info-row {
            display: flex;
            margin-bottom: 8px;
            padding: 5px 0;
            border-bottom: 1px dashed #ddd;
        }
        
        .info-label {
            font-weight: 600;
            width: 100px;
            color: #555;
        }
        
        .info-value {
            flex: 1;
            color: #333;
        }
        
        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
            color: white;
        }
        
        .badge-success { background: #2ecc71; }
        .badge-warning { background: #f39c12; }
        .badge-danger { background: #e74c3c; }
        .badge-info { background: #3498db; }
        .badge-purple { background: #9b59b6; }
        
        /* Map Container */
        .map-container {
            flex: 1;
            position: relative;
        }
        
        #map {
            height: 100%;
            width: 100%;
            background: #e5e3df;
        }
        
        .map-controls {
            position: absolute;
            top: 20px;
            right: 20px;
            z-index: 1000;
            background: white;
            border-radius: 4px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }
        
        .base-layer-switcher {
            background: white;
            border-radius: 4px;
            overflow: hidden;
        }
        
        .base-layer-btn {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 10px 15px;
            border: none;
            background: white;
            cursor: pointer;
            width: 100%;
            text-align: left;
            border-bottom: 1px solid #eee;
            transition: background 0.2s;
            font-size: 0.9rem;
        }
        
        .base-layer-btn:last-child {
            border-bottom: none;
        }
        
        .base-layer-btn:hover {
            background: #f5f5f5;
        }
        
        .base-layer-btn.active {
            background: #3498db;
            color: white;
        }
        
        .base-layer-btn i {
            width: 20px;
        }
        
        .coord-debug {
            position: absolute;
            bottom: 10px;
            left: 10px;
            background: rgba(0,0,0,0.7);
            color: #fff;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
            z-index: 1000;
            font-family: monospace;
            pointer-events: none;
        }
        
        .popup-link {
            display: inline-block;
            margin-top: 10px;
            padding: 5px 10px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 3px;
            font-size: 0.8rem;
        }
        
        .popup-link:hover {
            background: #2980b9;
        }
        
        @media (max-width: 768px) {
            .main-container {
                flex-direction: column;
            }
            
            .side-panel {
                width: 100%;
                max-height: 40vh;
            }
            
            .map-container {
                height: 60vh;
            }
            
            .header {
                padding: 0 10px;
                height: 50px;
            }
            
            .header h2 {
                font-size: 1.2rem;
            }
            
            .header-links a span {
                display: none;
            }
            
            .header-links a i {
                font-size: 1.2rem;
                margin: 0;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h2>
            <i class="fas fa-map-marked-alt"></i>
            UGIMS Explorer
        </h2>
        <div class="header-links">
            <a href="dashboard.php"><i class="fas fa-tachometer-alt"></i> <span>Dashboard</span></a>
            <a href="logout.php"><i class="fas fa-sign-out-alt"></i> <span>Logout</span></a>
        </div>
    </div>
    
    <div class="main-container">
        <!-- Side Panel -->
        <div class="side-panel">
            <div class="panel-header">
                <h3><i class="fas fa-search"></i> Explore Urban Green Infrastructure</h3>
                <p style="color: #7f8c8d; font-size: 0.9rem;">Click on any feature to see details</p>
            </div>
            
            <!-- Search Section -->
            <div class="panel-section">
                <h4><i class="fas fa-map-pin"></i> Quick Search</h4>
                
                <select id="searchUgi" class="search-select">
                    <option value="">-- Search UGI Asset --</option>
                    <?php foreach ($ugis as $u): ?>
                    <option value="<?= $u['ugi_id'] ?>" data-lat="<?= $u['lat'] ?>" data-lng="<?= $u['lng'] ?>">
                        <?= htmlspecialchars($u['name']) ?> (<?= htmlspecialchars($u['type_name']) ?>)
                    </option>
                    <?php endforeach; ?>
                </select>
                
                <select id="searchParcel" class="search-select">
                    <option value="">-- Search Parcel --</option>
                    <?php foreach ($parcels as $p): ?>
                    <option value="<?= $p['parcel_id'] ?>" data-lat="<?= $p['lat'] ?>" data-lng="<?= $p['lng'] ?>">
                        <?= htmlspecialchars($p['parcel_number']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
                
                <select id="searchZone" class="search-select">
                    <option value="">-- Search Maintenance Zone --</option>
                    <?php foreach ($zones as $z): ?>
                    <option value="<?= $z['zone_id'] ?>" data-lat="<?= $z['lat'] ?>" data-lng="<?= $z['lng'] ?>">
                        <?= htmlspecialchars($z['zone_name']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
                
                <button id="searchBtn" class="btn-search">
                    <i class="fas fa-search"></i> Search & Zoom
                </button>
            </div>
            
            <!-- Filter Section -->
            <div class="panel-section">
                <h4><i class="fas fa-filter"></i> Filter UGI by Type</h4>
                
                <div class="filter-group">
                    <select id="filterType">
                        <option value="">All Types</option>
                        <?php foreach ($ugi_types as $t): ?>
                        <option value="<?= $t['ugi_type_id'] ?>"><?= htmlspecialchars($t['type_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                
                <button id="applyFilter" class="btn-search">
                    <i class="fas fa-check"></i> Apply Filter
                </button>
                
                <button id="resetFilter" class="btn-search btn-reset">
                    <i class="fas fa-undo"></i> Reset Filter
                </button>
            </div>
            
            <!-- Layer Controls -->
            <div class="layer-controls">
                <h4><i class="fas fa-layers"></i> Visible Layers</h4>
                
                <div class="layer-item">
                    <input type="checkbox" id="layerParcels" checked>
                    <span class="layer-color" style="background: #e67e22; opacity: 0.5;"></span>
                    <span class="layer-name">Parcels</span>
                    <span class="layer-count"><?= count($parcels) ?></span>
                </div>
                
                <div class="layer-item">
                    <input type="checkbox" id="layerUGI" checked>
                    <span class="layer-color" style="background: #2ecc71; opacity: 0.5;"></span>
                    <span class="layer-name">UGI Assets</span>
                    <span class="layer-count"><?= count($ugis) ?></span>
                </div>
                
                <div class="layer-item">
                    <input type="checkbox" id="layerZones">
                    <span class="layer-color" style="background: #9b59b6; opacity: 0.3;"></span>
                    <span class="layer-name">Maintenance Zones</span>
                    <span class="layer-count"><?= count($zones) ?></span>
                </div>
            </div>
            
            <!-- Legend -->
            <div class="legend">
                <h4><i class="fas fa-palette"></i> Legend</h4>
                
                <div class="legend-item">
                    <span class="legend-color" style="background: #2ecc71;"></span>
                    <span>Park / Garden</span>
                </div>
                <div class="legend-item">
                    <span class="legend-color" style="background: #3498db;"></span>
                    <span>Sport Field</span>
                </div>
                <div class="legend-item">
                    <span class="legend-color" style="background: #f39c12;"></span>
                    <span>Playground</span>
                </div>
                <div class="legend-item">
                    <span class="legend-color" style="background: #e74c3c;"></span>
                    <span>Critical Condition</span>
                </div>
                <div class="legend-item">
                    <span class="legend-color" style="background: #e67e22; opacity: 0.5;"></span>
                    <span>Parcel Boundary</span>
                </div>
                <div class="legend-item">
                    <span class="legend-color" style="background: #9b59b6; opacity: 0.3;"></span>
                    <span>Maintenance Zone</span>
                </div>
            </div>
            
            <!-- Feature Info Panel -->
            <div class="feature-info" id="featureInfo">
                <h4><i class="fas fa-info-circle"></i> Feature Information</h4>
                <div class="info-content" id="infoContent">
                    <p style="color: #7f8c8d; text-align: center;">Click on any feature on the map to see details</p>
                </div>
            </div>
        </div>
        
        <!-- Map Container -->
        <div class="map-container">
            <div id="map"></div>
            
            <!-- Debug Info -->
            <div class="coord-debug" id="debugInfo">
                Loading map...
            </div>
            
            <!-- Base Layer Switcher -->
            <div class="map-controls">
                <div class="base-layer-switcher">
                    <button class="base-layer-btn active" id="osmBtn">
                        <i class="fas fa-map"></i> Street Map
                    </button>
                    <button class="base-layer-btn" id="satelliteBtn">
                        <i class="fas fa-satellite"></i> Satellite
                    </button>
                    <button class="base-layer-btn" id="terrainBtn">
                        <i class="fas fa-mountain"></i> Terrain
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        // Debug function
        function debug(message) {
            console.log(message);
            document.getElementById('debugInfo').innerHTML = message;
        }

        // Initialize map
        var map = L.map('map', {
            center: [9.03, 38.74], // Addis Ababa center
            zoom: 12,
            maxBounds: [[3.0, 33.0], [15.0, 48.0]] // Ethiopia bounds
        });
        
        debug('Map initialized at 9.03°N, 38.74°E');

        // Base layers
        var osmLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors',
            maxZoom: 19
        }).addTo(map);
        
        var satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
            attribution: 'Tiles © Esri',
            maxZoom: 19
        });
        
        var terrainLayer = L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenTopoMap',
            maxZoom: 17
        });

        // Feature groups
        var parcelLayer = L.featureGroup().addTo(map);
        var ugiLayer = L.featureGroup().addTo(map);
        var zoneLayer = L.featureGroup().addTo(map);

        // Color mapping for UGI types
        function getUgiColor(typeId) {
            const colors = {
                1: '#2ecc71',  // Park
                2: '#3498db',  // Sport Field
                3: '#95a5a6',  // Cemetery
                4: '#27ae60',  // Open Green
                5: '#16a085',  // Roadside
                6: '#1abc9c',  // Median
                7: '#f39c12',  // Roundabout
                8: '#27ae60',  // Urban Forest
                9: '#1abc9c',  // Riverside
                10: '#f1c40f', // Public Square
                11: '#e67e22', // Community Garden
                12: '#9b59b6', // Botanical Garden
                13: '#e67e22', // Playground
            };
            return colors[typeId] || '#2ecc71';
        }

        // Load parcels
        function loadParcels() {
            debug('Loading parcels...');
            
            fetch('../api/endpoints/get_parcels.php')
                .then(response => {
                    if (!response.ok) throw new Error('Network error');
                    return response.json();
                })
                .then(data => {
                    debug(`Loaded ${data.features.length} parcels`);
                    parcelLayer.clearLayers();
                    
                    if (data.features.length === 0) return;
                    
                    L.geoJSON(data, {
                        style: {
                            color: '#e67e22',
                            weight: 2,
                            opacity: 0.8,
                            fillOpacity: 0.2
                        },
                        onEachFeature: function(feature, layer) {
                            layer.on('click', function() {
                                showParcelInfo(feature.properties);
                            });
                            
                            layer.bindTooltip('Parcel: ' + feature.properties.parcel_number, {
                                sticky: true
                            });
                        }
                    }).addTo(parcelLayer);
                })
                .catch(error => {
                    debug('Error loading parcels: ' + error.message);
                });
        }

        // Load UGI assets
        function loadUGI(filterType = '') {
            let url = '../api/endpoints/get_ugi.php';
            if (filterType) url += '?type=' + filterType;
            
            debug('Loading UGI assets...');
            
            fetch(url)
                .then(response => {
                    if (!response.ok) throw new Error('Network error');
                    return response.json();
                })
                .then(data => {
                    debug(`Loaded ${data.features.length} UGI assets`);
                    ugiLayer.clearLayers();
                    
                    if (data.features.length === 0) return;
                    
                    L.geoJSON(data, {
                        style: function(feature) {
                            return {
                                color: getUgiColor(feature.properties.ugi_type_id),
                                weight: 2,
                                opacity: 0.8,
                                fillOpacity: 0.3
                            };
                        },
                        onEachFeature: function(feature, layer) {
                            layer.on('click', function() {
                                showUgiInfo(feature.properties);
                            });
                            
                            layer.bindTooltip(feature.properties.name, {
                                sticky: true
                            });
                        }
                    }).addTo(ugiLayer);
                })
                .catch(error => {
                    debug('Error loading UGI: ' + error.message);
                });
        }

        // Load zones
        function loadZones() {
            debug('Loading zones...');
            
            fetch('../api/endpoints/get_zones.php')
                .then(response => {
                    if (!response.ok) throw new Error('Network error');
                    return response.json();
                })
                .then(data => {
                    debug(`Loaded ${data.features.length} zones`);
                    zoneLayer.clearLayers();
                    
                    if (data.features.length === 0) return;
                    
                    L.geoJSON(data, {
                        style: {
                            color: '#9b59b6',
                            weight: 1,
                            opacity: 0.6,
                            fillOpacity: 0.1,
                            dashArray: '5, 5'
                        },
                        onEachFeature: function(feature, layer) {
                            layer.on('click', function() {
                                showZoneInfo(feature.properties);
                            });
                            
                            layer.bindTooltip('Zone: ' + feature.properties.zone_name, {
                                sticky: true
                            });
                        }
                    }).addTo(zoneLayer);
                })
                .catch(error => {
                    debug('Error loading zones: ' + error.message);
                });
        }

        // Show parcel info
        function showParcelInfo(props) {
            let html = `
                <div class="info-row">
                    <span class="info-label">Parcel #:</span>
                    <span class="info-value">${props.parcel_number || 'N/A'}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Area:</span>
                    <span class="info-value">${props.area_sq_m ? parseFloat(props.area_sq_m).toFixed(2) + ' m²' : 'N/A'}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Land Use:</span>
                    <span class="info-value">${props.land_use_name || 'N/A'}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Owner:</span>
                    <span class="info-value">${props.owner_name || 'N/A'}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Location:</span>
                    <span class="info-value">${props.street_name || ''} ${props.house_number || ''}</span>
                </div>
                <div style="margin-top: 10px; text-align: right;">
                    <a href="parcel_edit.php?id=${props.parcel_id}" class="popup-link" target="_blank">
                        <i class="fas fa-edit"></i> Edit Parcel
                    </a>
                </div>
            `;
            document.getElementById('infoContent').innerHTML = html;
        }

        // Show UGI info
        function showUgiInfo(props) {
            let conditionClass = 'badge-success';
            if (props.condition_status_id > 3) conditionClass = 'badge-danger';
            else if (props.condition_status_id > 2) conditionClass = 'badge-warning';
            
            let lighting = props.has_lighting == 't' || props.has_lighting == true ? '<i class="fas fa-lightbulb" style="color: #f39c12;" title="Has lighting"></i>' : '';
            let irrigation = props.has_irrigation == 't' || props.has_irrigation == true ? '<i class="fas fa-water" style="color: #3498db;" title="Has irrigation"></i>' : '';
            let fencing = props.has_fencing == 't' || props.has_fencing == true ? '<i class="fas fa-fence" style="color: #7f8c8d;" title="Has fencing"></i>' : '';
            
            let html = `
                <div class="info-row">
                    <span class="info-label">Name:</span>
                    <span class="info-value"><strong>${props.name || 'N/A'}</strong></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Type:</span>
                    <span class="info-value">${props.type_name || 'N/A'}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Area:</span>
                    <span class="info-value">${props.area_sq_m ? parseFloat(props.area_sq_m).toFixed(2) + ' m²' : 'N/A'}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Condition:</span>
                    <span class="info-value">
                        <span class="badge ${conditionClass}">${props.condition_name || 'Unknown'}</span>
                    </span>
                </div>
                <div class="info-row">
                    <span class="info-label">Amenities:</span>
                    <span class="info-value">
                        ${lighting} ${irrigation} ${fencing}
                    </span>
                </div>
                <div class="info-row">
                    <span class="info-label">Contact:</span>
                    <span class="info-value">${props.contact_person || 'N/A'}<br>${props.contact_phone || ''}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Trees:</span>
                    <span class="info-value">${props.tree_count || '0'}</span>
                </div>
                <div style="margin-top: 10px; text-align: right;">
                    <a href="ugi_edit.php?id=${props.ugi_id}" class="popup-link" target="_blank">
                        <i class="fas fa-edit"></i> Edit UGI
                    </a>
                </div>
            `;
            document.getElementById('infoContent').innerHTML = html;
        }

        // Show zone info
        function showZoneInfo(props) {
            let priorityClass = 'badge-success';
            if (props.priority_level <= 2) priorityClass = 'badge-danger';
            else if (props.priority_level <= 3) priorityClass = 'badge-warning';
            
            let html = `
                <div class="info-row">
                    <span class="info-label">Zone:</span>
                    <span class="info-value"><strong>${props.zone_name || 'N/A'}</strong></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Code:</span>
                    <span class="info-value">${props.zone_code || 'N/A'}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Priority:</span>
                    <span class="info-value">
                        <span class="badge ${priorityClass}">Level ${props.priority_level || 'N/A'}</span>
                    </span>
                </div>
                <div class="info-row">
                    <span class="info-label">Area:</span>
                    <span class="info-value">${props.area_sq_m ? parseFloat(props.area_sq_m).toFixed(2) + ' m²' : 'N/A'}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Description:</span>
                    <span class="info-value">${props.description || 'N/A'}</span>
                </div>
            `;
            document.getElementById('infoContent').innerHTML = html;
        }

        // Layer toggles
        document.getElementById('layerParcels').addEventListener('change', function(e) {
            if (e.target.checked) {
                map.addLayer(parcelLayer);
                loadParcels();
            } else {
                map.removeLayer(parcelLayer);
            }
        });
        
        document.getElementById('layerUGI').addEventListener('change', function(e) {
            if (e.target.checked) {
                map.addLayer(ugiLayer);
                loadUGI();
            } else {
                map.removeLayer(ugiLayer);
            }
        });
        
        document.getElementById('layerZones').addEventListener('change', function(e) {
            if (e.target.checked) {
                map.addLayer(zoneLayer);
                loadZones();
            } else {
                map.removeLayer(zoneLayer);
            }
        });

        // Base layer switching
        document.getElementById('osmBtn').addEventListener('click', function() {
            map.removeLayer(satelliteLayer);
            map.removeLayer(terrainLayer);
            map.addLayer(osmLayer);
            document.querySelectorAll('.base-layer-btn').forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
        });
        
        document.getElementById('satelliteBtn').addEventListener('click', function() {
            map.removeLayer(osmLayer);
            map.removeLayer(terrainLayer);
            map.addLayer(satelliteLayer);
            document.querySelectorAll('.base-layer-btn').forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
        });
        
        document.getElementById('terrainBtn').addEventListener('click', function() {
            map.removeLayer(osmLayer);
            map.removeLayer(satelliteLayer);
            map.addLayer(terrainLayer);
            document.querySelectorAll('.base-layer-btn').forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
        });

        // Search
        document.getElementById('searchBtn').addEventListener('click', function() {
            let ugiSelect = document.getElementById('searchUgi');
            let parcelSelect = document.getElementById('searchParcel');
            let zoneSelect = document.getElementById('searchZone');
            
            if (ugiSelect.value) {
                let option = ugiSelect.selectedOptions[0];
                let lat = parseFloat(option.dataset.lat);
                let lng = parseFloat(option.dataset.lng);
                debug(`Zooming to UGI: ${lat.toFixed(4)}°N, ${lng.toFixed(4)}°E`);
                map.setView([lat, lng], 18);
            } else if (parcelSelect.value) {
                let option = parcelSelect.selectedOptions[0];
                let lat = parseFloat(option.dataset.lat);
                let lng = parseFloat(option.dataset.lng);
                debug(`Zooming to parcel: ${lat.toFixed(4)}°N, ${lng.toFixed(4)}°E`);
                map.setView([lat, lng], 18);
            } else if (zoneSelect.value) {
                let option = zoneSelect.selectedOptions[0];
                let lat = parseFloat(option.dataset.lat);
                let lng = parseFloat(option.dataset.lng);
                debug(`Zooming to zone: ${lat.toFixed(4)}°N, ${lng.toFixed(4)}°E`);
                map.setView([lat, lng], 14);
            } else {
                debug('No item selected for search');
            }
        });

        // Filter
        document.getElementById('applyFilter').addEventListener('click', function() {
            let filterType = document.getElementById('filterType').value;
            debug(`Filtering UGI by type: ${filterType || 'all'}`);
            loadUGI(filterType);
        });

        // Reset filter
        document.getElementById('resetFilter').addEventListener('click', function() {
            document.getElementById('filterType').value = '';
            debug('Resetting UGI filter');
            loadUGI();
        });

        // Mouse move debug
        map.on('mousemove', function(e) {
            debug(`Center: ${map.getCenter().lat.toFixed(4)}°N, ${map.getCenter().lng.toFixed(4)}°E | Zoom: ${map.getZoom()}`);
        });

        // Initial loads
        loadParcels();
        loadUGI();
        
        // Add scale control
        L.control.scale({
            imperial: false,
            metric: true,
            position: 'bottomright',
            maxWidth: 200
        }).addTo(map);
    </script>
</body>
</html>
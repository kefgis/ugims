<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

// Define all spatial tables to export
$spatial_tables = [
    'ugims_parcel' => [
        'name' => 'Parcels',
        'description' => 'Land parcels with boundaries',
        'geometry_type' => 'MultiPolygon',
        'fields' => [
            'parcel_number' => 'Parcel Number (required)',
            'parcel_registration_number' => 'Registration Number',
            'land_use_type_id' => 'Land Use Type ID',
            'ownership_type_id' => 'Ownership Type ID',
            'owner_name' => 'Owner Name',
            'owner_id_number' => 'Owner ID Number',
            'owner_contact' => 'Owner Contact',
            'region_id' => 'Region ID',
            'city_id' => 'City ID',
            'Woreda_id' => 'Woreda ID',
            'street_name' => 'Street Name',
            'house_number' => 'House Number',
            'landmark' => 'Landmark',
            'registration_date' => 'Registration Date',
            'spatial_accuracy' => 'Spatial Accuracy',
            'survey_date' => 'Survey Date',
            'survey_method' => 'Survey Method'
        ]
    ],
    'ugims_ugi' => [
        'name' => 'UGI Assets',
        'description' => 'Urban Green Infrastructure (parks, sport fields, etc.)',
        'geometry_type' => 'MultiPolygon',
        'fields' => [
            'name' => 'UGI Name (required)',
            'amharic_name' => 'Amharic Name',
            'ugi_type_id' => 'UGI Type ID (required)',
            'parcel_id' => 'Parcel ID (UUID)',
            'condition_status_id' => 'Condition Status ID',
            'operational_status_id' => 'Operational Status ID',
            'has_lighting' => 'Has Lighting (true/false)',
            'has_irrigation' => 'Has Irrigation (true/false)',
            'has_fencing' => 'Has Fencing (true/false)',
            'visitor_capacity' => 'Visitor Capacity',
            'contact_person' => 'Contact Person',
            'contact_phone' => 'Contact Phone',
            'contact_email' => 'Contact Email',
            'tree_count' => 'Tree Count'
        ]
    ],
    'ugims_maintenance_zone' => [
        'name' => 'Maintenance Zones',
        'description' => 'Operational zones for maintenance teams',
        'geometry_type' => 'MultiPolygon',
        'fields' => [
            'zone_name' => 'Zone Name (required)',
            'zone_code' => 'Zone Code',
            'priority_level' => 'Priority Level (1-5)',
            'description' => 'Description'
        ]
    ],
    'ugims_inspection_area' => [
        'name' => 'Inspection Areas',
        'description' => 'Areas designated for inspections',
        'geometry_type' => 'Polygon',
        'fields' => [
            'area_name' => 'Area Name',
            'inspection_frequency' => 'Inspection Frequency (days)',
            'assigned_inspector' => 'Assigned Inspector'
        ]
    ],
    'lkq_region' => [
        'name' => 'Regions',
        'description' => 'Administrative regions',
        'geometry_type' => 'MultiPolygon',
        'fields' => [
            'region_name' => 'Region Name',
            'region_code' => 'Region Code'
        ]
    ],
    'lkq_city' => [
        'name' => 'Cities',
        'description' => 'Cities and municipalities',
        'geometry_type' => 'MultiPolygon',
        'fields' => [
            'city_name' => 'City Name',
            'municipality_code' => 'Municipality Code',
            'region_id' => 'Region ID'
        ]
    ],
    'lkq_subcity' => [
        'name' => 'Sub-cities',
        'description' => 'Sub-city administrative divisions',
        'geometry_type' => 'MultiPolygon',
        'fields' => [
            'subcity_name' => 'Sub-city Name',
            'administrative_code' => 'Administrative Code',
            'city_id' => 'City ID'
        ]
    ],
    'lkq_Woreda' => [
        'name' => 'Woredas',
        'description' => 'Woredas (neighborhoods)',
        'geometry_type' => 'MultiPolygon',
        'fields' => [
            'Woreda_name' => 'Woreda Name',
            'Woreda_number' => 'Woreda Number',
            'subcity_id' => 'Sub-city ID'
        ]
    ],
    'lkq_kebele' => [
        'name' => 'Kebeles',
        'description' => 'Kebele administrative units',
        'geometry_type' => 'MultiPolygon',
        'fields' => [
            'kebele_number' => 'Kebele Number',
            'kebele_name' => 'Kebele Name',
            'Woreda_id' => 'Woreda ID'
        ]
    ],
    'ugims_ugi_component' => [
        'name' => 'UGI Components',
        'description' => 'Individual components within UGI (benches, lights, etc.)',
        'geometry_type' => 'Point',
        'fields' => [
            'component_code' => 'Component Code',
            'component_type_id' => 'Component Type ID',
            'location_description' => 'Location Description',
            'manufacturer' => 'Manufacturer',
            'model_number' => 'Model Number',
            'serial_number' => 'Serial Number',
            'installation_date' => 'Installation Date',
            'material_type' => 'Material Type',
            'color' => 'Color',
            'condition_status_id' => 'Condition Status ID',
            'warranty_expiry' => 'Warranty Expiry',
            'is_public' => 'Is Public (true/false)',
            'safety_rating' => 'Safety Rating (1-5)'
        ]
    ],
    'ugims_citizen_report' => [
        'name' => 'Citizen Reports',
        'description' => 'Issue reports from citizens',
        'geometry_type' => 'Point',
        'fields' => [
            'report_number' => 'Report Number',
            'reporter_name' => 'Reporter Name',
            'reporter_email' => 'Reporter Email',
            'reporter_phone' => 'Reporter Phone',
            'report_type_id' => 'Report Type ID',
            'report_title' => 'Report Title',
            'report_description' => 'Report Description',
            'location_description' => 'Location Description',
            'status_id' => 'Status ID'
        ]
    ],
    'ugims_activity_execution' => [
        'name' => 'Activity Executions',
        'description' => 'Record of completed maintenance activities',
        'geometry_type' => 'Point',
        'fields' => [
            'execution_number' => 'Execution Number',
            'actual_start_datetime' => 'Start Date/Time',
            'actual_end_datetime' => 'End Date/Time',
            'actual_man_days' => 'Actual Man-days',
            'actual_labor_cost' => 'Labor Cost',
            'actual_material_cost' => 'Material Cost',
            'materials_used' => 'Materials Used',
            'work_notes' => 'Work Notes',
            'quality_rating' => 'Quality Rating (1-5)',
            'weather_conditions' => 'Weather Conditions'
        ]
    ],
    'ugims_inspection' => [
        'name' => 'Inspections',
        'description' => 'Scheduled and completed inspections',
        'geometry_type' => 'Point',
        'fields' => [
            'inspection_number' => 'Inspection Number',
            'inspection_type_id' => 'Inspection Type ID',
            'scheduled_date' => 'Scheduled Date',
            'completed_datetime' => 'Completed Date/Time',
            'overall_condition_id' => 'Overall Condition ID',
            'overall_rating' => 'Overall Rating (1-10)',
            'findings_summary' => 'Findings Summary',
            'recommendations' => 'Recommendations',
            'inspection_status_id' => 'Status ID'
        ]
    ],
    'ugims_inspection_finding' => [
        'name' => 'Inspection Findings',
        'description' => 'Specific findings from inspections',
        'geometry_type' => 'Point',
        'fields' => [
            'finding_description' => 'Finding Description',
            'finding_priority_id' => 'Priority ID',
            'severity' => 'Severity (1-5)',
            'immediate_action_taken' => 'Immediate Action',
            'recommended_action' => 'Recommended Action',
            'estimated_repair_cost' => 'Estimated Repair Cost',
            'resolved' => 'Resolved (true/false)'
        ]
    ]
];
?>
<!DOCTYPE html>
<html>
<head>
    <title>Spatial Data Export</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
    <style>
        .export-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .export-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .export-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.15);
        }
        .export-card h3 {
            margin-top: 0;
            color: #2c3e50;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 10px;
        }
        .geometry-badge {
            display: inline-block;
            padding: 3px 8px;
            background: #3498db;
            color: white;
            border-radius: 12px;
            font-size: 0.8rem;
            margin-bottom: 10px;
        }
        .field-list {
            max-height: 200px;
            overflow-y: auto;
            margin: 10px 0;
            padding: 10px;
            background: #f8f9fa;
            border-radius: 4px;
            font-size: 0.9rem;
        }
        .field-list ul {
            margin: 0;
            padding-left: 20px;
        }
        .field-list li {
            margin: 2px 0;
        }
        .export-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }
        .export-actions a {
            flex: 1;
            text-align: center;
            padding: 8px;
            text-decoration: none;
            border-radius: 4px;
        }
        .btn-shapefile {
            background: #27ae60;
            color: white;
        }
        .btn-csv {
            background: #f39c12;
            color: white;
        }
        .btn-geojson {
            background: #9b59b6;
            color: white;
        }
        .btn-template {
            background: #e67e22;
            color: white;
        }
        .btn-template-parcel {
            background: #e67e22;
            color: white;
        }
        .btn-template-ugi {
            background: #2ecc71;
            color: white;
        }
        .search-box {
            margin-bottom: 20px;
        }
        .search-box input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .stats {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            padding: 15px;
            background: white;
            border-radius: 8px;
        }
        .stat-item {
            flex: 1;
            text-align: center;
        }
        .stat-number {
            font-size: 24px;
            font-weight: bold;
            color: #2ecc71;
        }
        
        /* NEW: Template Section Styles */
        .template-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 30px;
            border-radius: 15px;
            margin: 30px 0;
            color: white;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        
        .template-section h2 {
            margin: 0 0 10px;
            font-size: 2rem;
            color: white;
        }
        
        .template-section p {
            font-size: 1.1rem;
            opacity: 0.9;
            margin-bottom: 25px;
        }
        
        .template-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-top: 20px;
        }
        
        .template-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            color: #333;
            transition: transform 0.3s, box-shadow 0.3s;
            position: relative;
            overflow: hidden;
        }
        
        .template-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.3);
        }
        
        .template-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
            background: linear-gradient(90deg, #e67e22, #f39c12);
        }
        
        .template-card.ugi::before {
            background: linear-gradient(90deg, #2ecc71, #27ae60);
        }
        
        .template-icon {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin-bottom: 20px;
        }
        
        .template-icon.parcel {
            background: linear-gradient(135deg, #e67e22, #d35400);
            color: white;
        }
        
        .template-icon.ugi {
            background: linear-gradient(135deg, #2ecc71, #27ae60);
            color: white;
        }
        
        .template-card h3 {
            margin: 0 0 10px;
            font-size: 1.5rem;
            color: #2c3e50;
        }
        
        .template-card .badge {
            display: inline-block;
            padding: 4px 12px;
            background: #f0f0f0;
            border-radius: 20px;
            font-size: 0.85rem;
            margin-bottom: 15px;
        }
        
        .feature-list {
            list-style: none;
            padding: 0;
            margin: 20px 0;
        }
        
        .feature-list li {
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.95rem;
        }
        
        .feature-list i {
            color: #2ecc71;
            width: 20px;
        }
        
        .btn-template-download {
            display: inline-block;
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 10px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            transition: all 0.3s;
            margin-top: 15px;
        }
        
        .btn-template-download.parcel {
            background: #e67e22;
            color: white;
        }
        
        .btn-template-download.parcel:hover {
            background: #d35400;
            transform: scale(1.02);
            text-decoration: none;
            color: white;
        }
        
        .btn-template-download.ugi {
            background: #2ecc71;
            color: white;
        }
        
        .btn-template-download.ugi:hover {
            background: #27ae60;
            transform: scale(1.02);
            text-decoration: none;
            color: white;
        }
        
        .info-note {
            margin-top: 20px;
            padding: 15px;
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            font-size: 0.95rem;
        }
        
        .info-note i {
            margin-right: 8px;
        }
        
        .divider {
            height: 2px;
            background: linear-gradient(90deg, transparent, #3498db, transparent);
            margin: 40px 0 20px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h2>Spatial Data Export</h2>
        <div>
            <span>Welcome, <?= htmlspecialchars($_SESSION['username']) ?></span>
            <a href="../dashboard.php">Dashboard</a>
            <a href="../logout.php">Logout</a>
        </div>
    </div>

    <div class="container">
        <!-- Navigation -->
        <div style="margin-bottom: 20px; padding: 10px; background: #f8f9fa; border-radius: 4px;">
            <a href="../import/index.php" style="margin-right: 15px;">📥 Import Data</a>
            <a href="index.php" style="margin-right: 15px; font-weight: bold;">📤 Export Data</a>
            <a href="help.php">❓ Help</a>
        </div>

        <!-- Stats -->
        <div class="stats">
            <div class="stat-item">
                <div class="stat-number"><?= count($spatial_tables) ?></div>
                <div>Spatial Tables</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">EPSG:20137</div>
                <div>Coordinate System</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">UTM zone 37S</div>
                <div>Projection</div>
            </div>
        </div>

        <!-- NEW: Template Download Section -->
        <div class="template-section">
            <h2><i class="fas fa-magic"></i> Enhanced Data Templates</h2>
            <p>Download comprehensive templates with sample data and complete lookup tables to help you prepare your data correctly.</p>
            
            <div class="template-grid">
                <!-- Parcel Template Card -->
                <div class="template-card">
                    <div class="template-icon parcel">
                        <i class="fas fa-draw-polygon"></i>
                    </div>
                    <h3>Parcel Template</h3>
                    <span class="badge">20+ sample rows</span>
                    
                    <ul class="feature-list">
                        <li><i class="fas fa-check-circle"></i> 20+ sample rows with realistic data</li>
                        <li><i class="fas fa-check-circle"></i> All land use types (15 values)</li>
                        <li><i class="fas fa-check-circle"></i> All ownership types (11 values)</li>
                        <li><i class="fas fa-check-circle"></i> Complete admin hierarchy (Regions, Cities, Subcities, Woredas, Kebeles)</li>
                        <li><i class="fas fa-check-circle"></i> Sample coordinates and dates</li>
                        <li><i class="fas fa-check-circle"></i> Detailed README with field descriptions</li>
                    </ul>
                    
                    <a href="export_template.php?type=parcel" class="btn-template-download parcel" target="_blank">
                        <i class="fas fa-download"></i> Download Parcel Template
                    </a>
                </div>
                
                <!-- UGI Template Card -->
                <div class="template-card ugi">
                    <div class="template-icon ugi">
                        <i class="fas fa-tree"></i>
                    </div>
                    <h3>UGI Asset Template</h3>
                    <span class="badge">20+ sample rows</span>
                    
                    <ul class="feature-list">
                        <li><i class="fas fa-check-circle"></i> 20+ sample rows with realistic data</li>
                        <li><i class="fas fa-check-circle"></i> All UGI types (15 values with categories)</li>
                        <li><i class="fas fa-check-circle"></i> All condition statuses (8 values)</li>
                        <li><i class="fas fa-check-circle"></i> All operational statuses (9 values)</li>
                        <li><i class="fas fa-check-circle"></i> All accessibility types (7 values)</li>
                        <li><i class="fas fa-check-circle"></i> Sample parcel UUIDs for reference</li>
                        <li><i class="fas fa-check-circle"></i> Detailed README with field descriptions</li>
                    </ul>
                    
                    <a href="export_template.php?type=ugi" class="btn-template-download ugi" target="_blank">
                        <i class="fas fa-download"></i> Download UGI Template
                    </a>
                </div>
            </div>
            
            <div class="info-note">
                <i class="fas fa-info-circle"></i> 
                <strong>What's included:</strong> Each download contains a main CSV with 20+ sample rows, all lookup tables as separate CSV files, and a comprehensive README with field descriptions and instructions.
            </div>
        </div>

        <div class="divider"></div>

        <!-- Search -->
        <div class="search-box">
            <input type="text" id="searchInput" placeholder="Search tables..." onkeyup="filterTables()">
        </div>

        <!-- Export Cards -->
        <div class="export-grid" id="exportGrid">
            <?php foreach ($spatial_tables as $table => $info): ?>
            <div class="export-card" data-name="<?= strtolower($info['name']) ?>">
                <h3><?= htmlspecialchars($info['name']) ?></h3>
                <span class="geometry-badge"><?= $info['geometry_type'] ?></span>
                <p><?= htmlspecialchars($info['description']) ?></p>
                
                <div class="field-list">
                    <strong>Fields (<?= count($info['fields']) ?>):</strong>
                    <ul>
                        <?php 
                        $display_fields = array_slice($info['fields'], 0, 8, true);
                        foreach ($display_fields as $field => $desc): 
                        ?>
                        <li><strong><?= $field ?></strong> - <?= htmlspecialchars($desc) ?></li>
                        <?php endforeach; ?>
                        <?php if (count($info['fields']) > 8): ?>
                        <li>... and <?= count($info['fields']) - 8 ?> more</li>
                        <?php endif; ?>
                    </ul>
                </div>

                <div class="export-actions">
                    <a href="export_shapefile.php?table=<?= $table ?>&format=shp" class="btn-shapefile">📦 Shapefile</a>
                    <a href="export_shapefile.php?table=<?= $table ?>&format=csv" class="btn-csv">📊 CSV</a>
                    <a href="export_shapefile.php?table=<?= $table ?>&format=geojson" class="btn-geojson">🌍 GeoJSON</a>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>

    <script>
    function filterTables() {
        const search = document.getElementById('searchInput').value.toLowerCase();
        const cards = document.getElementsByClassName('export-card');
        
        for (let card of cards) {
            const name = card.getAttribute('data-name');
            if (name.includes(search)) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        }
    }
    </script>
</body>
</html>
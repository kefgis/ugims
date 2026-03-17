<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../api/config/database.php';
require_once '../api/utils/geometry.php';

$db = (new Database())->getConnection();

$parcel_id = $_GET['id'] ?? null;
$parcel = null;
$geometry_geojson = null;

if ($parcel_id) {
    // Fetch existing parcel - transform on database side to WGS84 for Leaflet
    $stmt = $db->prepare("SELECT *, ST_AsGeoJSON(ST_Transform(geometry, 4326)) as geojson FROM ugims_parcel WHERE parcel_id = :id");
    $stmt->execute([':id' => $parcel_id]);
    $parcel = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$parcel) {
        header('Location: parcel_list.php');
        exit;
    }
    $geometry_geojson = $parcel['geojson'];
}

// Fetch lookup data
$land_use_types = $db->query("SELECT land_use_id, land_use_name FROM lkp_land_use_type ORDER BY land_use_name")->fetchAll();
$ownership_types = $db->query("SELECT ownership_id, ownership_name FROM lkp_ownership_type ORDER BY ownership_name")->fetchAll();
$wards = $db->query("SELECT woreda_id as ward_id, woreda_name as ward_name FROM lkq_woreda ORDER BY woreda_name")->fetchAll();
$cities = $db->query("SELECT city_id, city_name FROM lkq_city ORDER BY city_name")->fetchAll();
$regions = $db->query("SELECT region_id, region_name FROM lkq_region ORDER BY region_name")->fetchAll();

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Gather form data
    $parcel_number = $_POST['parcel_number'] ?? '';
    $parcel_registration_number = $_POST['parcel_registration_number'] ?? '';
    $land_use_type_id = $_POST['land_use_type_id'] ?? null;
    $ownership_type_id = $_POST['ownership_type_id'] ?? null;
    $owner_name = $_POST['owner_name'] ?? '';
    $owner_id_number = $_POST['owner_id_number'] ?? '';
    $owner_contact = $_POST['owner_contact'] ?? '';
    $region_id = $_POST['region_id'] ?? null;
    $city_id = $_POST['city_id'] ?? null;
    $ward_id = $_POST['ward_id'] ?? null;
    $street_name = $_POST['street_name'] ?? '';
    $house_number = $_POST['house_number'] ?? '';
    $landmark = $_POST['landmark'] ?? '';
    $registration_date = $_POST['registration_date'] ?? null;
    $spatial_accuracy = $_POST['spatial_accuracy'] ?? '';
    $survey_date = $_POST['survey_date'] ?? null;
    $survey_method = $_POST['survey_method'] ?? '';

    // Geometry from map (GeoJSON string in 4326)
    $geojson_str = $_POST['geometry'] ?? '';

    if (empty($parcel_number) || empty($geojson_str)) {
        $error = 'Parcel number and geometry are required.';
    } else {
        if ($parcel_id) {
            // Update - transform from 4326 to 20137 on the fly
            $sql = "UPDATE ugims_parcel SET
                    parcel_number = :parcel_number,
                    parcel_registration_number = :reg_number,
                    geometry = ST_Transform(ST_SetSRID(ST_GeomFromGeoJSON(:geojson), 4326), 20137),
                    land_use_type_id = :land_use,
                    ownership_type_id = :ownership,
                    owner_name = :owner_name,
                    owner_id_number = :owner_id,
                    owner_contact = :owner_contact,
                    region_id = :region_id,
                    city_id = :city_id,
                    woreda_id = :ward_id,
                    street_name = :street,
                    house_number = :house,
                    landmark = :landmark,
                    registration_date = :reg_date,
                    spatial_accuracy = :accuracy,
                    survey_date = :survey_date,
                    survey_method = :survey_method,
                    last_updated = NOW()
                    WHERE parcel_id = :id";
            $stmt = $db->prepare($sql);
            $params = [
                ':id' => $parcel_id,
                ':parcel_number' => $parcel_number,
                ':reg_number' => $parcel_registration_number,
                ':geojson' => $geojson_str,
                ':land_use' => $land_use_type_id,
                ':ownership' => $ownership_type_id,
                ':owner_name' => $owner_name,
                ':owner_id' => $owner_id_number,
                ':owner_contact' => $owner_contact,
                ':region_id' => $region_id,
                ':city_id' => $city_id,
                ':ward_id' => $ward_id,
                ':street' => $street_name,
                ':house' => $house_number,
                ':landmark' => $landmark,
                ':reg_date' => $registration_date,
                ':accuracy' => $spatial_accuracy,
                ':survey_date' => $survey_date,
                ':survey_method' => $survey_method
            ];
            if ($stmt->execute($params)) {
                $message = 'Parcel updated successfully.';
            } else {
                $error = 'Failed to update parcel.';
            }
        } else {
            // Insert - note: no created_date column, only last_updated
            $sql = "INSERT INTO ugims_parcel (
                    parcel_number, parcel_registration_number, geometry,
                    land_use_type_id, ownership_type_id,
                    owner_name, owner_id_number, owner_contact,
                    region_id, city_id, woreda_id,
                    street_name, house_number, landmark,
                    registration_date, spatial_accuracy,
                    survey_date, survey_method, last_updated
                ) VALUES (
                    :parcel_number, :reg_number, ST_Transform(ST_SetSRID(ST_GeomFromGeoJSON(:geojson), 4326), 20137),
                    :land_use, :ownership,
                    :owner_name, :owner_id, :owner_contact,
                    :region_id, :city_id, :ward_id,
                    :street, :house, :landmark,
                    :reg_date, :accuracy,
                    :survey_date, :survey_method, NOW()
                ) RETURNING parcel_id";
            $stmt = $db->prepare($sql);
            $params = [
                ':parcel_number' => $parcel_number,
                ':reg_number' => $parcel_registration_number,
                ':geojson' => $geojson_str,
                ':land_use' => $land_use_type_id,
                ':ownership' => $ownership_type_id,
                ':owner_name' => $owner_name,
                ':owner_id' => $owner_id_number,
                ':owner_contact' => $owner_contact,
                ':region_id' => $region_id,
                ':city_id' => $city_id,
                ':ward_id' => $ward_id,
                ':street' => $street_name,
                ':house' => $house_number,
                ':landmark' => $landmark,
                ':reg_date' => $registration_date,
                ':accuracy' => $spatial_accuracy,
                ':survey_date' => $survey_date,
                ':survey_method' => $survey_method
            ];
            if ($stmt->execute($params)) {
                $new_id = $stmt->fetchColumn();
                header('Location: parcel_edit.php?id=' . $new_id);
                exit;
            } else {
                $error = 'Failed to create parcel.';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title><?= $parcel_id ? 'Edit' : 'Add' ?> Parcel</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.css" />
    <style>
        #map { height: 500px; width: 100%; margin-bottom: 20px; border-radius: 5px; }
        .form-row { display: flex; gap: 20px; flex-wrap: wrap; }
        .form-col { flex: 1 1 300px; }
        .info-box {
            background: #f8f9fa;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="header">
        <h2><?= $parcel_id ? 'Edit' : 'Add' ?> Parcel</h2>
        <div>
            <a href="parcel_list.php">← Back to List</a>
            <a href="dashboard.php">Dashboard</a>
        </div>
    </div>
    <div class="container">
        <?php if ($message): ?><div class="message"><?= $message ?></div><?php endif; ?>
        <?php if ($error): ?><div class="error"><?= $error ?></div><?php endif; ?>

        <form method="post" id="parcelForm">
            <div class="form-row">
                <div class="form-col">
                    <div class="form-group">
                        <label>Parcel Number *</label>
                        <input type="text" name="parcel_number" value="<?= htmlspecialchars($parcel['parcel_number'] ?? '') ?>" required>
                    </div>
                    <div class="form-group">
                        <label>Registration Number</label>
                        <input type="text" name="parcel_registration_number" value="<?= htmlspecialchars($parcel['parcel_registration_number'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Land Use Type</label>
                        <select name="land_use_type_id">
                            <option value="">-- Select --</option>
                            <?php foreach ($land_use_types as $l): ?>
                            <option value="<?= $l['land_use_id'] ?>" <?= (($parcel['land_use_type_id'] ?? '') == $l['land_use_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($l['land_use_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Ownership Type</label>
                        <select name="ownership_type_id">
                            <option value="">-- Select --</option>
                            <?php foreach ($ownership_types as $o): ?>
                            <option value="<?= $o['ownership_id'] ?>" <?= (($parcel['ownership_type_id'] ?? '') == $o['ownership_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($o['ownership_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Owner Name</label>
                        <input type="text" name="owner_name" value="<?= htmlspecialchars($parcel['owner_name'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Owner ID Number</label>
                        <input type="text" name="owner_id_number" value="<?= htmlspecialchars($parcel['owner_id_number'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Owner Contact</label>
                        <input type="text" name="owner_contact" value="<?= htmlspecialchars($parcel['owner_contact'] ?? '') ?>">
                    </div>
                </div>
                <div class="form-col">
                    <div class="form-group">
                        <label>Region</label>
                        <select name="region_id">
                            <option value="">-- Select --</option>
                            <?php foreach ($regions as $r): ?>
                            <option value="<?= $r['region_id'] ?>" <?= (($parcel['region_id'] ?? '') == $r['region_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($r['region_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>City</label>
                        <select name="city_id">
                            <option value="">-- Select --</option>
                            <?php foreach ($cities as $c): ?>
                            <option value="<?= $c['city_id'] ?>" <?= (($parcel['city_id'] ?? '') == $c['city_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($c['city_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Woreda</label>
                        <select name="ward_id">
                            <option value="">-- Select --</option>
                            <?php foreach ($wards as $w): ?>
                            <option value="<?= $w['ward_id'] ?>" <?= (($parcel['ward_id'] ?? '') == $w['ward_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($w['ward_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Street Name</label>
                        <input type="text" name="street_name" value="<?= htmlspecialchars($parcel['street_name'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>House Number</label>
                        <input type="text" name="house_number" value="<?= htmlspecialchars($parcel['house_number'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Landmark</label>
                        <input type="text" name="landmark" value="<?= htmlspecialchars($parcel['landmark'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Registration Date</label>
                        <input type="date" name="registration_date" value="<?= htmlspecialchars($parcel['registration_date'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Spatial Accuracy</label>
                        <input type="text" name="spatial_accuracy" value="<?= htmlspecialchars($parcel['spatial_accuracy'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Survey Date</label>
                        <input type="date" name="survey_date" value="<?= htmlspecialchars($parcel['survey_date'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Survey Method</label>
                        <input type="text" name="survey_method" value="<?= htmlspecialchars($parcel['survey_method'] ?? '') ?>">
                    </div>
                </div>
            </div>

            <div class="info-box">
                <strong>Draw Parcel Boundary on Map:</strong> Draw or edit the parcel boundary.
                <?php if ($parcel_id): ?>
                The existing boundary will appear automatically (converted to WGS84 for display).
                <?php endif; ?>
                <div>Coordinate System: WGS84 (EPSG:4326) for display - automatically converted to UTM (EPSG:20137) by the database.</div>
            </div>
            <div id="map"></div>
            <input type="hidden" name="geometry" id="geometryInput" value='<?= htmlspecialchars($geometry_geojson ?? '') ?>'>

            <button type="submit">Save Parcel</button>
        </form>
    </div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.js"></script>
    <script>
        // Initialize map with default view (Addis Ababa in WGS84)
        var map = L.map('map').setView([9.03, 38.74], 12);
        
        // Add base layer
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(map);

        // Feature group for drawn items
        var drawnItems = new L.FeatureGroup();
        map.addLayer(drawnItems);

        // Initialize draw control
        var drawControl = new L.Control.Draw({
            edit: { 
                featureGroup: drawnItems,
                edit: true,
                remove: true
            },
            draw: { 
                polygon: true, 
                rectangle: true, 
                circle: false, 
                marker: false, 
                polyline: false,
                circlemarker: false
            }
        });
        map.addControl(drawControl);

        // Load existing geometry if editing
        <?php if ($geometry_geojson): ?>
        var existingGeo = <?= $geometry_geojson ?>;
        
        try {
            var geoJsonLayer = L.geoJSON(existingGeo, {
                onEachFeature: function(feature, layer) {
                    drawnItems.addLayer(layer);
                }
            });
            
            // Wait for map to be ready and then zoom to bounds
            setTimeout(function() {
                if (drawnItems.getLayers().length > 0) {
                    map.fitBounds(drawnItems.getBounds(), {
                        padding: [50, 50],
                        maxZoom: 18
                    });
                }
            }, 500);
        } catch (e) {
            console.error('Error loading geometry:', e);
        }
        <?php endif; ?>

        // When a new polygon is drawn, update hidden input
        map.on('draw:created', function(e) {
            var layer = e.layer;
            drawnItems.clearLayers(); // remove previous if any
            drawnItems.addLayer(layer);
            updateGeometryInput();
        });

        map.on('draw:edited', function(e) {
            updateGeometryInput();
        });

        map.on('draw:deleted', function(e) {
            document.getElementById('geometryInput').value = '';
        });

        function updateGeometryInput() {
            var geoJson = drawnItems.toGeoJSON();
            if (geoJson.features.length > 0) {
                document.getElementById('geometryInput').value = JSON.stringify(geoJson.features[0].geometry);
            } else {
                document.getElementById('geometryInput').value = '';
            }
        }

        // Before form submit, ensure geometry is set
        document.getElementById('parcelForm').addEventListener('submit', function(e) {
            if (!document.getElementById('geometryInput').value) {
                alert('Please draw a polygon on the map.');
                e.preventDefault();
            }
        });

        // Add a manual zoom button
        var zoomButton = L.control({position: 'topleft'});
        zoomButton.onAdd = function(map) {
            var div = L.DomUtil.create('div', 'leaflet-bar leaflet-control leaflet-control-custom');
            div.innerHTML = '<a href="#" title="Zoom to feature" style="background-color: white; width: 30px; height: 30px; display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: bold;">🔍</a>';
            div.onclick = function() {
                if (drawnItems.getLayers().length > 0) {
                    map.fitBounds(drawnItems.getBounds(), {
                        padding: [50, 50],
                        maxZoom: 18
                    });
                } else {
                    alert('No feature to zoom to');
                }
                return false;
            };
            return div;
        };
        zoomButton.addTo(map);
    </script>
</body>
</html>
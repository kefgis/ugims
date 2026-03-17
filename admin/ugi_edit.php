<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../api/config/database.php';
require_once '../api/utils/geometry.php';

$db = (new Database())->getConnection();

$ugi_id = $_GET['id'] ?? null;
$asset = null;
$geometry_geojson = null;

if ($ugi_id) {
    // Fetch existing asset - transform on database side to WGS84 for Leaflet
    $stmt = $db->prepare("SELECT *, ST_AsGeoJSON(ST_Transform(geometry, 4326)) as geojson FROM ugims_ugi WHERE ugi_id = :id");
    $stmt->execute([':id' => $ugi_id]);
    $asset = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$asset) {
        header('Location: ugi_list.php');
        exit;
    }
    $geometry_geojson = $asset['geojson'];
}

// Fetch lookup data for dropdowns
$types = $db->query("SELECT ugi_type_id, type_name FROM lkp_ethiopia_ugi_type ORDER BY type_name")->fetchAll();
$conditions = $db->query("SELECT status_id, status_name FROM lkp_condition_status ORDER BY status_id")->fetchAll();
$operational = $db->query("SELECT status_id, status_name FROM lkp_operational_status ORDER BY status_id")->fetchAll();
$parcels = $db->query("SELECT parcel_id, parcel_number FROM ugims_parcel ORDER BY parcel_number")->fetchAll();

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Gather form data
    $parcel_id = $_POST['parcel_id'] ?? null;
    $name = $_POST['name'] ?? '';
    $amharic_name = $_POST['amharic_name'] ?? '';
    $ugi_type_id = $_POST['ugi_type_id'] ?? 0;
    $condition_status_id = $_POST['condition_status_id'] ?? null;
    $operational_status_id = $_POST['operational_status_id'] ?? null;
    $has_lighting = isset($_POST['has_lighting']) ? 'true' : 'false';
    $has_irrigation = isset($_POST['has_irrigation']) ? 'true' : 'false';
    $has_fencing = isset($_POST['has_fencing']) ? 'true' : 'false';
    $visitor_capacity = $_POST['visitor_capacity'] ?? null;
    $contact_person = $_POST['contact_person'] ?? '';
    $contact_phone = $_POST['contact_phone'] ?? '';
    $contact_email = $_POST['contact_email'] ?? '';
    $tree_count = $_POST['tree_count'] ?? 0;
    
    // Geometry from map (GeoJSON string in 4326)
    $geojson_str = $_POST['geometry'] ?? '';

    if (empty($parcel_id) || empty($name) || empty($ugi_type_id) || empty($geojson_str)) {
        $error = 'Parcel, name, type, and geometry are required.';
    } else {
        if ($ugi_id) {
            // Update - let PostGIS handle transformation
            $sql = "UPDATE ugims_ugi SET
                    parcel_id = :parcel_id,
                    name = :name,
                    amharic_name = :amharic,
                    ugi_type_id = :type_id,
                    geometry = ST_Transform(ST_SetSRID(ST_GeomFromGeoJSON(:geojson), 4326), 20137),
                    condition_status_id = :condition_id,
                    operational_status_id = :operational_id,
                    has_lighting = :lighting,
                    has_irrigation = :irrigation,
                    has_fencing = :fencing,
                    visitor_capacity = :capacity,
                    contact_person = :person,
                    contact_phone = :phone,
                    contact_email = :email,
                    tree_count = :trees,
                    last_updated = NOW()
                    WHERE ugi_id = :id";
            $stmt = $db->prepare($sql);
            $params = [
                ':id' => $ugi_id,
                ':parcel_id' => $parcel_id,
                ':name' => $name,
                ':amharic' => $amharic_name,
                ':type_id' => $ugi_type_id,
                ':geojson' => $geojson_str,
                ':condition_id' => $condition_status_id,
                ':operational_id' => $operational_status_id,
                ':lighting' => $has_lighting,
                ':irrigation' => $has_irrigation,
                ':fencing' => $has_fencing,
                ':capacity' => $visitor_capacity,
                ':person' => $contact_person,
                ':phone' => $contact_phone,
                ':email' => $contact_email,
                ':trees' => $tree_count
            ];
            if ($stmt->execute($params)) {
                $message = 'Asset updated successfully.';
            } else {
                $error = 'Failed to update asset.';
            }
        } else {
            // Insert - note: created_date and last_updated both exist in ugims_ugi
            $sql = "INSERT INTO ugims_ugi (
                    parcel_id, name, amharic_name, ugi_type_id, geometry,
                    condition_status_id, operational_status_id,
                    has_lighting, has_irrigation, has_fencing,
                    visitor_capacity, contact_person, contact_phone,
                    contact_email, tree_count, created_date, last_updated
                ) VALUES (
                    :parcel_id, :name, :amharic, :type_id, ST_Transform(ST_SetSRID(ST_GeomFromGeoJSON(:geojson), 4326), 20137),
                    :condition_id, :operational_id,
                    :lighting, :irrigation, :fencing,
                    :capacity, :person, :phone,
                    :email, :trees, NOW(), NOW()
                ) RETURNING ugi_id";
            $stmt = $db->prepare($sql);
            $params = [
                ':parcel_id' => $parcel_id,
                ':name' => $name,
                ':amharic' => $amharic_name,
                ':type_id' => $ugi_type_id,
                ':geojson' => $geojson_str,
                ':condition_id' => $condition_status_id,
                ':operational_id' => $operational_status_id,
                ':lighting' => $has_lighting,
                ':irrigation' => $has_irrigation,
                ':fencing' => $has_fencing,
                ':capacity' => $visitor_capacity,
                ':person' => $contact_person,
                ':phone' => $contact_phone,
                ':email' => $contact_email,
                ':trees' => $tree_count
            ];
            if ($stmt->execute($params)) {
                $new_id = $stmt->fetchColumn();
                header('Location: ugi_edit.php?id=' . $new_id);
                exit;
            } else {
                $error = 'Failed to create asset.';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title><?= $ugi_id ? 'Edit' : 'Add' ?> UGI Asset</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.css" />
    <style>
        #map { height: 500px; width: 100%; margin-bottom: 20px; border-radius: 5px; }
        .form-row { display: flex; gap: 20px; flex-wrap: wrap; }
        .form-col { flex: 1 1 300px; }
        .checkbox-group { margin-top: 5px; }
        .checkbox-group label { display: inline-block; margin-right: 15px; font-weight: normal; }
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
        <h2><?= $ugi_id ? 'Edit' : 'Add' ?> UGI Asset</h2>
        <div>
            <a href="ugi_list.php">← Back to List</a>
            <a href="dashboard.php">Dashboard</a>
        </div>
    </div>
    <div class="container">
        <?php if ($message): ?><div class="message"><?= $message ?></div><?php endif; ?>
        <?php if ($error): ?><div class="error"><?= $error ?></div><?php endif; ?>

        <form method="post" id="assetForm">
            <div class="form-row">
                <div class="form-col">
                    <div class="form-group">
                        <label>Parcel *</label>
                        <select name="parcel_id" required>
                            <option value="">-- Select Parcel --</option>
                            <?php foreach ($parcels as $p): ?>
                            <option value="<?= $p['parcel_id'] ?>" <?= (($asset['parcel_id'] ?? '') == $p['parcel_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($p['parcel_number']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Name *</label>
                        <input type="text" name="name" value="<?= htmlspecialchars($asset['name'] ?? '') ?>" required>
                    </div>
                    <div class="form-group">
                        <label>Amharic Name</label>
                        <input type="text" name="amharic_name" value="<?= htmlspecialchars($asset['amharic_name'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>UGI Type *</label>
                        <select name="ugi_type_id" required>
                            <option value="">-- Select Type --</option>
                            <?php foreach ($types as $t): ?>
                            <option value="<?= $t['ugi_type_id'] ?>" <?= (($asset['ugi_type_id'] ?? 0) == $t['ugi_type_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($t['type_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Condition</label>
                        <select name="condition_status_id">
                            <option value="">-- Select --</option>
                            <?php foreach ($conditions as $c): ?>
                            <option value="<?= $c['status_id'] ?>" <?= (($asset['condition_status_id'] ?? '') == $c['status_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($c['status_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Operational Status</label>
                        <select name="operational_status_id">
                            <option value="">-- Select --</option>
                            <?php foreach ($operational as $o): ?>
                            <option value="<?= $o['status_id'] ?>" <?= (($asset['operational_status_id'] ?? '') == $o['status_id']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($o['status_name']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
                <div class="form-col">
                    <div class="form-group">
                        <label>Visitor Capacity</label>
                        <input type="number" name="visitor_capacity" value="<?= htmlspecialchars($asset['visitor_capacity'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Tree Count</label>
                        <input type="number" name="tree_count" value="<?= htmlspecialchars($asset['tree_count'] ?? '0') ?>">
                    </div>
                    <div class="form-group">
                        <label>Contact Person</label>
                        <input type="text" name="contact_person" value="<?= htmlspecialchars($asset['contact_person'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Contact Phone</label>
                        <input type="text" name="contact_phone" value="<?= htmlspecialchars($asset['contact_phone'] ?? '') ?>">
                    </div>
                    <div class="form-group">
                        <label>Contact Email</label>
                        <input type="email" name="contact_email" value="<?= htmlspecialchars($asset['contact_email'] ?? '') ?>">
                    </div>
                    <div class="form-group checkbox-group">
                        <label><input type="checkbox" name="has_lighting" <?= ($asset['has_lighting'] ?? false) ? 'checked' : '' ?>> Lighting</label>
                        <label><input type="checkbox" name="has_irrigation" <?= ($asset['has_irrigation'] ?? false) ? 'checked' : '' ?>> Irrigation</label>
                        <label><input type="checkbox" name="has_fencing" <?= ($asset['has_fencing'] ?? false) ? 'checked' : '' ?>> Fencing</label>
                    </div>
                </div>
            </div>

            <div class="info-box">
                <strong>Draw Polygon on Map:</strong> Draw or edit the boundary of this UGI asset.
                <?php if ($ugi_id): ?>
                The existing boundary will appear automatically (converted to WGS84 for display).
                <?php endif; ?>
                <div>Coordinate System: WGS84 (EPSG:4326) for display - automatically converted to UTM (EPSG:20137) by the database.</div>
            </div>
            <div id="map"></div>
            <input type="hidden" name="geometry" id="geometryInput" value='<?= htmlspecialchars($geometry_geojson ?? '') ?>'>

            <button type="submit">Save Asset</button>
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
        document.getElementById('assetForm').addEventListener('submit', function(e) {
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
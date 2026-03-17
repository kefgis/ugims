<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

require_once '../../api/config/database.php';
$db = (new Database())->getConnection();

$import_type = $_GET['type'] ?? ($_POST['type'] ?? 'parcel');
$mapping_id = $_GET['mapping'] ?? null;
$saved_mapping = null;

if ($mapping_id) {
    $stmt = $db->prepare("SELECT * FROM ugims_import_mapping WHERE mapping_id = ?");
    $stmt->execute([$mapping_id]);
    $saved_mapping = $stmt->fetch(PDO::FETCH_ASSOC);
}

// Define database fields for each import type
$db_fields = [
    'parcel' => [
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
    ],
    'ugi' => [
        'name' => 'UGI Name (required)',
        'amharic_name' => 'Amharic Name',
        'ugi_type_id' => 'UGI Type ID (required)',
        'parcel_id' => 'Parcel ID (required - UUID)',
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
];

// Lookup values for dropdowns (to help users)
$lookups = [
    'ugi_type' => $db->query("SELECT ugi_type_id, type_name FROM lkp_ethiopia_ugi_type ORDER BY type_name")->fetchAll(),
    'condition' => $db->query("SELECT status_id, status_name FROM lkp_condition_status ORDER BY status_id")->fetchAll(),
    'operational' => $db->query("SELECT status_id, status_name FROM lkp_operational_status ORDER BY status_id")->fetchAll(),
    'land_use' => $db->query("SELECT land_use_id, land_use_name FROM lkp_land_use_type ORDER BY land_use_name")->fetchAll(),
    'ownership' => $db->query("SELECT ownership_id, ownership_name FROM lkp_ownership_type ORDER BY ownership_name")->fetchAll()
];
?>
<!DOCTYPE html>
<html>
<head>
    <title>Field Mapping - <?= ucfirst($import_type) ?> Import</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
    <style>
        .mapping-container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-top: 20px;
        }
        .upload-area {
            border: 2px dashed #3498db;
            border-radius: 8px;
            padding: 40px;
            text-align: center;
            background: #f9f9f9;
            cursor: pointer;
            margin-bottom: 20px;
        }
        .upload-area.dragover {
            background: #e1f0fa;
            border-color: #2ecc71;
        }
        .mapping-table {
            width: 100%;
            border-collapse: collapse;
        }
        .mapping-table th, .mapping-table td {
            padding: 12px;
            border-bottom: 1px solid #ecf0f1;
        }
        .mapping-table th {
            background: #f8f9fa;
            font-weight: 600;
        }
        .field-select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .preview-table {
            max-height: 400px;
            overflow-y: auto;
            border: 1px solid #ddd;
            margin-top: 20px;
        }
        .preview-table table {
            width: 100%;
            border-collapse: collapse;
        }
        .preview-table th {
            position: sticky;
            top: 0;
            background: #34495e;
            color: white;
            padding: 10px;
        }
        .preview-table td {
            padding: 8px;
            border-bottom: 1px solid #ecf0f1;
        }
        .lookup-hint {
            font-size: 0.85rem;
            color: #7f8c8d;
            margin-top: 2px;
        }
        .save-mapping-form {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 4px;
            margin-top: 20px;
        }
        .badge-success {
            background: #2ecc71;
            color: white;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8rem;
        }
    </style>
</head>
<body>
    <div class="header">
        <h2>Field Mapping - <?= ucfirst($import_type) ?> Import</h2>
        <div>
            <a href="index.php">Import Dashboard</a>
            <a href="../dashboard.php">Main Dashboard</a>
        </div>
    </div>
    <div class="container">
        <div class="mapping-container">
            <!-- Step 1: Upload Shapefile -->
            <div class="upload-area" id="dropArea">
                <p>📁 Drag and drop shapefile files here, or click to select</p>
                <p class="small">(Select .shp, .shx, .dbf files or a ZIP archive)</p>
                <input type="file" id="fileInput" multiple accept=".shp,.shx,.dbf,.zip" style="display: none;">
                <button type="button" onclick="document.getElementById('fileInput').click()" class="btn">Browse Files</button>
                <div id="fileList" style="margin-top: 15px;"></div>
            </div>

            <!-- Step 2: Field Mapping (shown after upload) -->
            <div id="mappingSection" style="display: none;">
                <h3>Step 2: Map Fields</h3>
                <p>Match your shapefile fields to database columns. Required fields are marked.</p>

                <div class="save-mapping-form">
                    <h4>Save this mapping for future use</h4>
                    <div style="display: flex; gap: 10px; align-items: center;">
                        <input type="text" id="mappingName" placeholder="Enter mapping name" style="flex: 1;">
                        <button onclick="saveMapping()" class="btn">Save Mapping</button>
                    </div>
                </div>

                <table class="mapping-table" id="mappingTable">
                    <thead>
                        <tr>
                            <th>Database Field</th>
                            <th>Description</th>
                            <th>Shapefile Field</th>
                            <th>Sample Value</th>
                        </tr>
                    </thead>
                    <tbody id="mappingBody">
                        <!-- Populated by JavaScript -->
                    </tbody>
                </table>

                <!-- Lookup value hints -->
                <div style="margin: 20px 0; padding: 15px; background: #f8f9fa; border-radius: 4px;">
                    <h4>📋 Lookup Value References</h4>
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                        <?php if ($import_type == 'ugi'): ?>
                        <div>
                            <strong>UGI Types:</strong>
                            <ul style="margin: 5px 0; font-size: 0.9rem;">
                                <?php foreach ($lookups['ugi_type'] as $t): ?>
                                <li><?= $t['ugi_type_id'] ?>: <?= htmlspecialchars($t['type_name']) ?></li>
                                <?php endforeach; ?>
                            </ul>
                        </div>
                        <div>
                            <strong>Condition Status:</strong>
                            <ul style="margin: 5px 0; font-size: 0.9rem;">
                                <?php foreach ($lookups['condition'] as $c): ?>
                                <li><?= $c['status_id'] ?>: <?= htmlspecialchars($c['status_name']) ?></li>
                                <?php endforeach; ?>
                            </ul>
                        </div>
                        <?php else: ?>
                        <div>
                            <strong>Land Use Types:</strong>
                            <ul style="margin: 5px 0; font-size: 0.9rem;">
                                <?php foreach ($lookups['land_use'] as $l): ?>
                                <li><?= $l['land_use_id'] ?>: <?= htmlspecialchars($l['land_use_name']) ?></li>
                                <?php endforeach; ?>
                            </ul>
                        </div>
                        <div>
                            <strong>Ownership Types:</strong>
                            <ul style="margin: 5px 0; font-size: 0.9rem;">
                                <?php foreach ($lookups['ownership'] as $o): ?>
                                <li><?= $o['ownership_id'] ?>: <?= htmlspecialchars($o['ownership_name']) ?></li>
                                <?php endforeach; ?>
                            </ul>
                        </div>
                        <?php endif; ?>
                    </div>
                </div>

                <div style="text-align: right;">
                    <button onclick="previewImport()" class="btn">Preview Import</button>
                    <button onclick="startImport()" class="btn btn-primary">Start Import</button>
                </div>
            </div>

            <!-- Step 3: Preview (shown after mapping) -->
            <div id="previewSection" style="display: none;">
                <h3>Step 3: Preview Data</h3>
                <div id="previewContent" class="preview-table"></div>
                <div style="margin-top: 20px; text-align: right;">
                    <button onclick="confirmImport()" class="btn btn-success">Confirm Import</button>
                    <button onclick="goBackToMapping()" class="btn">Adjust Mapping</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let currentSessionId = null;
        let shapefileFields = [];

        // Drag and drop handling
        const dropArea = document.getElementById('dropArea');
        const fileInput = document.getElementById('fileInput');
        const fileList = document.getElementById('fileList');

        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            dropArea.addEventListener(eventName, preventDefaults, false);
        });

        function preventDefaults(e) {
            e.preventDefault();
            e.stopPropagation();
        }

        ['dragenter', 'dragover'].forEach(eventName => {
            dropArea.addEventListener(eventName, () => dropArea.classList.add('dragover'));
        });

        ['dragleave', 'drop'].forEach(eventName => {
            dropArea.addEventListener(eventName, () => dropArea.classList.remove('dragover'));
        });

        dropArea.addEventListener('drop', handleDrop);
        fileInput.addEventListener('change', handleFiles);

        function handleDrop(e) {
            const dt = e.dataTransfer;
            const files = dt.files;
            uploadFiles(files);
        }

        function handleFiles(e) {
            uploadFiles(e.target.files);
        }

        function uploadFiles(files) {
            const formData = new FormData();
            for (let file of files) {
                formData.append('shapefiles[]', file);
            }
            formData.append('import_type', '<?= $import_type ?>');
            formData.append('action', 'analyze');

            // Show uploading message
            fileList.innerHTML = '<p>Uploading and analyzing shapefile...</p>';

            fetch('ajax/get_fields.php', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    currentSessionId = data.session_id;
                    shapefileFields = data.fields;
                    displayFileList(data.files);
                    showMappingSection(data.fields, data.preview);
                } else {
                    alert('Error: ' + data.error);
                }
            })
            .catch(error => {
                alert('Upload failed: ' + error.message);
            });
        }

        function displayFileList(files) {
            let html = '<h4>Uploaded Files:</h4>';
            files.forEach(file => {
                html += `<div>✅ ${file}</div>`;
            });
            fileList.innerHTML = html;
        }

        function showMappingSection(fields, preview) {
            document.getElementById('mappingSection').style.display = 'block';
            
            // Build mapping table
            let html = '';
            const dbFields = <?= json_encode($db_fields[$import_type]) ?>;
            
            <?php if ($saved_mapping): ?>
            const savedMapping = <?= json_encode(json_decode($saved_mapping['field_mapping'], true)) ?>;
            <?php else: ?>
            const savedMapping = {};
            <?php endif; ?>

            for (let [field, description] of Object.entries(dbFields)) {
                let isRequired = description.includes('(required)');
                html += '<tr>';
                html += `<td><strong>${field}</strong> ${isRequired ? '<span class="badge-success">required</span>' : ''}</td>`;
                html += `<td>${description}</td>`;
                html += '<td>';
                html += `<select class="field-select" data-field="${field}" onchange="updateMapping('${field}', this.value)">`;
                html += '<option value="">-- Ignore --</option>';
                
                // Add shapefile fields
                fields.forEach(f => {
                    let selected = (savedMapping[field] === f) ? 'selected' : '';
                    html += `<option value="${f}" ${selected}>${f}</option>`;
                });
                
                html += '</select>';
                html += '</td>';
                html += `<td id="sample-${field}">-</td>`;
                html += '</tr>';
            }
            
            document.getElementById('mappingBody').innerHTML = html;
            
            // Show sample data for first few records
            showSampleData(preview);
        }

        function showSampleData(preview) {
            // This would display sample rows from the shapefile
            // Implementation depends on preview data format
        }

        function updateMapping(field, shapefileField) {
            // Store mapping in memory
            if (!window.mappings) window.mappings = {};
            window.mappings[field] = shapefileField;
            
            // Optionally fetch sample value
            if (shapefileField) {
                // You could fetch a sample value from the server
            }
        }

        function saveMapping() {
            const name = document.getElementById('mappingName').value;
            if (!name) {
                alert('Please enter a mapping name');
                return;
            }

            const mapping = {};
            document.querySelectorAll('.field-select').forEach(select => {
                if (select.value) {
                    mapping[select.dataset.field] = select.value;
                }
            });

            fetch('ajax/save_mapping.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    name: name,
                    type: '<?= $import_type ?>',
                    mapping: mapping
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Mapping saved successfully!');
                } else {
                    alert('Error saving mapping: ' + data.error);
                }
            });
        }

        function previewImport() {
            const mapping = getCurrentMapping();
            
            fetch('ajax/preview_import.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    session_id: currentSessionId,
                    mapping: mapping
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    document.getElementById('mappingSection').style.display = 'none';
                    document.getElementById('previewSection').style.display = 'block';
                    document.getElementById('previewContent').innerHTML = data.preview;
                } else {
                    alert('Preview failed: ' + data.error);
                }
            });
        }

        function getCurrentMapping() {
            const mapping = {};
            document.querySelectorAll('.field-select').forEach(select => {
                if (select.value) {
                    mapping[select.dataset.field] = select.value;
                }
            });
            return mapping;
        }

        function startImport() {
            if (confirm('Start import with current mapping?')) {
                const mapping = getCurrentMapping();
                
                fetch('process_import.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        session_id: currentSessionId,
                        mapping: mapping,
                        action: 'start'
                    })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert(`Import started: ${data.records_imported} records imported`);
                        window.location.href = 'import_history.php';
                    } else {
                        alert('Import failed: ' + data.error);
                    }
                });
            }
        }

        function confirmImport() {
            // Similar to startImport but with confirmation
            startImport();
        }

        function goBackToMapping() {
            document.getElementById('previewSection').style.display = 'none';
            document.getElementById('mappingSection').style.display = 'block';
        }
    </script>
</body>
</html>
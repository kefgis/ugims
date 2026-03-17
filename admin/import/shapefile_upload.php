<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../login.php');
    exit;
}

$import_type = $_GET['type'] ?? 'parcel'; // 'parcel' or 'ugi'
?>
<!DOCTYPE html>
<html>
<head>
    <title>Import Shapefile - <?= ucfirst($import_type) ?></title>
    <link rel="stylesheet" href="../../assets/css/style.css">
    <style>
        .upload-area {
            border: 2px dashed #3498db;
            border-radius: 8px;
            padding: 40px;
            text-align: center;
            background: #f9f9f9;
            cursor: pointer;
            margin: 20px 0;
        }
        .upload-area.dragover {
            background: #e1f0fa;
            border-color: #2ecc71;
        }
        .file-list { margin-top: 20px; }
        .file-item { padding: 8px; background: #f0f0f0; margin: 5px 0; border-radius: 4px; }
        .progress-bar { height: 20px; background: #ecf0f1; border-radius: 10px; overflow: hidden; display: none; }
        .progress-fill { height: 100%; background: #2ecc71; width: 0%; transition: width 0.3s; }
    </style>
</head>
<body>
    <div class="header">
        <h2>Import Shapefile - <?= ucfirst($import_type) ?></h2>
        <div>
            <a href="../dashboard.php">Dashboard</a>
            <a href="../logout.php">Logout</a>
        </div>
    </div>
    <div class="container">
        <div class="info-message">
            <p>Upload a shapefile (as individual files or ZIP archive) to import into the <strong><?= $import_type ?></strong> table.</p>
            <p>Required files: <code>.shp</code>, <code>.shx</code>, <code>.dbf</code></p>
            <p>Coordinate system: <strong>EPSG:20137 (UTM zone 37S)</strong></p>
        </div>

        <form id="uploadForm" enctype="multipart/form-data">
            <input type="hidden" name="import_type" value="<?= $import_type ?>">
            
            <div class="upload-area" id="dropArea">
                <p>Drag and drop shapefile files here, or click to select</p>
                <p class="small">(You can select multiple files or a ZIP archive)</p>
                <input type="file" name="shapefiles[]" id="fileInput" multiple style="display: none;">
                <button type="button" onclick="document.getElementById('fileInput').click()" class="btn">Browse Files</button>
            </div>

            <div id="fileList" class="file-list"></div>
            
            <div class="form-group">
                <label>Import Options</label>
                <select name="duplicate_handling">
                    <option value="skip">Skip duplicates (based on parcel_number / name)</option>
                    <option value="update">Update existing records</option>
                    <option value="create">Create new records (allow duplicates)</option>
                </select>
            </div>

            <div class="form-group">
                <label>Preview first</label>
                <input type="number" name="preview_count" value="10" min="1" max="100">
            </div>

            <button type="submit" class="btn btn-primary">Upload and Preview</button>
        </form>

        <div class="progress-bar" id="progressBar">
            <div class="progress-fill" id="progressFill"></div>
        </div>

        <div id="previewArea" style="margin-top: 30px; display: none;">
            <h3>Preview</h3>
            <div id="previewContent"></div>
            <button onclick="confirmImport()" class="btn btn-success" style="margin-top: 10px;">Confirm Import</button>
            <button onclick="cancelImport()" class="btn">Cancel</button>
        </div>
    </div>

    <script>
        // Drag and drop handling
        const dropArea = document.getElementById('dropArea');
        const fileInput = document.getElementById('fileInput');
        const fileList = document.getElementById('fileList');
        let uploadedFiles = [];

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
            handleFiles({ target: { files: files } });
        }

        function handleFiles(e) {
            const files = e.target.files;
            uploadedFiles = Array.from(files);
            displayFileList();
        }

        function displayFileList() {
            fileList.innerHTML = '<h4>Selected Files:</h4>';
            uploadedFiles.forEach(file => {
                const div = document.createElement('div');
                div.className = 'file-item';
                div.textContent = `${file.name} (${(file.size/1024).toFixed(2)} KB)`;
                fileList.appendChild(div);
            });
        }

        // Form submission for preview
        document.getElementById('uploadForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const formData = new FormData();
            uploadedFiles.forEach(file => {
                formData.append('shapefiles[]', file);
            });
            formData.append('import_type', document.querySelector('[name=import_type]').value);
            formData.append('preview_count', document.querySelector('[name=preview_count]').value);
            formData.append('action', 'preview');

            document.getElementById('progressBar').style.display = 'block';
            
            try {
                const response = await fetch('process_import.php', {
                    method: 'POST',
                    body: formData
                });
                
                const result = await response.json();
                
                if (result.success) {
                    document.getElementById('previewArea').style.display = 'block';
                    document.getElementById('previewContent').innerHTML = result.preview;
                    // Store import session ID for confirmation
                    window.importSessionId = result.session_id;
                } else {
                    alert('Error: ' + result.error);
                }
            } catch (error) {
                alert('Upload failed: ' + error.message);
            } finally {
                document.getElementById('progressBar').style.display = 'none';
            }
        });

        function confirmImport() {
            // Proceed with actual import
            fetch('process_import.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    action: 'confirm',
                    session_id: window.importSessionId,
                    duplicate_handling: document.querySelector('[name=duplicate_handling]').value
                })
            })
            .then(response => response.json())
            .then(result => {
                if (result.success) {
                    alert(`Import completed: ${result.records_imported} records imported`);
                    window.location.href = 'import_history.php';
                } else {
                    alert('Import failed: ' + result.error);
                }
            });
        }

        function cancelImport() {
            document.getElementById('previewArea').style.display = 'none';
            uploadedFiles = [];
            fileList.innerHTML = '';
        }
    </script>
</body>
</html>
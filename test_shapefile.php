<?php
require_once __DIR__ . '/vendor/autoload.php';

use PhpMyAdmin\ShapeFile\ShapeFile;

echo "✓ Autoloader loaded successfully<br>";

if (class_exists('PhpMyAdmin\ShapeFile\ShapeFile')) {
    echo "✓ ShapeFile class found!<br>";
} else {
    echo "✗ ShapeFile class NOT found<br>";
}

// Check if dbase extension is loaded
if (extension_loaded('dbase')) {
    echo "✓ dbase extension loaded<br>";
} else {
    echo "✗ dbase extension NOT loaded - check php.ini<br>";
}
?>
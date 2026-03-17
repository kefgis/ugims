<?php
$host = 'localhost';
$port = '5432';
$database = 'ugims'; // Default database
$user = 'postgres';     // Default user
$password = 'postgres';         // Your password (often empty in XAMPP)

try {
    $conn = new PDO("pgsql:host=$host;port=$port;dbname=$database", $user, $password);
    echo "✅ Successfully connected to PostgreSQL!";
    
    // Check PostGIS
    $stmt = $conn->query("SELECT PostGIS_Version()");
    $version = $stmt->fetchColumn();
    echo "<br>✅ PostGIS version: " . $version;
    
} catch (PDOException $e) {
    die("❌ Connection failed: " . $e->getMessage());
}
?>
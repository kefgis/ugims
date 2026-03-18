<?php
echo "<h2>UGIMS Database Connection Test</h2>";

// Include the database class
require_once 'api/config/database.php';

echo "<h3>1. Loading Database Class...</h3>";
$db = new Database();
echo "✅ Database class instantiated<br>";

echo "<h3>2. Getting Connection...</h3>";
$conn = $db->getConnection();

if ($conn) {
    echo "✅ Connection object received<br>";
    
    echo "<h3>3. Testing Query...</h3>";
    try {
        $stmt = $conn->query("SELECT 1 as test");
        $result = $stmt->fetch();
        echo "✅ Query executed successfully<br>";
        
        echo "<h3>4. Checking PostgreSQL Version...</h3>";
        $stmt = $conn->query("SELECT version()");
        $version = $stmt->fetchColumn();
        echo "✅ PostgreSQL version: " . $version . "<br>";
        
        echo "<h3>5. Checking Database Tables...</h3>";
        $stmt = $conn->query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' LIMIT 5");
        $tables = $stmt->fetchAll();
        echo "✅ Found " . count($tables) . " tables<br>";
        echo "<ul>";
        foreach ($tables as $table) {
            echo "<li>" . $table['table_name'] . "</li>";
        }
        echo "</ul>";
        
    } catch (PDOException $e) {
        echo "❌ Query failed: " . $e->getMessage() . "<br>";
    }
} else {
    echo "❌ Connection failed - got null<br>";
}

echo "<h3>6. Environment Variables:</h3>";
echo "<pre>";
echo "DB_HOST: " . (getenv('DB_HOST') ?: 'NOT SET') . "\n";
echo "DB_PORT: " . (getenv('DB_PORT') ?: 'NOT SET') . "\n";
echo "DB_NAME: " . (getenv('DB_NAME') ?: 'NOT SET') . "\n";
echo "DB_USER: " . (getenv('DB_USER') ?: 'NOT SET') . "\n";
echo "DB_PASSWORD: " . (getenv('DB_PASSWORD') ? 'SET (hidden)' : 'NOT SET') . "\n";
echo "RENDER: " . (getenv('RENDER') ?: 'NOT SET') . "\n";
echo "APP_ENV: " . (getenv('APP_ENV') ?: 'NOT SET') . "\n";
echo "</pre>";
?>
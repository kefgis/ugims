<?php
echo "<h2>🔍 UGIMS Detailed Database Diagnostic</h2>";

// Turn on error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h3>1. System Information</h3>";
echo "PHP Version: " . phpversion() . "<br>";
echo "Server Software: " . $_SERVER['SERVER_SOFTWARE'] . "<br>";

echo "<h3>2. Checking PostgreSQL Support</h3>";
if (extension_loaded('pdo_pgsql')) {
    echo "✅ PDO PostgreSQL extension is loaded<br>";
} else {
    echo "❌ PDO PostgreSQL extension is NOT loaded<br>";
}

if (extension_loaded('pgsql')) {
    echo "✅ PostgreSQL extension is loaded<br>";
} else {
    echo "❌ PostgreSQL extension is NOT loaded<br>";
}

echo "<h3>3. Environment Variables</h3>";
$env_vars = ['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD', 'RENDER', 'APP_ENV'];
foreach ($env_vars as $var) {
    $value = getenv($var);
    if ($var === 'DB_PASSWORD') {
        echo "$var: " . ($value ? '✓ SET (hidden)' : '✗ NOT SET') . "<br>";
    } else {
        echo "$var: " . ($value ?: '✗ NOT SET') . "<br>";
    }
}

echo "<h3>4. Database Connection Test</h3>";

// Include the database class
require_once 'api/config/database.php';
echo "✅ Database class loaded<br>";

$db = new Database();
echo "✅ Database object created<br>";

echo "<h4>Attempting connection...</h4>";

try {
    $conn = $db->getConnection();
    
    if ($conn) {
        echo "✅ Connection object received<br>";
        
        // Test basic query
        $stmt = $conn->query("SELECT 1 as test");
        $result = $stmt->fetch();
        echo "✅ Basic query successful: " . $result['test'] . "<br>";
        
        // Test PostgreSQL version
        $stmt = $conn->query("SELECT version()");
        $version = $stmt->fetchColumn();
        echo "✅ PostgreSQL version: " . $version . "<br>";
        
        // Test database connection settings
        $stmt = $conn->query("SHOW server_version");
        $server_version = $stmt->fetchColumn();
        echo "✅ Server version: " . $server_version . "<br>";
        
    } else {
        echo "❌ Connection returned null<br>";
    }
    
} catch (PDOException $e) {
    echo "❌ PDO Exception: " . $e->getMessage() . "<br>";
    echo "❌ Error Code: " . $e->getCode() . "<br>";
} catch (Exception $e) {
    echo "❌ General Exception: " . $e->getMessage() . "<br>";
}

echo "<h3>5. Manual PDO Connection Test</h3>";

try {
    $host = getenv('DB_HOST');
    $port = getenv('DB_PORT');
    $dbname = getenv('DB_NAME');
    $user = getenv('DB_USER');
    $pass = getenv('DB_PASSWORD');
    
    echo "Attempting direct PDO connection with:<br>";
    echo "Host: $host<br>";
    echo "Port: $port<br>";
    echo "Database: $dbname<br>";
    echo "User: $user<br>";
    
    // Try different connection strings
    
    echo "<h4>Option 1: Standard connection</h4>";
    try {
        $dsn1 = "pgsql:host=$host;port=$port;dbname=$dbname";
        $conn1 = new PDO($dsn1, $user, $pass);
        echo "✅ Standard connection SUCCESS<br>";
    } catch (PDOException $e) {
        echo "❌ Standard connection FAILED: " . $e->getMessage() . "<br>";
    }
    
    echo "<h4>Option 2: With SSL require</h4>";
    try {
        $dsn2 = "pgsql:host=$host;port=$port;dbname=$dbname;sslmode=require";
        $conn2 = new PDO($dsn2, $user, $pass);
        echo "✅ SSL connection SUCCESS<br>";
    } catch (PDOException $e) {
        echo "❌ SSL connection FAILED: " . $e->getMessage() . "<br>";
    }
    
    echo "<h4>Option 3: With SSL prefer</h4>";
    try {
        $dsn3 = "pgsql:host=$host;port=$port;dbname=$dbname;sslmode=prefer";
        $conn3 = new PDO($dsn3, $user, $pass);
        echo "✅ SSL prefer connection SUCCESS<br>";
    } catch (PDOException $e) {
        echo "❌ SSL prefer connection FAILED: " . $e->getMessage() . "<br>";
    }
    
} catch (Exception $e) {
    echo "❌ Manual test error: " . $e->getMessage() . "<br>";
}

echo "<h3>6. Network Connectivity Test</h3>";

$host = getenv('DB_HOST');
$port = getenv('DB_PORT');

echo "Testing connection to $host on port $port...<br>";

$connection = @fsockopen($host, $port, $errno, $errstr, 5);
if ($connection) {
    echo "✅ Successfully connected to $host on port $port<br>";
    fclose($connection);
} else {
    echo "❌ Failed to connect to $host on port $port<br>";
    echo "Error: $errstr ($errno)<br>";
}

echo "<h3>7. DNS Resolution Test</h3>";

$ip = gethostbyname($host);
if ($ip !== $host) {
    echo "✅ Host $host resolves to IP: $ip<br>";
} else {
    echo "❌ Could not resolve hostname<br>";
}

echo "<h3>8. PHP Info (selected)</h3>";
echo "Loaded PHP Extensions:<br>";
$extensions = get_loaded_extensions();
echo "<pre>" . implode(', ', array_slice($extensions, 0, 20)) . "...</pre>";

echo "<hr>";
echo "<p>Test completed at: " . date('Y-m-d H:i:s') . "</p>";
?>
<?php
class Database {
    private $host;
    private $port;
    private $dbname;
    private $user;
    private $pass;
    private $conn;

    public function __construct() {
        // Read from environment variables
        $this->host = getenv('DB_HOST') ?: 'localhost';
        $this->port = getenv('DB_PORT') ?: '5432';
        $this->dbname = getenv('DB_NAME') ?: 'ugims';
        $this->user = getenv('DB_USER') ?: 'postgres';
        $this->pass = getenv('DB_PASSWORD') ?: '';
    }

    public function getConnection() {
        $this->conn = null;
        try {
            // Build connection string
            $dsn = "pgsql:host={$this->host};port={$this->port};dbname={$this->dbname}";
            
            // Add SSL for Render
            if (getenv('RENDER')) {
                $dsn .= ";sslmode=require";
            }
            
            $this->conn = new PDO($dsn, $this->user, $this->pass);
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            
            // Enable PostGIS
            $this->conn->exec("SET postgis.backend = 'geos'");
            
        } catch (PDOException $e) {
            error_log("Connection error: " . $e->getMessage());
            if (getenv('APP_ENV') !== 'production') {
                echo "Connection error: " . $e->getMessage();
            }
        }
        return $this->conn;
    }
    
    public function getConfig() {
        return [
            'host' => $this->host,
            'port' => $this->port,
            'dbname' => $this->dbname,
            'user' => $this->user,
            'password' => $this->pass
        ];
    }
}
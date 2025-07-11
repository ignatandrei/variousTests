<?php
// Database connection test file
// Based on configuration from Step 41

// Database configuration
$dbName = "wordpress";
$dbUser = "wordpress_user";
$dbPassword = "wordpress_password";
$dbHost = "localhost";

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h2>Database Connection Test</h2>";
echo "<p><strong>Configuration:</strong></p>";
echo "<ul>";
echo "<li>Database: $dbName</li>";
echo "<li>Username: $dbUser</li>";
echo "<li>Host: $dbHost</li>";
echo "<li>Password: " . str_repeat('*', strlen($dbPassword)) . "</li>";
echo "</ul>";

echo "<hr>";

try {
    // Attempt to connect to the database
    echo "<p><strong>Attempting database connection...</strong></p>";
    
    $mysqli = new mysqli($dbHost, $dbUser, $dbPassword, $dbName);
    
    // Check connection
    if ($mysqli->connect_error) {
        throw new Exception("Connection failed: " . $mysqli->connect_error);
    }
    
    echo "<p style='color: green;'><strong>✅ SUCCESS: Successfully connected to database!</strong></p>";
    
    // Test a simple query
    echo "<p><strong>Testing database query...</strong></p>";
    $result = $mysqli->query("SELECT VERSION() as version");
    
    if ($result) {
        $row = $result->fetch_assoc();
        echo "<p style='color: green;'><strong>✅ Query successful!</strong></p>";
        echo "<p><strong>Database Version:</strong> " . htmlspecialchars($row['version']) . "</p>";
        $result->free();
    } else {
        echo "<p style='color: orange;'><strong>⚠️ Query failed:</strong> " . $mysqli->error . "</p>";
    }
    
    // Get database information
    echo "<p><strong>Database Information:</strong></p>";
    echo "<ul>";
    echo "<li>Server Info: " . htmlspecialchars($mysqli->server_info) . "</li>";
    echo "<li>Host Info: " . htmlspecialchars($mysqli->host_info) . "</li>";
    echo "<li>Protocol Version: " . $mysqli->protocol_version . "</li>";
    echo "</ul>";
    
    // Close connection
    $mysqli->close();
    echo "<p style='color: green;'><strong>✅ Connection closed successfully</strong></p>";
    
} catch (Exception $e) {
    echo "<p style='color: red;'><strong>❌ ERROR: " . htmlspecialchars($e->getMessage()) . "</strong></p>";
    
    // Additional debugging information
    echo "<h3>Debugging Information:</h3>";
    echo "<ul>";
    echo "<li>PHP Version: " . phpversion() . "</li>";
    echo "<li>MySQL Extension: " . (extension_loaded('mysqli') ? 'Loaded' : 'Not Loaded') . "</li>";
    echo "<li>Error Code: " . (isset($mysqli) ? $mysqli->connect_errno : 'N/A') . "</li>";
    echo "<li>Error Message: " . (isset($mysqli) ? htmlspecialchars($mysqli->connect_error) : 'N/A') . "</li>";
    echo "</ul>";
    
    // Check if we can connect without specifying database
    echo "<p><strong>Trying connection without database...</strong></p>";
    try {
        $mysqli_test = new mysqli($dbHost, $dbUser, $dbPassword);
        if ($mysqli_test->connect_error) {
            echo "<p style='color: red;'>❌ Cannot connect even without database: " . htmlspecialchars($mysqli_test->connect_error) . "</p>";
        } else {
            echo "<p style='color: green;'>✅ Can connect without database - database '$dbName' might not exist</p>";
            $mysqli_test->close();
        }
    } catch (Exception $e2) {
        echo "<p style='color: red;'>❌ Connection test failed: " . htmlspecialchars($e2->getMessage()) . "</p>";
    }
}

echo "<hr>";
echo "<p><em>Test completed at: " . date('Y-m-d H:i:s') . "</em></p>";
?> 
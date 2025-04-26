<?php
// Set error reporting based on environment
$environment = 'development'; // Change to 'production' in production
if ($environment === 'development') {
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
} else {
    ini_set('display_errors', 0);
    ini_set('display_startup_errors', 0);
    error_reporting(E_ALL);
}

// Toggle debug output (set to false for production)
$debugEnabled = false;

// Set the content type to JSON
header('Content-Type: application/json');

// Start output buffering to catch any output before JSON
ob_start();

try {
    // Define the base JSON structure
    $data = [
        "description" => "BackupHub Template Repository",
        "baseurl" => "https://pembo.co.uk/BackupHub/template-repository/templates",
        "version" => "1.0",
        "templates" => []
    ];

    // Only add debug section if debug is enabled
    if ($debugEnabled) {
        $data['debug'] = [
            "timestamp" => date('c'),
            "script" => basename(__FILE__)
        ];
    }

    // Directory containing the template files
    $dir = __DIR__ . '/templates';

    // Debug: Check if directory is working (only if debug is enabled)
    if ($debugEnabled) {
        $debugDir = realpath($dir);
        $data['debug']['directory'] = [
            'path' => $dir,
            'exists' => is_dir($dir),
            'realpath' => $debugDir ? $debugDir : 'Not found',
            'writable' => is_writable($dir)
        ];
    }

    // Check if the directory exists
    if (!is_dir($dir)) {
        throw new Exception("Template directory not found: " . $dir);
    }

    // Open the directory
    if ($dh = opendir($dir)) {
        if ($debugEnabled) {
            $data['debug']['directory_opened'] = true;
        }
        $fileCount = 0;

        // Loop through all the files in the directory
        while (($file = readdir($dh)) !== false) {
            if ($debugEnabled) {
                $data['debug']['files_processed'][] = $file;
            }

            // Only process .sh files
            if (pathinfo($file, PATHINFO_EXTENSION) === 'sh') {
                $fileCount++;
                $filePath = realpath($dir . '/' . $file);

                // Validate file path to prevent directory traversal
                if ($filePath === false || strpos($filePath, realpath($dir)) !== 0) {
                    if ($debugEnabled) {
                        $data['debug']['errors'][] = "Invalid file path: " . $file;
                    }
                    continue;
                }

                // Debug: Check file status (only if debug is enabled)
                if ($debugEnabled) {
                    $data['debug']['file_details'][$file] = [
                        'path' => $filePath,
                        'exists' => file_exists($filePath),
                        'readable' => is_readable($filePath),
                        'size' => filesize($filePath)
                    ];
                }

                // Read the file contents
                $content = @file_get_contents($filePath);
                
                if ($content === false) {
                    if ($debugEnabled) {
                        $data['debug']['errors'][] = "Failed to read file: " . $file;
                    }
                    continue;
                }

                // Extract the header between #start-params and #end-params
                if (preg_match('/#start-params\n(.*?)\n#end-params/s', $content, $matches)) {
                    // Clean up the extracted header
                    $header = trim($matches[1]);
                    
                    // Create the template object
                    $template = [
                        "filename" => $file,
                        "header" => $header
                    ];
                    
                    // Append to the templates array
                    $data['templates'][] = $template;
                } else {
                    if ($debugEnabled) {
                        $data['debug']['warnings'][] = "No params header found in: " . $file;
                    }
                }
            }
        }

        // Close the directory
        closedir($dh);
        if ($debugEnabled) {
            $data['debug']['total_files'] = $fileCount;
            $data['debug']['successful'] = true;
            $data['debug']['memory_usage'] = memory_get_peak_usage(true);
            $data['debug']['execution_time'] = microtime(true) - $_SERVER['REQUEST_TIME_FLOAT'];
        }

    } else {
        throw new Exception("Could not open directory: " . $dir);
    }

} catch (Exception $e) {
    // Log error to file
    $logMessage = sprintf(
        "[%s] %s | Code: %s | File: %s | Line: %s",
        date('c'),
        $e->getMessage(),
        $e->getCode(),
        $e->getFile(),
        $e->getLine()
    );
    error_log($logMessage . PHP_EOL, 3, __DIR__ . '/logs/error.log');

    if ($debugEnabled) {
        $data['error'] = [
            'message' => $e->getMessage(),
            'code' => $e->getCode(),
            'file' => $e->getFile(),
            'line' => $e->getLine()
        ];
        $data['debug']['successful'] = false;
    } else {
        // Minimal error response when debug is off
        $data['error'] = ['message' => 'An error occurred. Enable debug for details.'];
    }
}

// Clean output buffer and output JSON
if (ob_get_level() > 0) {
    ob_end_clean();
}
try {
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_THROW_ON_ERROR);
} catch (Exception $e) {
    error_log("JSON encoding failed: " . $e->getMessage() . PHP_EOL, 3, __DIR__ . '/logs/error.log');
    http_response_code(500);
    echo json_encode(['error' => 'Failed to encode JSON response']);
}

?>

<?php namespace WebServerStatus\Library;
class Machine
{
    public function validateDomains() {
        // Directory to scan 
        $directory = dirname(__FILE__) . '\Scripts';
        // Full path to the script
        $scriptPath = $directory.'\domains.sh';

        // Execute the script
        $output = shell_exec("bash $scriptPath");

        // Print the output
        echo $output;
    }
    public function makeExecutable() {
        // Directory to scan 
        $directory = dirname(__FILE__) . '\Scripts';
        // Check if the directory exists
        if (!is_dir(filename: $directory)) {
            var_dump($directory);
            die("The specified directory does not exist.");
        }

        // Open the directory
        $files = scandir($directory);

        // Initialize the counter for files
        $fileCount = 0;

        foreach ($files as $file) {
            // Skip current and parent directory references
            if ($file === '.' || $file === '..') {
                continue;
            }
            
            // Build the full path to the file
            $filePath = $directory . DIRECTORY_SEPARATOR . $file;
            
            // Check if it's a file (not a directory)
            if (is_file($filePath)) {
                // Increment file counter
                $fileCount++;
                
                // Make the file executable
                chmod($filePath, 0755);
            }
        }

        // Output the total file count
        echo "Total number of files: " . $fileCount . PHP_EOL;

    }    
}

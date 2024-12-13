<?php
include("Library/boot.php");

use \WebServerStatus\Library\Machine;

$machine = new Machine();

// Function to display the menu
function displayMenu() {
    echo "Please select an option from the menu below:\n";
    echo "1. Make Scripts Executables\n";
    echo "2. Validate Domains\n";
    echo "3. Exit\n";
    echo "Enter your choice: ";
}

// Function to handle user choice
function handleChoice($choice) {
    global $machine;
    switch ($choice) {
        case 1:
            $machine->makeExecutable();
            break;
        case 2:
            $machine->validateDomains();
            break;
        case 3:
            echo "Goodbye!\n";
            exit; // Exit the script
        default:
            echo "Invalid option. Please try again.\n";
    }
}

// Main loop
while (true) {
    displayMenu();
    $input = trim(fgets(STDIN)); // Get user input
    if (is_numeric($input)) {
        handleChoice((int)$input);
    } else {
        echo "Invalid input. Please enter a number.\n";
    }
    echo "\n"; // Add a blank line for better readability
}
?>

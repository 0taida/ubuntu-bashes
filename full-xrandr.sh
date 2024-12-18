#!/bin/bash

# Script to configure display resolution using xrandr
# Author: [Your Name]
# Last modified: [Date]

# Constants
MODENAME="1920x1080_59.00"
DISPLAY="VGA-1"
REFRESH_RATE=59.00

# Error handling
set -e
trap 'echo "Error: Command failed at line $LINENO. Exit code: $?" >&2' ERR

# Function to check if xrandr is installed
check_xrandr() {
    if ! command -v xrandr >/dev/null 2>&1; then
        echo "Error: xrandr is not installed. Please install it first." >&2
        exit 1
    fi
}

# Function to create and add new mode
setup_display_mode() {
    # Generate modeline using cvt
    MODELINE=$(cvt 1920 1080 $REFRESH_RATE | grep -oP '(?<=Modeline\s).*')
    
    # Extract mode name and parameters
    MODE_PARAMS=$(echo "$MODELINE" | cut -d' ' -f2-)
    
    # Create new mode
    xrandr --newmode $MODELINE || {
        echo "Warning: Mode might already exist, continuing..." >&2
    }
    
    # Add mode to display
    xrandr --addmode $DISPLAY $MODENAME || {
        echo "Warning: Mode might already be added, continuing..." >&2
    }
    
    # Set the display mode
    xrandr --output $DISPLAY --mode $MODENAME
}

# Main execution
main() {
    echo "Configuring display resolution..."
    
    # Check prerequisites
    check_xrandr
    
    # Setup display mode
    setup_display_mode
    
    echo "Display configuration completed successfully!"
}

# Execute main function
main "$@"
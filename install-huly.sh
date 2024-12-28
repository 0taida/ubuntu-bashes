#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print success messages
print_success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}$1${NC}"
}

# Create directories if they don't exist
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications

# Download Huly AppImage
Huly_URL="https://dist.huly.io/Huly-linux-0.6.388.AppImage"
Huly_PATH="/opt/Huly.AppImage"

echo "Downloading Huly ..."
if sudo wget -O "$Huly_PATH" "$Huly_URL"; then
    print_success "Download completed successfully!"
else
    print_error "Failed to download Huly "
    exit 1
fi

# Set executable permissions
echo "Setting permissions..."
if sudo chmod +x "$Huly_PATH"; then
    print_success "Permissions set successfully!"
else
    print_error "Failed to set permissions"
    exit 1
fi

# Create desktop entry
DESKTOP_ENTRY="/usr/share/applications/Huly.desktop"
echo "Creating desktop entry..."

cat << EOF | sudo tee "$DESKTOP_ENTRY" > /dev/null
[Desktop Entry]
Name=Huly 
Comment=AI-first code editor
Exec=$Huly_PATH --no-sandbox
Icon=Huly
Type=Application
Categories=Development;;TextEditor;
Terminal=false
StartupWMClass=Huly
Keywords=Huly;programming;editor;
EOF

# Set desktop entry permissions
sudo chmod +x "$DESKTOP_ENTRY"

# Create symbolic link with --no-sandbox
echo "Creating symbolic link..."
SCRIPT_PATH="/usr/local/bin/Huly"

# Remove existing symlink or script if it exists
sudo rm -f "$SCRIPT_PATH"

# Create new script
cat << EOF | sudo tee "$SCRIPT_PATH" > /dev/null
#!/bin/bash
$Huly_PATH --no-sandbox "\$@"
EOF

# Make script executable
sudo chmod +x "$SCRIPT_PATH"

# Update desktop database
update-desktop-database ~/.local/share/applications

print_success "Installation completed successfully!"
print_success "You can now launch Huly  by typing 'Huly' in the terminal"
print_success "or by searching for it in your application launcher."

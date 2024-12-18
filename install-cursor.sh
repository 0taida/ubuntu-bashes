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

# Download Cursor AppImage
CURSOR_URL="https://download.cursor.sh/linux/appImage/x64"
CURSOR_PATH="/opt/cursor.AppImage"

echo "Downloading Cursor IDE..."
if sudo wget -O "$CURSOR_PATH" "$CURSOR_URL"; then
    print_success "Download completed successfully!"
else
    print_error "Failed to download Cursor IDE"
    exit 1
fi

# Set executable permissions
echo "Setting permissions..."
if sudo chmod +x "$CURSOR_PATH"; then
    print_success "Permissions set successfully!"
else
    print_error "Failed to set permissions"
    exit 1
fi

# Create desktop entry
DESKTOP_ENTRY="/usr/share/applications/cursor.desktop"
echo "Creating desktop entry..."

cat << EOF | sudo tee "$DESKTOP_ENTRY" > /dev/null
[Desktop Entry]
Name=Cursor IDE
Comment=AI-first code editor
Exec=$CURSOR_PATH --no-sandbox
Icon=cursor
Type=Application
Categories=Development;IDE;TextEditor;
Terminal=false
StartupWMClass=Cursor
Keywords=cursor;programming;editor;
EOF

# Set desktop entry permissions
sudo chmod +x "$DESKTOP_ENTRY"

# Create symbolic link with --no-sandbox
echo "Creating symbolic link..."
SCRIPT_PATH="/usr/local/bin/cursor"

# Remove existing symlink or script if it exists
sudo rm -f "$SCRIPT_PATH"

# Create new script
cat << EOF | sudo tee "$SCRIPT_PATH" > /dev/null
#!/bin/bash
$CURSOR_PATH --no-sandbox "\$@"
EOF

# Make script executable
sudo chmod +x "$SCRIPT_PATH"

# Update desktop database
update-desktop-database ~/.local/share/applications

print_success "Installation completed successfully!"
print_success "You can now launch Cursor IDE by typing 'cursor' in the terminal"
print_success "or by searching for it in your application launcher."

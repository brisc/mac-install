#!/bin/bash

# macOS Development Environment Bootstrap Script
# Simple launcher that downloads and runs the full setup
# 
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/brisc/mac-install/main/bootstrap.sh)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE} macOS Development Environment Bootstrap${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
}

# Function to check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only!"
        exit 1
    fi
    print_success "Running on macOS"
}

# Function to download the full setup
download_setup() {
    print_info "Downloading complete setup from GitHub..."
    
    SETUP_DIR="$HOME/macos-dev-setup"
    
    # Remove existing directory if it exists
    if [[ -d "$SETUP_DIR" ]]; then
        print_warning "Removing existing setup directory..."
        rm -rf "$SETUP_DIR"
    fi
    
    # Create directory
    mkdir -p "$SETUP_DIR"
    
    # Download as tar archive (no git required)
    print_info "Downloading repository archive..."
    curl -fsSL https://github.com/brisc/mac-install/archive/main.tar.gz | tar -xz -C "$SETUP_DIR" --strip-components=1
    
    if [[ ! -f "$SETUP_DIR/setup.sh" ]]; then
        print_error "Failed to download setup files"
        print_error "Expected setup.sh not found in $SETUP_DIR"
        exit 1
    fi
    
    print_success "Setup files downloaded to $SETUP_DIR"
    
    # Make scripts executable
    chmod +x "$SETUP_DIR/setup.sh"
    chmod +x "$SETUP_DIR/check.sh" 2>/dev/null || true  # check.sh might not exist yet
    
    print_success "Scripts made executable"
}

# Function to run the main setup
run_setup() {
    print_info "Starting main setup script..."
    
    SETUP_DIR="$HOME/macos-dev-setup"
    cd "$SETUP_DIR"
    
    print_info "Running setup.sh - this will handle all installations..."
    echo ""
    
    # Run the setup script
    ./setup.sh
    
    print_success "Setup script completed!"
}

# Main execution flow
main() {
    print_header
    
    print_info "This bootstrap script will:"
    print_info "1. Download the complete setup from GitHub"
    print_info "2. Run the main setup.sh script"
    print_info "3. The setup.sh will handle all installations and validations"
    echo ""
    
    # Simple flow: download and run
    check_macos
    download_setup
    run_setup
    
    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN} 🎉 Bootstrap Complete! 🎉${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""
    echo -e "${BLUE}Setup files are now available at:${NC} ~/macos-dev-setup"
    echo -e "${BLUE}Re-run setup anytime with:${NC} cd ~/macos-dev-setup && ./setup.sh"
    echo -e "${BLUE}Check installation with:${NC} cd ~/macos-dev-setup && ./check.sh"
    echo ""
}

# Run main function
main "$@"

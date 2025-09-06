#!/bin/bash

# macOS Development Environment Setup Script
# This script will install all necessary development tools automatically
# It is safe to run multiple times and will skip already installed packages

# Don't exit on errors - we want to continue and try other packages
# set -e  # Commented out to allow retrying/resuming installations

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/software.json"
UTILS_DIR="$SCRIPT_DIR/utils"

# Source progress utilities
source "$UTILS_DIR/progress.sh"

# Configuration
LOG_FILE="$HOME/macos_setup_$(date +%Y%m%d_%H%M%S).log"
SUCCESSFUL_INSTALLS=0
FAILED_INSTALLS=0

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Function to check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only!"
        exit 1
    fi
}

# Function to install Xcode Command Line Tools
install_xcode_tools() {
    print_section "Installing Xcode Command Line Tools"
    
    if xcode-select -p &>/dev/null; then
        print_success "Xcode Command Line Tools already installed"
        return 0
    fi
    
    print_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    
    print_warning "Please complete the Xcode Command Line Tools installation in the dialog box"
    wait_for_confirmation "Once installation is complete, press Enter to continue"
    
    if xcode-select -p &>/dev/null; then
        print_success "Xcode Command Line Tools installed successfully"
        log_message "Xcode Command Line Tools: SUCCESS"
        return 0
    else
        print_error "Failed to install Xcode Command Line Tools"
        log_message "Xcode Command Line Tools: FAILED"
        return 1
    fi
}

# Function to install Homebrew
install_homebrew() {
    print_section "Installing Homebrew"
    
    if command_exists brew; then
        print_success "Homebrew already installed"
        print_info "Updating Homebrew..."
        if brew update; then
            print_success "Homebrew updated successfully"
        else
            print_warning "Homebrew update failed, but continuing..."
        fi
        return 0
    fi
    
    print_info "Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        print_success "Homebrew installation completed"
    else
        print_error "Homebrew installation failed, but continuing..."
        return 1
    fi
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
        eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
    fi
    
    if command_exists brew; then
        print_success "Homebrew installed successfully"
        log_message "Homebrew: SUCCESS"
        return 0
    else
        print_error "Failed to install Homebrew"
        log_message "Homebrew: FAILED"
        return 1
    fi
}

# Function to install brew packages
install_brew_packages() {
    print_section "Installing Homebrew Packages"
    
    # Check if brew is available
    if ! command_exists brew; then
        print_error "Homebrew not available, skipping brew packages"
        return 1
    fi
    
    # Read packages from config file
    local packages=$(cat "$CONFIG_FILE" | jq -r '.brew_packages[] | @base64')
    
    for package_data in $packages; do
        local package_info=$(echo "$package_data" | base64 --decode)
        local package_name=$(echo "$package_info" | jq -r '.name')
        local package_desc=$(echo "$package_info" | jq -r '.description')
        local package_type=$(echo "$package_info" | jq -r '.type // "formula"')
        
        next_step
        show_step_progress "Installing $package_name ($package_desc)"
        
        if [[ "$package_type" == "cask" ]]; then
            if brew list --cask 2>/dev/null | grep -q "^$package_name$"; then
                print_success "$package_name already installed"
                continue
            fi
            
            # Check if the app is already installed in /Applications
            case "$package_name" in
                "google-chrome")
                    if [[ -d "/Applications/Google Chrome.app" ]]; then
                        print_success "$package_name already installed in /Applications"
                        continue
                    fi
                    ;;
                "visual-studio-code")
                    if [[ -d "/Applications/Visual Studio Code.app" ]]; then
                        print_success "$package_name already installed in /Applications"
                        continue
                    fi
                    ;;
                "firefox")
                    if [[ -d "/Applications/Firefox.app" ]]; then
                        print_success "$package_name already installed in /Applications"
                        continue
                    fi
                    ;;
            esac
            
            if brew install --cask "$package_name" 2>/dev/null; then
                print_success "Successfully installed $package_name"
                log_message "$package_name (cask): SUCCESS"
                SUCCESSFUL_INSTALLS=$((SUCCESSFUL_INSTALLS + 1))
            else
                # Check if installation failed because app already exists
                case "$package_name" in
                    "google-chrome")
                        if [[ -d "/Applications/Google Chrome.app" ]]; then
                            print_success "$package_name was already installed in /Applications"
                            log_message "$package_name (cask): SUCCESS"
                            SUCCESSFUL_INSTALLS=$((SUCCESSFUL_INSTALLS + 1))
                        else
                            print_error "Failed to install $package_name (continuing with other packages)"
                            log_message "$package_name (cask): FAILED"
                            FAILED_INSTALLS=$((FAILED_INSTALLS + 1))
                        fi
                        ;;
                    "jordanbaird-ice")
                        print_warning "$package_name might require manual installation from Mac App Store"
                        print_error "Failed to install $package_name (continuing with other packages)"
                        log_message "$package_name (cask): FAILED"
                        FAILED_INSTALLS=$((FAILED_INSTALLS + 1))
                        ;;
                    *)
                        print_error "Failed to install $package_name (continuing with other packages)"
                        log_message "$package_name (cask): FAILED"
                        FAILED_INSTALLS=$((FAILED_INSTALLS + 1))
                        ;;
                esac
            fi
        else
            if brew list 2>/dev/null | grep -q "^$package_name$"; then
                print_success "$package_name already installed"
                continue
            fi
            
            if brew install "$package_name" 2>/dev/null; then
                print_success "Successfully installed $package_name"
                log_message "$package_name (formula): SUCCESS"
                SUCCESSFUL_INSTALLS=$((SUCCESSFUL_INSTALLS + 1))
            else
                print_error "Failed to install $package_name (continuing with other packages)"
                log_message "$package_name (formula): FAILED"
                FAILED_INSTALLS=$((FAILED_INSTALLS + 1))
            fi
        fi
        
        sleep 1  # Brief pause between installations
    done
}

# Function to install npm packages
install_npm_packages() {
    print_section "Installing NPM Packages"
    
    # Check if NVM is installed first
    if [ ! -d "$HOME/.nvm" ]; then
        print_warning "NVM not installed, skipping npm packages"
        return 0
    fi
    
    # Source NVM and check if npm is available
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    if ! command -v npm >/dev/null 2>&1; then
        print_warning "NPM not available via NVM, skipping npm packages"
        return 0
    fi
    
    local packages=$(cat "$CONFIG_FILE" | jq -r '.npm_packages[] | @base64')
    
    for package_data in $packages; do
        local package_info=$(echo "$package_data" | base64 --decode)
        local package_name=$(echo "$package_info" | jq -r '.name')
        local package_desc=$(echo "$package_info" | jq -r '.description')
        local is_global=$(echo "$package_info" | jq -r '.global // false')
        
        next_step
        show_step_progress "Installing $package_name ($package_desc)"
        
        if [[ "$is_global" == "true" ]]; then
            # Source NVM and check if package is already installed
            if source ~/.nvm/nvm.sh 2>/dev/null && npm list -g "$package_name" >/dev/null 2>&1; then
                print_success "$package_name already installed globally"
                continue
            fi
            
            if source ~/.nvm/nvm.sh 2>/dev/null && npm install -g "$package_name" >/dev/null 2>&1; then
                print_success "Successfully installed $package_name globally"
                log_message "$package_name (npm global): SUCCESS"
                SUCCESSFUL_INSTALLS=$((SUCCESSFUL_INSTALLS + 1))
            else
                print_error "Failed to install $package_name globally (continuing with other packages)"
                log_message "$package_name (npm global): FAILED"
                FAILED_INSTALLS=$((FAILED_INSTALLS + 1))
            fi
        fi
        
        sleep 1
    done
}

# Function to install additional tools
install_additional_tools() {
    print_section "Installing Additional Tools"
    
    local tools=$(cat "$CONFIG_FILE" | jq -r '.additional_tools[] | @base64')
    
    for tool_data in $tools; do
        local tool_info=$(echo "$tool_data" | base64 --decode)
        local tool_name=$(echo "$tool_info" | jq -r '.name')
        local tool_desc=$(echo "$tool_info" | jq -r '.description')
        local install_cmd=$(echo "$tool_info" | jq -r '.install_command')
        
        next_step
        show_step_progress "Installing $tool_name ($tool_desc)"
        
        # Special handling for version managers
        case "$tool_name" in
            "nvm")
                if [[ -d "$HOME/.nvm" ]]; then
                    print_success "$tool_name already installed"
                    continue
                fi
                ;;
            "rvm")
                if [[ -d "$HOME/.rvm" ]]; then
                    print_success "$tool_name already installed"
                    continue
                fi
                ;;
            "ruby")
                if command -v ruby >/dev/null 2>&1 && ruby -v | grep -q "ruby [3-9]"; then
                    print_success "$tool_name already installed"
                    continue
                fi
                ;;
            "oh-my-zsh")
                if [[ -d "$HOME/.oh-my-zsh" ]]; then
                    print_success "$tool_name already installed"
                    continue
                fi
                ;;
            "powerline-fonts")
                if ls ~/Library/Fonts/*Powerline* >/dev/null 2>&1; then
                    print_success "$tool_name already installed"
                    continue
                fi
                ;;
            "nerd-fonts")
                if ls ~/Library/Fonts/*Nerd* >/dev/null 2>&1 || ls /System/Library/Fonts/*Nerd* >/dev/null 2>&1; then
                    print_success "$tool_name already installed"
                    continue
                fi
                ;;
            "powerlevel10k")
                if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
                    print_success "$tool_name already installed"
                    continue
                fi
                ;;
            "zsh-plugins")
                if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]] && [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
                    print_success "$tool_name already installed"
                    continue
                fi
                ;;
            "configure-zsh")
                if grep -q "powerlevel10k" ~/.zshrc 2>/dev/null; then
                    print_success "$tool_name already configured"
                    continue
                fi
                ;;
            "nvm")
                if [[ -d "$HOME/.nvm" ]]; then
                    print_success "$tool_name already installed"
                    continue
                fi
                ;;
            "node-20"|"node-10")
                if [[ ! -d "$HOME/.nvm" ]]; then
                    print_warning "NVM not found, skipping $tool_name"
                    continue
                fi
                # Check if this Node version is already installed
                local version=$(echo "$tool_name" | cut -d'-' -f2)
                export NVM_DIR="$HOME/.nvm"
                if [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm list 2>/dev/null | grep -q "v$version"; then
                    print_success "$tool_name already installed"
                    continue
                fi
                # Reload NVM before installing Node
                [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
                ;;
        esac
        
        if eval "$install_cmd" >/dev/null 2>&1; then
            print_success "Successfully installed $tool_name"
            log_message "$tool_name (additional): SUCCESS"
            SUCCESSFUL_INSTALLS=$((SUCCESSFUL_INSTALLS + 1))
            
            # Post-installation setup
            case "$tool_name" in
                "nvm")
                    print_info "Adding NVM to shell profile..."
                    {
                        echo 'export NVM_DIR="$HOME/.nvm"'
                        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
                        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
                    } >> ~/.zshrc 2>/dev/null || true
                    # Wait for NVM setup to complete
                    sleep 2
                    ;;
                "rvm")
                    print_info "Adding RVM to shell profile..."
                    echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> ~/.zshrc 2>/dev/null || true
                    # Wait for RVM setup to complete
                    sleep 2
                    ;;
                "powerline-fonts")
                    print_info "Powerline fonts installed to ~/Library/Fonts"
                    ;;
                "nerd-fonts")
                    print_info "Nerd fonts installed via Homebrew"
                    ;;
                "powerlevel10k")
                    print_info "Powerlevel10k theme installed"
                    print_info "Run 'p10k configure' in iTerm2 to customize"
                    ;;
                "zsh-plugins")
                    print_info "Zsh plugins installed (autosuggestions, syntax-highlighting)"
                    ;;
                "configure-zsh")
                    print_info "Zsh configuration updated with plugins and theme"
                    print_info "Restart your terminal or run 'source ~/.zshrc' to apply changes"
                    ;;
                "node-20")
                    print_info "Setting Node 20 as default..."
                    export NVM_DIR="$HOME/.nvm"
                    if [ -s "$NVM_DIR/nvm.sh" ]; then
                        \. "$NVM_DIR/nvm.sh"
                        nvm alias default 20 2>/dev/null || true
                    fi
                    ;;
            esac
        else
            print_error "Failed to install $tool_name (continuing with other tools)"
            log_message "$tool_name (additional): FAILED"
            FAILED_INSTALLS=$((FAILED_INSTALLS + 1))
        fi
        
        sleep 1
    done
}

# Function to calculate total steps
calculate_total_steps() {
    local brew_count=$(cat "$CONFIG_FILE" | jq '.brew_packages | length')
    local npm_count=$(cat "$CONFIG_FILE" | jq '.npm_packages | length')
    local additional_count=$(cat "$CONFIG_FILE" | jq '.additional_tools | length')
    
    local total=$((brew_count + npm_count + additional_count))
    set_total_steps $total
}

# Function to perform system cleanup
cleanup() {
    print_section "Cleaning Up"
    
    if command_exists brew; then
        print_info "Running brew cleanup..."
        if brew cleanup 2>/dev/null; then
            print_success "Homebrew cleanup completed"
        else
            print_warning "Homebrew cleanup had issues, but continuing..."
        fi
    fi
    
    # Check if npm is available via NVM
    if source ~/.nvm/nvm.sh 2>/dev/null && command -v npm >/dev/null 2>&1; then
        print_info "Running npm cache clean..."
        if source ~/.nvm/nvm.sh 2>/dev/null && npm cache clean --force >/dev/null 2>&1; then
            print_success "NPM cache cleanup completed"
        else
            print_warning "NPM cache cleanup had issues, but continuing..."
        fi
    fi
}

# Main installation function
main() {
    print_section "macOS Development Environment Setup"
    print_info "Starting automated installation process..."
    print_info "Log file: $LOG_FILE"
    print_success "This script is safe to run multiple times - it will skip already installed packages"
    print_info "If installation fails, you can re-run this script to resume from where it left off"
    echo
    
    # Initialize log
    log_message "Starting macOS setup process"
    
    # Check if we're on macOS
    check_macos
    
    # Check if config file exists
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    
    # Check if jq is available
    if ! command_exists jq; then
        print_warning "jq not found. Installing jq first..."
        if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            print_error "Failed to install Homebrew (required for jq)"
            exit 1
        fi
        
        # Add Homebrew to PATH
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        brew install jq
    fi
    
    # Calculate total steps for progress tracking
    calculate_total_steps
    
    # Install Xcode Command Line Tools
    if ! install_xcode_tools; then
        print_warning "Xcode Command Line Tools installation failed or needs manual completion."
        print_info "You can re-run this script after installing Xcode Command Line Tools."
    fi
    
    # Install Homebrew
    if ! install_homebrew; then
        print_warning "Homebrew installation failed, but continuing with other installations..."
        print_info "Some packages may fail without Homebrew. You can re-run this script after fixing Homebrew."
    fi
    
    # Install all packages
    install_brew_packages
    install_additional_tools  # Install NVM/RVM first
    
    # Refresh shell environment to make NVM available for NPM packages
    print_info "Refreshing shell environment for NPM installation..."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    install_npm_packages  # Install NPM packages after NVM is available
    
    # Cleanup
    cleanup
    
    # Show summary
    local total_packages=$((SUCCESSFUL_INSTALLS + FAILED_INSTALLS))
    create_summary $SUCCESSFUL_INSTALLS $FAILED_INSTALLS $total_packages
    
    print_section "Setup Complete!"
    print_success "macOS development environment setup completed!"
    print_info "Log file saved to: $LOG_FILE"
    
    if [[ $FAILED_INSTALLS -gt 0 ]]; then
        print_warning "$FAILED_INSTALLS packages failed to install out of $total_packages total packages."
        print_info "You can re-run this script to retry failed installations."
        print_info "Check the log file for specific failure details: $LOG_FILE"
        print_success "Successfully installed packages: $SUCCESSFUL_INSTALLS"
        
        # Don't exit with error code - just inform about partial success
        print_info "Setup completed with some issues. Re-run the script to retry failed packages."
    else
        print_success "All $total_packages packages installed successfully! 🎉"
    fi
}

# Run main function
main "$@"

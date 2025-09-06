#!/bin/bash

# Local macOS Development Environment Test Script
# Run this script directly on your Mac to validate the installation

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_section() {
    echo
    echo "========================================="
    echo "  $1"
    echo "========================================="
    echo
}

# Test system tools
test_system_tools() {
    print_section "Testing System Tools"
    
    local tests_passed=0
    local tests_failed=0
    
    # Test Homebrew
    if command -v brew >/dev/null 2>&1; then
        print_success "Homebrew is installed ($(brew --version | head -1))"
        tests_passed=$((tests_passed + 1))
    else
        print_error "Homebrew is not installed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test Git
    if command -v git >/dev/null 2>&1; then
        print_success "Git is installed ($(git --version))"
        tests_passed=$((tests_passed + 1))
    else
        print_error "Git is not installed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test Node.js
    if command -v node >/dev/null 2>&1; then
        print_success "Node.js is installed ($(node --version))"
        tests_passed=$((tests_passed + 1))
    else
        print_error "Node.js is not installed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test NVM
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        print_success "NVM is installed"
        source "$HOME/.nvm/nvm.sh"
        if command -v nvm >/dev/null 2>&1; then
            print_info "Available Node versions: $(nvm list --no-colors | tr '\n' ' ')"
        fi
        tests_passed=$((tests_passed + 1))
    else
        print_error "NVM is not installed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test Ruby
    if command -v ruby >/dev/null 2>&1; then
        print_success "Ruby is installed ($(ruby --version))"
        tests_passed=$((tests_passed + 1))
    else
        print_error "Ruby is not installed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test RVM
    if [ -s "$HOME/.rvm/scripts/rvm" ]; then
        print_success "RVM is installed"
        source "$HOME/.rvm/scripts/rvm"
        if command -v rvm >/dev/null 2>&1; then
            print_info "Available Ruby versions: $(rvm list strings | tr '\n' ' ')"
        fi
        tests_passed=$((tests_passed + 1))
    else
        print_error "RVM is not installed"
        tests_failed=$((tests_failed + 1))
    fi
    
    print_info "System tools: $tests_passed passed, $tests_failed failed"
    return $tests_failed
}

# Test development tools
test_development_tools() {
    print_section "Testing Development Tools"
    
    local tests_passed=0
    local tests_failed=0
    
    # Test tools from brew
    local tools=("yarn" "jq" "curl" "wget" "make" "gcc" "cmake")
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            print_success "$tool is installed"
            tests_passed=$((tests_passed + 1))
        else
            print_error "$tool is not installed"
            tests_failed=$((tests_failed + 1))
        fi
    done
    
    print_info "Development tools: $tests_passed passed, $tests_failed failed"
    return $tests_failed
}

# Test terminal configuration
test_terminal_configuration() {
    print_section "Testing Terminal Configuration"
    
    local tests_passed=0
    local tests_failed=0
    
    # Test Oh My Zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh is installed"
        tests_passed=$((tests_passed + 1))
    else
        print_error "Oh My Zsh is not installed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test Powerlevel10k theme
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        print_success "Powerlevel10k theme is installed"
        tests_passed=$((tests_passed + 1))
    else
        print_error "Powerlevel10k theme is not installed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test Zsh plugins
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    if [ -d "$plugin_dir/zsh-syntax-highlighting" ]; then
        print_success "zsh-syntax-highlighting plugin is installed"
        tests_passed=$((tests_passed + 1))
    else
        print_error "zsh-syntax-highlighting plugin is not installed"
        tests_failed=$((tests_failed + 1))
    fi
    
    if [ -d "$plugin_dir/zsh-autosuggestions" ]; then
        print_success "zsh-autosuggestions plugin is installed"
        tests_passed=$((tests_passed + 1))
    else
        print_error "zsh-autosuggestions plugin is not installed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test default shell
    if [[ "$SHELL" == *"zsh"* ]]; then
        print_success "Zsh is the default shell"
        tests_passed=$((tests_passed + 1))
    else
        print_warning "Default shell is not Zsh (current: $SHELL)"
        print_info "Run: chsh -s /bin/zsh"
    fi
    
    print_info "Terminal configuration: $tests_passed passed, $tests_failed failed"
    return $tests_failed
}

# Test GUI applications
test_gui_applications() {
    print_section "Testing GUI Applications"
    
    local tests_passed=0
    local tests_failed=0
    
    # Test if applications are installed
    local apps=(
        "/Applications/Visual Studio Code.app:Visual Studio Code"
        "/Applications/Google Chrome.app:Google Chrome"
        "/Applications/Firefox.app:Firefox"
        "/Applications/iTerm.app:iTerm2"
        "/Applications/Slack.app:Slack"
        "/Applications/Discord.app:Discord"
        "/Applications/Rectangle.app:Rectangle"
        "/Applications/Maccy.app:Maccy"
        "/Applications/Ice.app:Ice"
        "/Applications/Amphetamine.app:Amphetamine"
    )
    
    for app in "${apps[@]}"; do
        IFS=":" read -r app_path app_name <<< "$app"
        if [ -d "$app_path" ]; then
            print_success "$app_name is installed"
            tests_passed=$((tests_passed + 1))
        else
            print_error "$app_name is not installed"
            tests_failed=$((tests_failed + 1))
        fi
    done
    
    print_info "GUI applications: $tests_passed passed, $tests_failed failed"
    return $tests_failed
}

# Test Ember.js environment
test_ember_environment() {
    print_section "Testing Ember.js Environment"
    
    local tests_passed=0
    local tests_failed=0
    
    # Test Ember CLI
    if command -v ember >/dev/null 2>&1; then
        print_success "Ember CLI is installed ($(ember --version | head -1))"
        tests_passed=$((tests_passed + 1))
    else
        print_error "Ember CLI is not installed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test Bower (for legacy Ember v1)
    if command -v bower >/dev/null 2>&1; then
        print_success "Bower is installed ($(bower --version))"
        tests_passed=$((tests_passed + 1))
    else
        print_warning "Bower is not installed (needed for Ember v1 projects)"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test Watchman
    if command -v watchman >/dev/null 2>&1; then
        print_success "Watchman is installed ($(watchman --version))"
        tests_passed=$((tests_passed + 1))
    else
        print_error "Watchman is not installed"
        tests_failed=$((tests_failed + 1))
    fi
    
    # Test PhantomJS (for legacy testing)
    if command -v phantomjs >/dev/null 2>&1; then
        print_success "PhantomJS is installed ($(phantomjs --version))"
        tests_passed=$((tests_passed + 1))
    else
        print_warning "PhantomJS is not installed (may be needed for legacy Ember v1 testing)"
    fi
    
    print_info "Ember.js environment: $tests_passed passed, $tests_failed failed"
    return $tests_failed
}

# Main execution
main() {
    print_section "macOS Development Environment Local Test"
    
    print_info "Testing installation on this Mac..."
    print_info "macOS Version: $(sw_vers -productVersion)"
    print_info "Architecture: $(uname -m)"
    echo
    
    local total_failed=0
    
    # Run all tests
    test_system_tools
    total_failed=$((total_failed + $?))
    
    test_development_tools
    total_failed=$((total_failed + $?))
    
    test_terminal_configuration
    total_failed=$((total_failed + $?))
    
    test_gui_applications
    total_failed=$((total_failed + $?))
    
    test_ember_environment
    total_failed=$((total_failed + $?))
    
    # Final results
    print_section "Test Results Summary"
    
    if [ $total_failed -eq 0 ]; then
        print_success "All tests passed! Your development environment is ready."
    else
        print_warning "$total_failed test(s) failed. Some components may need attention."
        print_info "Run './setup.sh' to install missing components"
        print_info "Run './check.sh' to see detailed status"
    fi
    
    exit $total_failed
}

main "$@"

#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Progress tracking
TOTAL_STEPS=0
CURRENT_STEP=0

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print progress
print_progress() {
    local current=$1
    local total=$2
    local description=$3
    local percentage=$((current * 100 / total))
    
    print_color $CYAN "[$current/$total] ($percentage%) $description"
    
    # Create progress bar
    local bar_length=50
    local filled_length=$((percentage * bar_length / 100))
    local bar=""
    
    for ((i=1; i<=bar_length; i++)); do
        if [ $i -le $filled_length ]; then
            bar="${bar}█"
        else
            bar="${bar}░"
        fi
    done
    
    echo -e "${BLUE}${bar}${NC} ${percentage}%"
}

# Function to print section header
print_section() {
    local title=$1
    echo ""
    print_color $PURPLE "========================================="
    print_color $PURPLE "  $title"
    print_color $PURPLE "========================================="
    echo ""
}

# Function to print success message
print_success() {
    local message=$1
    print_color $GREEN "✅ $message"
}

# Function to print error message
print_error() {
    local message=$1
    print_color $RED "❌ $message"
}

# Function to print warning message
print_warning() {
    local message=$1
    print_color $YELLOW "⚠️  $message"
}

# Function to print info message
print_info() {
    local message=$1
    print_color $BLUE "ℹ️  $message"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to increment step counter
next_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
}

# Function to set total steps
set_total_steps() {
    TOTAL_STEPS=$1
}

# Function to show step progress
show_step_progress() {
    local description=$1
    print_progress $CURRENT_STEP $TOTAL_STEPS "$description"
}

# Function to wait for user confirmation (if needed)
wait_for_confirmation() {
    local message=$1
    echo ""
    print_color $YELLOW "$message"
    print_color $YELLOW "Press Enter to continue..."
    read -r
}

# Function to log installation result
log_result() {
    local package=$1
    local status=$2
    local log_file="$HOME/install_log_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "$(date): $package - $status" >> "$log_file"
}

# Function to create summary report
create_summary() {
    local successful=$1
    local failed=$2
    local total=$3
    
    echo ""
    print_section "INSTALLATION SUMMARY"
    
    print_color $GREEN "Successfully installed: $successful packages"
    print_color $RED "Failed installations: $failed packages"
    print_color $BLUE "Total packages: $total"
    
    local success_rate=$((successful * 100 / total))
    print_color $CYAN "Success rate: $success_rate%"
    
    echo ""
}

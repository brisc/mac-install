#!/bin/bash

# Setup script for Telus development environment
# This script creates a telus directory and clones required repositories

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

echo
print_status "Starting Telus development environment setup..."
echo

print_warning "IMPORTANT: You need SSH access configured for GitHub!"
print_warning "Make sure you have:"
echo "  1. Generated an SSH key: ssh-keygen -t ed25519 -C 'your_email@example.com'"
echo "  2. Added your public key to your GitHub account"
echo "  3. Test with: ssh -T git@github.com"
echo

# Create telus directory
telus_dir="$HOME/telus"
print_status "Creating telus directory at $telus_dir..."
mkdir -p "$telus_dir"
cd "$telus_dir"

# List of repositories to clone
repositories=(
    "git@github.com:telus-agcg/cosmere.git"
    "git@github.com:telus-agcg/alpaca.git"
    "git@github.com:telus-agcg/agrian-ember-core.git"
    "git@github.com:telus-agcg/wizard-lizard.git"
)

# Clone each repository
print_status "Cloning repositories..."
failed_repos=()
success_count=0

for repo in "${repositories[@]}"; do
    repo_name=$(basename "$repo" .git)
    
    if [ -d "$repo_name" ]; then
        print_status "$repo_name already exists - skipping"
        ((success_count++))
    else
        print_status "Cloning $repo_name..."
        if git clone "$repo"; then
            print_success "Successfully cloned $repo_name"
            ((success_count++))
        else
            print_error "Failed to clone $repo_name"
            failed_repos+=("$repo_name")
        fi
    fi
done

# Summary
echo
echo "========================================="
print_status "Setup Summary"
echo "========================================="
print_status "Successfully set up: $success_count/${#repositories[@]} repositories"

if [ ${#failed_repos[@]} -eq 0 ]; then
    print_success "All repositories are ready!"
else
    print_warning "Failed repositories:"
    for repo in "${failed_repos[@]}"; do
        echo "  ✗ $repo"
    done
    echo
    print_warning "Make sure your SSH key is configured for GitHub access"
fi

echo
print_status "Telus development environment location: $telus_dir"
print_status "Navigate with: cd $telus_dir"
echo

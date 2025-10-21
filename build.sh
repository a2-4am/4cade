#!/bin/bash
#
# 4cade Docker Build Helper Script
#
# Usage:
#   ./build.sh          - Build 4cade.hdv using Docker
#   ./build.sh clean    - Clean build artifacts
#   ./build.sh shell    - Open interactive shell in build environment
#   ./build.sh rebuild  - Clean and rebuild from scratch
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project name
PROJECT_NAME="4cade-builder"

# Helper functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# Check if Docker is available
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
}

# Build the Docker image
build_image() {
    print_info "Building Docker image: ${PROJECT_NAME}"
    docker build -t ${PROJECT_NAME} .
    print_success "Docker image built successfully"
}

# Run the build
run_build() {
    print_info "Starting 4cade build..."

    # Capture start time
    start_time=$(date +%s)

    # Run the build
    docker run --rm -v "$(pwd):/build" ${PROJECT_NAME} make

    # Capture end time
    end_time=$(date +%s)
    duration=$((end_time - start_time))

    # Validate output
    if [ -f "build/4cade.hdv" ]; then
        file_size=$(stat -f "%z" "build/4cade.hdv" 2>/dev/null || stat -c "%s" "build/4cade.hdv")
        file_size_mb=$((file_size / 1024 / 1024))
        print_success "Build completed in ${duration} seconds"
        print_info "Output: build/4cade.hdv (${file_size_mb}MB)"
    else
        print_error "Build failed: output file not found"
        exit 1
    fi
}

# Clean build artifacts
clean_build() {
    print_info "Cleaning build artifacts..."

    if [ -d "build" ]; then
        rm -rf build/
        print_success "Build artifacts cleaned"
    else
        print_warning "No build artifacts to clean"
    fi
}

# Open interactive shell
open_shell() {
    print_info "Opening interactive shell in build environment..."
    docker run --rm -it -v "$(pwd):/build" ${PROJECT_NAME} /bin/bash
}

# Main script logic
check_docker

case "${1:-build}" in
    build)
        # Check if image exists, build if not
        if ! docker image inspect ${PROJECT_NAME} &> /dev/null; then
            build_image
        fi
        run_build
        ;;

    clean)
        clean_build
        ;;

    shell)
        # Check if image exists, build if not
        if ! docker image inspect ${PROJECT_NAME} &> /dev/null; then
            build_image
        fi
        open_shell
        ;;

    rebuild)
        clean_build
        build_image
        run_build
        ;;

    image)
        build_image
        ;;

    *)
        echo "Usage: $0 {build|clean|shell|rebuild|image}"
        echo ""
        echo "Commands:"
        echo "  build   - Build 4cade.hdv using Docker (default)"
        echo "  clean   - Remove build artifacts"
        echo "  shell   - Open interactive shell in build environment"
        echo "  rebuild - Clean and rebuild from scratch"
        echo "  image   - Build/rebuild Docker image only"
        exit 1
        ;;
esac

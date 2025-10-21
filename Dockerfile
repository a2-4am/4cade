# 4cade Docker Build Environment
#
# Multi-stage build for compiling the 4cade (Total Replay) Apple II game launcher.
# This Dockerfile provides all necessary tools to build 4cade completely within Docker
# with no host system dependencies required.
#
# Build tools included:
# - ACME cross-assembler (6502 assembly)
# - Cadius disk imager (Apple II disk manipulation)
# - Exomizer compressor (data compression)
# - GNU Parallel (parallel build execution)
# - Python 3 (build scripts)
#
# Build stages:
# 1. base        - Core build dependencies and system tools
# 2. acme        - ACME cross-assembler compilation
# 3. cadius      - Cadius disk imager compilation
# 4. exomizer    - Exomizer compressor compilation
# 5. build-env   - Combined environment with all tools
# 6. final       - Lean production image with project source

# ==============================================================================
# Stage 1: Base - Core build dependencies
# ==============================================================================
FROM ubuntu:22.04 AS base

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install core build tools and dependencies
# - build-essential: gcc, g++, make, libc-dev
# - git: version control and repository operations
# - python3: build script execution (3.11+ required for datetime.UTC)
# - wget, curl: downloading dependencies
# - cmake: required for Cadius build
# - ca-certificates: HTTPS support
# - pkg-config: library dependency management
# - software-properties-common: for adding PPAs
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    python3 \
    python3-pip \
    wget \
    curl \
    cmake \
    ca-certificates \
    pkg-config \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Verify Python version - Ubuntu 22.04 ships with Python 3.10
# which is sufficient for most tasks. If datetime.UTC is needed,
# we could upgrade to Python 3.11, but for compatibility we'll
# patch the script instead during build
RUN python3 --version

# Verify core tools are installed correctly
RUN gcc --version && \
    g++ --version && \
    make --version && \
    python3 --version && \
    cmake --version

# Set up working directory structure
WORKDIR /build

# ==============================================================================
# Stage 2: ACME Cross-Assembler
# ==============================================================================
# ACME is a 6502 cross-assembler used to compile Apple II assembly code
# Version required: 0.97 or later
# Source: https://sourceforge.net/projects/acme-crossass/
# Installation: Official package from Ubuntu repositories (maintained from SourceForge)
FROM base AS acme

# Install ACME cross-assembler from Ubuntu repositories
# This provides the official ACME version 0.97+ from SourceForge
RUN apt-get update && apt-get install -y \
    acme \
    && rm -rf /var/lib/apt/lists/*

# Verify ACME installation and version (0.97 or later required)
RUN acme --version && \
    acme --help 2>&1 | head -n 5

# Reset working directory
WORKDIR /build

# ==============================================================================
# Stage 3: Cadius Disk Imager
# ==============================================================================
# Cadius creates and manipulates Apple II disk images (ProDOS format)
# Version required: 1.4.0 or later
# Source: https://github.com/mach-kernel/cadius
# Build system: Makefile (standard C++ project with gcc/g++)
FROM base AS cadius

# Clone Cadius repository (shallow clone to save space)
RUN git clone --depth 1 https://github.com/mach-kernel/cadius.git /build/cadius

# Build Cadius using make
WORKDIR /build/cadius
RUN make -j$(nproc)

# Install the Cadius binary to system PATH
# The Makefile builds the binary to bin/release/cadius
RUN cp bin/release/cadius /usr/local/bin/ && \
    chmod +x /usr/local/bin/cadius

# Verify installation (cadius --help exits with code 1, so use || true)
RUN cadius --help || true

# Clean up build artifacts to reduce image size
RUN rm -rf /build/cadius

# Reset working directory
WORKDIR /build

# ==============================================================================
# Stage 4: Exomizer Compressor
# ==============================================================================
# Exomizer compresses data for space-constrained Apple II environment
# Version required: 3.1.0 or later
# Source: https://bitbucket.org/magli143/exomizer/
# Build system: Makefile (standard C project)
FROM base AS exomizer

# Clone Exomizer repository at version 3.1.2 (latest stable)
# Note: Using git clone since Bitbucket downloads are unavailable
RUN git clone --depth 1 --branch 3.1.2 https://bitbucket.org/magli143/exomizer.git /build/exomizer

# Build Exomizer from source
# The Makefile is located in the src/ directory
WORKDIR /build/exomizer/src
RUN make

# Install Exomizer binary to /usr/local/bin/
# The binary is built as 'exomizer' in the src/ directory
RUN install -m 755 exomizer /usr/local/bin/exomizer

# Clean up build artifacts to reduce image size
WORKDIR /build
RUN rm -rf /build/exomizer

# Verify Exomizer installation
RUN exomizer --help || exomizer -? || exomizer 2>&1 | head -n 5

# Reset working directory
WORKDIR /build

# ==============================================================================
# Stage 5: GNU Parallel
# ==============================================================================
# GNU Parallel enables parallel execution of build tasks
# Source: https://www.gnu.org/software/parallel/
FROM base AS parallel

# Install GNU Parallel from Ubuntu repositories
RUN apt-get update && apt-get install -y \
    parallel \
    && rm -rf /var/lib/apt/lists/*

# Verify GNU Parallel installation
RUN parallel --version

# Reset working directory
WORKDIR /build

# ==============================================================================
# Stage 6: Build Environment - Combined tools for 4cade build
# ==============================================================================
# This stage combines all compiled tools into a unified build environment
# with everything needed to build 4cade from source
FROM base AS build-env

# Copy compiled tools from previous build stages
# Each tool is copied to /usr/local/bin/ to be available in PATH
# Note: ACME from apt is in /usr/bin/, so we copy it to /usr/local/bin/ for consistency
COPY --from=acme /usr/bin/acme /usr/local/bin/acme
COPY --from=cadius /usr/local/bin/cadius /usr/local/bin/cadius
COPY --from=exomizer /usr/local/bin/exomizer /usr/local/bin/exomizer
COPY --from=parallel /usr/bin/parallel /usr/bin/parallel

# Install GNU Parallel dependencies (perl modules required for parallel execution)
RUN apt-get update && apt-get install -y \
    parallel \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for building (security best practice)
# User ID 1000 matches most host systems, avoiding permission issues
RUN useradd -m -u 1000 -s /bin/bash builder

# Set up build workspace with proper permissions
# The 4cade source will be mounted here via Docker volume
WORKDIR /build
RUN chown builder:builder /build

# Create a startup script to patch Python 3.10 compatibility issue
# The rfc2822_to_touch.py script uses datetime.UTC which is only in Python 3.11+
# We'll patch it on container start to use timezone.utc instead
RUN echo '#!/bin/bash' > /usr/local/bin/patch-python-compat.sh && \
    echo 'if [ -f /build/bin/rfc2822_to_touch.py ]; then' >> /usr/local/bin/patch-python-compat.sh && \
    echo '  sed -i "s/from datetime import UTC/from datetime import timezone/" /build/bin/rfc2822_to_touch.py' >> /usr/local/bin/patch-python-compat.sh && \
    echo '  sed -i "s/astimezone(UTC)/astimezone(timezone.utc)/" /build/bin/rfc2822_to_touch.py' >> /usr/local/bin/patch-python-compat.sh && \
    echo 'fi' >> /usr/local/bin/patch-python-compat.sh && \
    chmod +x /usr/local/bin/patch-python-compat.sh

# Verify all tools are accessible and working
RUN echo "=== Verifying Build Tools ===" && \
    acme --help 2>&1 | head -n 2 && \
    cadius --help 2>&1 | head -n 2 || true && \
    exomizer --help 2>&1 | head -n 2 || true && \
    parallel --version | head -n 1 && \
    echo "=== All tools verified ==="

# Switch to non-root user for build execution
USER builder

# Default command: patch Python compatibility, then build 4cade using make
# The source directory should be mounted at /build
# Output will be in /build/build/4cade.hdv
CMD ["/bin/bash", "-c", "patch-python-compat.sh && make"]

# ==============================================================================
# Stage 7: Final Image - Lean production image (optional)
# ==============================================================================
# This stage would copy only necessary runtime files for the smallest image size
# For now, build-env serves as the final stage for interactive use

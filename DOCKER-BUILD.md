# 4cade Docker Build Environment

This directory contains a complete Docker-based build environment for 4cade that includes all necessary tools and dependencies.

## Overview

The Docker build environment provides:
- **ACME 0.97** - 6502 assembler
- **Cadius 1.4.6** - Apple II disk image manipulation tool
- **Exomizer 3.1.2** - Data compression utility
- **GNU Parallel** - Build acceleration for parallel compilation
- **Python 3** - Build scripts
- **Ubuntu 22.04** - Base Linux environment

All tools are pre-configured with correct versions and ready to use.

## Quick Start

### Option 1: Using the Build Script (Recommended)

The `build.sh` script provides the easiest way to build 4cade:

```bash
# Build 4cade (builds Docker image if needed)
./build.sh

# Clean build artifacts
./build.sh clean

# Rebuild from scratch
./build.sh rebuild

# Open interactive shell in build environment
./build.sh shell

# Rebuild Docker image only
./build.sh image
```

### Option 2: Using Docker Directly

```bash
# Build the Docker image
docker build -t 4cade-builder .

# Run the build
docker run --rm -v $(pwd):/build 4cade-builder make

# Clean build artifacts
rm -rf build/
```

### Option 3: Using Docker Compose

```bash
# Build 4cade
docker-compose up builder

# Clean build artifacts
docker-compose up clean

# Open interactive shell
docker-compose run shell
```

## Build Output

Successful builds produce:
- **File**: `build/4cade.hdv`
- **Size**: ~32MB (33,553,920 bytes)
- **Type**: Apple II hard disk image
- **Build Time**: ~15-20 seconds (with parallel processing)

## Verification

After building, verify the output:

```bash
# Check file exists and size
ls -lh build/4cade.hdv

# Check exact byte size (should be 33553920)
stat -f "%z" build/4cade.hdv  # macOS
stat -c "%s" build/4cade.hdv  # Linux

# Check file type
file build/4cade.hdv
```

## Troubleshooting

### Docker Build Fails

If the Docker image fails to build:

1. Ensure Docker is installed and running
2. Check you have internet connectivity (needed for apt packages and git clones)
3. Try rebuilding without cache: `docker build --no-cache -t 4cade-builder .`

### Build Fails Inside Container

If the 4cade build fails:

1. Check the build log: `cat build/log`
2. Open an interactive shell to debug: `./build.sh shell`
3. Ensure all source files are present and not corrupted

### Permission Issues

If you encounter permission issues with build artifacts:

```bash
# Clean with proper permissions
docker run --rm -v $(pwd):/build 4cade-builder rm -rf build/

# Or use the build script
./build.sh clean
```

## Architecture

The Dockerfile uses a multi-stage build:

1. **base** - Ubuntu 22.04 with core build tools
2. **acme** - ACME assembler (v0.97 from apt)
3. **cadius** - Cadius disk imager (v1.4.6 from git)
4. **exomizer** - Exomizer compressor (v3.1.2 from git)
5. **parallel** - GNU Parallel (from apt)
6. **build-env** - Final combined environment with all tools

This approach:
- Minimizes layer rebuilds (cached stages)
- Isolates tool compilation
- Verifies each tool before combining
- Provides clean final image

## Tool Versions

| Tool | Version | Source |
|------|---------|--------|
| ACME | 0.97 | Ubuntu apt package |
| Cadius | 1.4.6 | mach-kernel/cadius (git) |
| Exomizer | 3.1.2 | magli143/exomizer (git) |
| GNU Parallel | Latest | Ubuntu apt package |
| Python | 3.10+ | Ubuntu 22.04 default |

## Performance

Build times on typical hardware:

- **Initial Docker build**: 2-5 minutes (downloads and compiles tools)
- **Subsequent Docker builds**: <1 second (cached layers)
- **4cade build**: 15-20 seconds (with parallel processing)
- **Total first-time build**: ~5-7 minutes
- **Total subsequent builds**: ~15-20 seconds

## Development Workflow

Typical development workflow:

```bash
# One-time setup: build Docker image
docker build -t 4cade-builder .

# Make changes to source code...

# Build and test
./build.sh

# If build succeeds, test the .hdv file in an emulator

# Iterate...
```

## Advanced Usage

### Custom Build Commands

Run arbitrary commands in the build environment:

```bash
# Run a single command
docker run --rm -v $(pwd):/build 4cade-builder <command>

# Examples:
docker run --rm -v $(pwd):/build 4cade-builder acme --help
docker run --rm -v $(pwd):/build 4cade-builder cadius --help
docker run --rm -v $(pwd):/build 4cade-builder make clean
```

### Debugging Builds

Open an interactive shell to debug:

```bash
./build.sh shell

# Inside the container:
make clean
make VERBOSE=1
cat build/log
```

### CI/CD Integration

For automated builds in CI/CD:

```bash
# Build Docker image
docker build -t 4cade-builder .

# Run build (fails on error)
docker run --rm -v $(pwd):/build 4cade-builder make

# Validate output
test -f build/4cade.hdv
test $(stat -f "%z" build/4cade.hdv) -eq 33553920
```

## Files

- **Dockerfile** - Multi-stage Docker build definition
- **build.sh** - Helper script for common operations
- **docker-compose.yml** - Docker Compose configuration
- **.dockerignore** - Excludes unnecessary files from Docker context
- **DOCKER-BUILD.md** - This documentation

## Requirements

- Docker Desktop or Docker Engine
- 1GB free disk space for Docker image
- Internet connection (for initial build)

## License

Same license as 4cade project.

## Support

For issues with:
- **4cade source code**: See main project documentation
- **Docker build environment**: Check this documentation and Dockerfile comments
- **Tool issues**: See individual tool documentation (ACME, Cadius, Exomizer)

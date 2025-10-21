# Building 4cade with Docker - Complete Guide

**New to Docker? This guide is for you!**

This guide walks you through building 4cade (Total Replay) using Docker, even if you've never used Docker before. No need to manually install ACME, Cadius, Exomizer, or any other build tools - Docker handles everything.

## Table of Contents

- [What is Docker and Why Use It?](#what-is-docker-and-why-use-it)
- [Installing Docker](#installing-docker)
  - [Windows](#windows)
  - [macOS](#macos)
  - [Linux](#linux)
- [Quick Start - Building 4cade](#quick-start---building-4cade)
- [Understanding the Output](#understanding-the-output)
- [Using the Built Disk Image](#using-the-built-disk-image)
- [Development Workflow](#development-workflow)
- [Troubleshooting](#troubleshooting)
- [What's Happening Inside?](#whats-happening-inside)
- [Advanced Usage](#advanced-usage)

---

## What is Docker and Why Use It?

**Docker** is a tool that packages software and all its dependencies into a "container" - think of it as a lightweight, portable virtual machine.

### Why use Docker for building 4cade?

**Without Docker:**
- Install ACME assembler (specific version required)
- Install Cadius disk imaging tool (compile from source)
- Install Exomizer compression tool (compile from source)
- Install GNU Parallel
- Ensure all tools are in your PATH
- Deal with version compatibility issues
- Different steps for Windows/Mac/Linux

**With Docker:**
- Install Docker once (one-time setup)
- Run one command to build
- All tools pre-installed and configured
- Works identically on Windows, Mac, and Linux
- No PATH configuration needed
- Consistent builds every time

### The Trade-off

- **One-time cost**: 5-10 minutes to install Docker and build the container
- **Ongoing benefit**: 15-second builds with zero tool management

---

## Installing Docker

Choose your platform below:

### Windows

#### Requirements
- Windows 10 64-bit: Pro, Enterprise, or Education (Build 19044 or higher)
- Windows 11 64-bit
- **Note**: Windows Home editions require enabling WSL 2 (Windows Subsystem for Linux)

#### Installation Steps

1. **Download Docker Desktop for Windows**
   - Go to: https://www.docker.com/products/docker-desktop/
   - Click "Download for Windows"
   - Save the installer (Docker Desktop Installer.exe)

2. **Run the Installer**
   - Double-click the installer
   - Follow the installation wizard
   - When prompted, ensure "Use WSL 2 instead of Hyper-V" is checked (recommended)
   - Click "Ok" to proceed with installation

3. **Restart Your Computer**
   - The installer will prompt you to restart
   - This is required for Docker to work properly

4. **Start Docker Desktop**
   - Docker Desktop should start automatically after restart
   - If not, launch it from the Start menu
   - Wait for Docker Desktop to fully start (the whale icon in system tray will stop animating)

5. **Verify Installation**
   - Open Command Prompt or PowerShell
   - Run:
     ```cmd
     docker --version
     ```
   - You should see output like: `Docker version 24.0.x, build xxxxx`

6. **Test Docker is Working**
   ```cmd
   docker run hello-world
   ```
   - This downloads a test image and runs it
   - You should see "Hello from Docker!" message

#### Windows Troubleshooting

**"WSL 2 installation is incomplete"**
- Download and install the Linux kernel update package: https://aka.ms/wsl2kernel
- Restart Docker Desktop

**Docker Desktop won't start**
- Ensure virtualization is enabled in BIOS
- Check Windows features: "Hyper-V" and "Windows Subsystem for Linux" should be enabled
- Run `wsl --set-default-version 2` in PowerShell (as Administrator)

---

### macOS

#### Requirements
- macOS 11 Big Sur or later
- Mac hardware: 2010 or newer model

#### Installation Steps

1. **Download Docker Desktop for Mac**
   - Go to: https://www.docker.com/products/docker-desktop/
   - Click "Download for Mac"
   - Choose the right version:
     - **Apple Silicon** (M1, M2, M3 chips): Download "Mac with Apple chip"
     - **Intel**: Download "Mac with Intel chip"
   - If unsure: Click Apple menu → About This Mac → Check "Chip" or "Processor"

2. **Install Docker Desktop**
   - Open the downloaded .dmg file
   - Drag Docker icon to Applications folder
   - Open Applications folder and double-click Docker
   - Click "Open" if prompted about opening downloaded application

3. **Grant Permissions**
   - Docker will ask for permission to install helper tools
   - Enter your Mac password when prompted
   - This is normal and required for Docker to function

4. **Wait for Docker to Start**
   - Docker Desktop will appear in your menu bar (whale icon)
   - Wait until the icon stops animating
   - Click the icon - if you see "Docker Desktop is running", you're ready

5. **Verify Installation**
   - Open Terminal (Applications → Utilities → Terminal)
   - Run:
     ```bash
     docker --version
     ```
   - You should see: `Docker version 24.0.x, build xxxxx`

6. **Test Docker is Working**
   ```bash
   docker run hello-world
   ```
   - You should see "Hello from Docker!" message

#### Alternative: Colima (Advanced Users)

If you prefer an open-source, lightweight alternative:

```bash
# Install using Homebrew
brew install docker colima

# Start Colima
colima start

# Verify
docker --version
```

---

### Linux

#### Option 1: Docker Engine (Recommended for Linux)

**Ubuntu/Debian:**

1. **Remove Old Versions** (if any)
   ```bash
   sudo apt-get remove docker docker-engine docker.io containerd runc
   ```

2. **Install Prerequisites**
   ```bash
   sudo apt-get update
   sudo apt-get install ca-certificates curl gnupg lsb-release
   ```

3. **Add Docker's Official GPG Key**
   ```bash
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   ```

4. **Set Up Repository**
   ```bash
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

5. **Install Docker Engine**
   ```bash
   sudo apt-get update
   sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

6. **Post-Installation: Add Your User to Docker Group**
   ```bash
   sudo usermod -aG docker $USER
   ```
   - **Important**: Log out and log back in for this to take effect
   - This allows running Docker without `sudo`

7. **Verify Installation**
   ```bash
   docker --version
   ```

8. **Test Docker** (after logging out and back in)
   ```bash
   docker run hello-world
   ```
   - You should see "Hello from Docker!" message

**Fedora:**

```bash
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

**Arch Linux:**

```bash
sudo pacman -S docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

#### Option 2: Docker Desktop for Linux

Available for Ubuntu, Debian, and Fedora:
- Download from: https://www.docker.com/products/docker-desktop/
- Provides graphical interface similar to Windows/Mac version

---

## Quick Start - Building 4cade

Once Docker is installed, building 4cade is simple:

### Step 1: Get the Source Code

```bash
# Clone the repository
git clone https://github.com/a2-4am/4cade.git
cd 4cade
```

If you don't have git installed:
- **Windows**: Download from https://git-scm.com/download/win
- **macOS**: Install Xcode Command Line Tools: `xcode-select --install`
- **Linux**: `sudo apt-get install git` (Ubuntu/Debian)

### Step 2: Build with One Command

**The easiest way** - use the build helper script:

```bash
./build.sh
```

That's it! The script will:
1. Check if Docker is installed
2. Build the Docker container (first time only - takes 2-5 minutes)
3. Build 4cade (~17 seconds)
4. Show you where the output file is

**Expected output:**
```
→ Building Docker image: 4cade-builder
[Docker build messages...]
✓ Docker image built successfully
→ Starting 4cade build...
[Build messages...]
✓ Build completed in 17 seconds
→ Output: build/4cade.hdv (32MB)
```

### Alternative Methods

If you prefer to use Docker commands directly:

**Method 1: Docker only**
```bash
# Build the container (first time only)
docker build -t 4cade-builder .

# Build 4cade
docker run --rm -v $(pwd):/build 4cade-builder make
```

**Method 2: Docker Compose**
```bash
docker-compose up builder
```

---

## Understanding the Output

After a successful build, you'll find:

**File Location:** `build/4cade.hdv`

**File Details:**
- **Size**: 32 MB (exactly 33,553,920 bytes)
- **Type**: Apple II hard disk image (ProDOS format)
- **Contents**: Complete Total Replay game collection

**Verify your build:**

```bash
# Check the file exists and see its size
ls -lh build/4cade.hdv

# Expected output (macOS/Linux):
# -rw-r--r--  1 user  staff   32M Nov 21 10:30 build/4cade.hdv

# Windows (PowerShell):
dir build\4cade.hdv
```

---

## Using the Built Disk Image

Now that you have `4cade.hdv`, you can use it with Apple II emulators:

### Recommended Emulators

**Windows:**
- **AppleWin** (recommended): https://github.com/AppleWin/AppleWin/releases
  - Download latest release
  - Run AppleWin.exe
  - Go to Disk → Hard Disk → Select `4cade.hdv`
  - Reboot the emulated Apple II

**macOS:**
- **OpenEmulator**: https://archive.org/details/OpenEmulatorSnapshots
- **Ample**: https://github.com/ksherlock/ample
- **Virtual II**: http://virtualii.com/

**Linux:**
- **MAME**: `sudo apt-get install mame`
- **LinApple**: https://github.com/linappleii/linapple

**Cross-platform:**
- **MAME**: http://www.mamedev.org (Windows/Mac/Linux)

### Loading the Disk Image

1. Open your emulator
2. Mount the hard disk image (usually in Disk or Drive menu)
3. Select `build/4cade.hdv`
4. Reboot the emulated Apple II (Ctrl+Reset or similar)
5. Total Replay should boot automatically

---

## Development Workflow

### Making Changes and Rebuilding

```bash
# 1. Edit source files in src/ directory
vim src/4cade.a  # or use your preferred editor

# 2. Rebuild
./build.sh

# 3. Test the new build in your emulator
# (mount the updated build/4cade.hdv)

# 4. Repeat as needed
```

### Clean Builds

If you want to rebuild everything from scratch:

```bash
# Clean build artifacts
./build.sh clean

# Rebuild everything
./build.sh rebuild
```

### Debugging

Open an interactive shell inside the build container:

```bash
./build.sh shell
```

Inside the shell, you can:
```bash
# Run build with verbose output
make VERBOSE=1

# Check build log
cat build/log

# Test individual tools
acme --help
cadius --help

# Exit when done
exit
```

---

## Troubleshooting

### Docker Not Found

**Error:** `docker: command not found` or `'docker' is not recognized`

**Solution:**
- Ensure Docker Desktop is installed and running
- On Windows: Restart Command Prompt/PowerShell after installing Docker
- On Linux: Ensure you've logged out and back in after adding user to docker group

### Permission Denied (Linux)

**Error:** `permission denied while trying to connect to the Docker daemon`

**Solution:**
```bash
# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and log back in (or restart)
# Then verify:
docker run hello-world
```

### Build Takes Too Long

**Normal build times:**
- First time: 2-5 minutes (downloading and compiling tools)
- Subsequent builds: 15-20 seconds

**If it takes longer:**
- Check internet connection (first build downloads packages)
- Check disk space: `df -h` (need ~2GB free)
- Try building with cache cleared: `docker build --no-cache -t 4cade-builder .`

### Build Fails Inside Container

**Error:** Build completes but no `4cade.hdv` file created

**Debug steps:**
```bash
# Open shell in container
./build.sh shell

# Check what's in build directory
ls -la build/

# Try clean build manually
make clean
make

# Check for errors
cat build/log
```

### Docker Desktop Won't Start (Windows)

**Solutions:**
1. **Enable WSL 2:**
   - Open PowerShell as Administrator
   - Run: `wsl --set-default-version 2`
   - Restart Docker Desktop

2. **Enable Virtualization:**
   - Restart computer and enter BIOS
   - Find "Virtualization Technology" or "Intel VT-x" or "AMD-V"
   - Enable it
   - Save and restart

3. **Update WSL:**
   - PowerShell as Administrator:
   ```powershell
   wsl --update
   ```

### Port Already in Use

**Error:** `port is already allocated`

**Solution:**
- This shouldn't happen with 4cade builds (we don't expose ports)
- If you see this: `docker ps` and `docker stop <container-id>` for conflicting containers

### Disk Space Issues

**Error:** `no space left on device`

**Check disk space:**
```bash
# Linux/macOS
df -h

# Windows (PowerShell)
Get-PSDrive
```

**Free up Docker space:**
```bash
# Remove unused containers/images
docker system prune -a

# This can free several GB
```

### Build Works But File is Wrong Size

**Expected size:** 33,553,920 bytes (exactly)

**Check size:**
```bash
# Linux/macOS
stat -c "%s" build/4cade.hdv  # Linux
stat -f "%z" build/4cade.hdv  # macOS

# Windows (PowerShell)
(Get-Item build\4cade.hdv).length
```

**If size is wrong:**
- Try clean build: `./build.sh rebuild`
- Check build log for errors: `cat build/log`

---

## What's Happening Inside?

You don't need to understand this to use Docker, but if you're curious:

### The Dockerfile

The `Dockerfile` describes how to build the container:

1. **Base System** - Starts with Ubuntu 22.04 Linux
2. **ACME Assembler** - Installs 6502 assembler (v0.97)
3. **Cadius** - Compiles Apple II disk image tool from source
4. **Exomizer** - Compiles data compression tool from source
5. **GNU Parallel** - Installs for faster builds
6. **Final Image** - Combines all tools into one container

### What Happens When You Run `./build.sh`

1. Script checks Docker is installed
2. If needed, builds the Docker container (downloads Ubuntu, installs tools)
3. Runs the container with your source code mounted inside
4. Inside container: runs `make` to build 4cade
5. Build output written to your `build/` directory
6. Container shuts down automatically

### Why This Works

**Container isolation:** The container is isolated from your system but shares the source code directory. Changes you make on your computer are visible inside the container, and build outputs are written back to your computer.

**No PATH issues:** All tools are pre-configured inside the container.

**Reproducible:** Everyone gets the exact same build environment.

---

## Advanced Usage

### Custom Build Commands

Run arbitrary commands in the build environment:

```bash
# Run a single command
docker run --rm -v $(pwd):/build 4cade-builder <command>

# Examples:
docker run --rm -v $(pwd):/build 4cade-builder acme --version
docker run --rm -v $(pwd):/build 4cade-builder ls -la build/
```

### Building Without Helper Script

```bash
# Build Docker image
docker build -t 4cade-builder .

# Run build
docker run --rm -v $(pwd):/build 4cade-builder make

# Clean
docker run --rm -v $(pwd):/build 4cade-builder make clean
```

### Docker Compose (Alternative Workflow)

```bash
# Build
docker-compose up builder

# Clean
docker-compose up clean

# Interactive shell
docker-compose run shell
```

### Rebuilding Just the Docker Image

If tools are updated or Dockerfile changes:

```bash
# Rebuild Docker image only (doesn't build 4cade)
./build.sh image

# Or with Docker directly:
docker build -t 4cade-builder .
```

### CI/CD Integration

For automated builds (GitHub Actions, GitLab CI, etc.):

```yaml
# Example GitHub Actions snippet
- name: Build 4cade
  run: |
    docker build -t 4cade-builder .
    docker run --rm -v $(pwd):/build 4cade-builder make
    test -f build/4cade.hdv
```

---

## Getting Help

**Docker-related issues:**
- Docker documentation: https://docs.docker.com/
- Docker Desktop support: https://docs.docker.com/desktop/

**4cade build issues:**
- Check existing issues: https://github.com/a2-4am/4cade/issues
- File a new issue: https://github.com/a2-4am/4cade/issues/new
- See technical documentation: `DOCKER-BUILD.md`

**Additional Documentation:**
- `README.md` - Main project documentation
- `DOCKER-BUILD.md` - Technical Docker reference
- `Makefile` - Build system details

---

## What's Next?

**You now have:**
- Docker installed and working
- A working build environment
- A freshly built `4cade.hdv` disk image

**Next steps:**
1. Try mounting the disk image in an emulator
2. Explore the source code in `src/`
3. Make a small change and rebuild
4. Read the main `README.md` for code structure details

**Happy hacking!**

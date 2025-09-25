#!/bin/bash

# Exit on any error
set -e

echo "Installing Flutter..."

# Check if Flutter is already installed
if command -v flutter &> /dev/null; then
    echo "Flutter is already installed"
    flutter --version
    exit 0
fi

# Download and install Flutter
cd /tmp
wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
tar xf flutter_linux_3.24.0-stable.tar.xz

# Add Flutter to PATH
export PATH="$PATH:/tmp/flutter/bin"

# Pre-download dependencies
flutter config --no-analytics
flutter precache --web

echo "Flutter installation completed"
flutter --version
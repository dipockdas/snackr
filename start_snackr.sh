#!/bin/bash

echo "Starting Snackr Flutter App..."
echo "=============================="

cd "$(dirname "$0")"

# Check if in development mode
if [ -d ".dart_tool" ]; then
    echo "Development mode detected, using 'flutter run'"
    flutter run -d macos --verbose
else
    echo "Running built application"
    open build/macos/Build/Products/Debug/snackr_flutter.app
fi

echo "Done"
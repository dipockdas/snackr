#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Run the reset script using Flutter
echo "Resetting Snackr settings to use slower scroll speed..."
flutter run reset_settings.dart

# Start the app
echo "Starting Snackr..."
./start_snackr.sh
#!/bin/bash

# Default panel directory
PANEL_DIR="/var/www/pterodactyl"

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --paneldirectory=*)
      PANEL_DIR="${1#*=}"
      ;;
    *)
      echo "Invalid argument: $1"
      exit 1
  esac
  shift
done

# Check if the panel directory exists
if [ ! -d "$PANEL_DIR" ]; then
    echo "The directory $PANEL_DIR does not exist."
    echo "You can use --paneldirectory=(url) to use change pterodactyl directory."
    exit 1
fi

# Change directory to the panel directory
cd "$PANEL_DIR"

# Put Pterodactyl panel into maintenance mode
php artisan down

# Download and extract the latest theme release
curl -L https://github.com/KoshiTheme/panel/releases/latest/download/panel.tar.gz | tar -xzv

# Set proper permissions
chmod -R 755 storage/* bootstrap/cache

# Install Composer dependencies
composer install --no-dev --optimize-autoloader

# Build assets
yarn build:production --progress

# Bring Pterodactyl panel back online
php artisan up

# Completion message
echo "KoshiTheme has finished installation successfully"

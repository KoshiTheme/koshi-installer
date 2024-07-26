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

rm panel.tar.gz

curl -L -o panel.tar.gz https://github.com/KoshiTheme/panel/releases/latest/download/panel.tar.gz

# Verify the file is a gzip archive
if ! file panel.tar.gz | grep -q gzip; then
    echo "Downloaded file is not a valid gzip archive. Exiting installation."
    exit 1
fi

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

#!/bin/bash
set -e

# Copy .env file
if [ ! -f /var/www/.env ]; then
    echo "Creating .env file from .env.docker"
    cp /var/www/.env.docker /var/www/.env
fi

# Wait for the database to be ready
echo "Waiting for database to be ready..."
ATTEMPTS=0
while ! mysql -h db -u ninja -pninja -e "SELECT 1" >/dev/null 2>&1; do
    ATTEMPTS=$((ATTEMPTS+1))
    echo "Waiting for database connection... (attempt $ATTEMPTS)"
    if [ $ATTEMPTS -gt 30 ]; then
        echo "Database connection failed after 30 attempts. Exiting."
        exit 1
    fi
    sleep 5
done
echo "Database connection established."

# Directory check
echo "Checking directory structure..."
ls -la /var/www
echo "Checking vendor directory..."
ls -la /var/www/vendor 2>/dev/null || echo "Vendor directory not found!"

# Run migrations
cd /var/www
echo "Running artisan optimize:clear..."
php artisan optimize:clear || echo "Failed to run artisan optimize:clear"
echo "Running migrations..."
php artisan migrate --force || echo "Failed to run artisan migrate"

# Set proper permissions
echo "Setting permissions..."
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Start PHP-FPM
echo "Starting PHP-FPM..."
php-fpm 
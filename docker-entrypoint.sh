#!/bin/bash
set -e

# Create or update .env file from environment variables
echo "Generating .env file from environment variables..."
cat > /var/www/.env <<EOF
APP_NAME="Invoice Ninja"
APP_ENV=production
APP_KEY=base64:RR++yx2rJ9kdxbdh3+AmbHLDQu+Q76i++co9Y8ybbno=
APP_DEBUG=false

APP_URL=${APP_URL:-http://localhost}
REACT_URL=${REACT_URL:-http://localhost:3001}

DB_CONNECTION=mysql
MULTI_DB_ENABLED=false

DB_HOST=${DB_HOST:-db}
DB_DATABASE=${DB_DATABASE:-ninja}
DB_USERNAME=${DB_USERNAME:-ninja}
DB_PASSWORD=${DB_PASSWORD:-ninja}
DB_PORT=${DB_PORT:-3306}

DEMO_MODE=false

BROADCAST_DRIVER=${BROADCAST_DRIVER:-log}
LOG_CHANNEL=${LOG_CHANNEL:-stack}
CACHE_DRIVER=${CACHE_DRIVER:-redis}
QUEUE_CONNECTION=${QUEUE_CONNECTION:-redis}
SESSION_DRIVER=${SESSION_DRIVER:-redis}
SESSION_LIFETIME=120

MAIL_MAILER=${MAIL_MAILER:-smtp}
REDIS_HOST=${REDIS_HOST:-redis}
REDIS_PASSWORD=${REDIS_PASSWORD:-null}
REDIS_PORT=${REDIS_PORT:-6379}

NINJA_ENVIRONMENT=selfhost

PDF_GENERATOR=${PDF_GENERATOR:-hosted_ninja}

DELETE_PDF_DAYS=60
DELETE_BACKUP_DAYS=60
EOF

# Wait for the database to be ready
echo "Waiting for database to be ready..."
ATTEMPTS=0
while ! mysql -h ${DB_HOST:-db} -u ${DB_USERNAME:-ninja} -p${DB_PASSWORD:-ninja} -e "SELECT 1" >/dev/null 2>&1; do
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
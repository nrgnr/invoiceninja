FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    default-mysql-client \
    nodejs \
    npm

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy existing application directory contents
COPY . /var/www

# Configuration for git safe directories
RUN git config --global --add safe.directory /var/www

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Create cache directories and set permissions
RUN mkdir -p /var/www/bootstrap/cache \
    && mkdir -p /var/www/storage/framework/cache \
    && mkdir -p /var/www/storage/framework/sessions \
    && mkdir -p /var/www/storage/framework/views \
    && mkdir -p /var/www/storage/logs \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache \
    && chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Install dependencies
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --optimize-autoloader --no-dev --no-interaction

# Install npm dependencies
RUN npm ci && npm run production

# Change ownership of our applications
RUN chown -R www-data:www-data /var/www

# Make our entrypoint script executable
RUN chmod +x /var/www/docker-entrypoint.sh

# Expose port 9000
EXPOSE 9000

# Use our entrypoint script
ENTRYPOINT ["/var/www/docker-entrypoint.sh"] 
# Use the official PHP image as a parent image
FROM php:8.2-fpm

# Set the working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    supervisor \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Install Node.js (22.x) and npm
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application code
COPY . .

# Set permissions for storage and bootstrap cache
RUN chmod -R 777 storage bootstrap/cache

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Install frontend dependencies and build assets
RUN npm install && npm run build

# Run Laravel-specific commands
RUN php artisan storage:link

# Copy Supervisor configuration files
COPY docker/supervisor /etc/supervisor/conf.d

# Expose PHP-FPM port
EXPOSE 9000

# Start Supervisor to manage processes
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

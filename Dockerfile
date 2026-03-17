# Use an official PHP 8.2 runtime with Apache
FROM php:8.2-apache

# Install system dependencies and PHP extensions needed for PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo_pgsql pgsql

# Enable Apache mod_rewrite for URL rewriting
RUN a2enmod rewrite

# Set the working directory
WORKDIR /var/www/html

# Copy all files
COPY . .

# Create database.php from template (if template exists)
RUN if [ -f api/config/database.template.php ]; then \
    cp api/config/database.template.php api/config/database.php; \
    fi

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
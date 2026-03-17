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

# Create necessary directories if they don't exist
RUN mkdir -p api/config

# Create database.php from template with debugging
RUN echo "Creating database configuration..." && \
    if [ -f api/config/database.template.php ]; then \
        cp api/config/database.template.php api/config/database.php && \
        echo "✅ database.php created from template"; \
    else \
        echo "❌ ERROR: database.template.php not found!" && \
        ls -la api/config/ && \
        exit 1; \
    fi

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Create a test file to verify
RUN echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# Create a debug file to check paths
RUN echo '<?php\
echo "<h2>UGIMS Debug Info</h2>";\
echo "<h3>Directory Listing:</h3><pre>";\
system("ls -la /var/www/html/");\
system("ls -la /var/www/html/api/");\
system("ls -la /var/www/html/api/config/");\
echo "</pre>";\
echo "<h3>Environment Variables:</h3><pre>";\
print_r($_ENV);\
echo "</pre>";\
?>' > /var/www/html/debug.php

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
# Use an official PHP 8.2 runtime with Apache
FROM php:8.2-apache

# Install system dependencies and PHP extensions needed for PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo_pgsql pgsql

# Enable Apache mod_rewrite for URL rewriting
RUN a2enmod rewrite

# Set the working directory inside the container
WORKDIR /var/www/html

# Copy all files from your current directory to the working directory
COPY . .

# Expose port 80 for the web server
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]

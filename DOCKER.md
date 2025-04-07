# Invoice Ninja Docker Setup

This directory contains Docker configuration files to easily set up and run Invoice Ninja in a containerized environment.

## Prerequisites

- Docker
- Docker Compose

## Getting Started

1. Clone the repository:
   ```
   git clone https://github.com/invoiceninja/invoiceninja.git
   cd invoiceninja
   ```

2. Build and start the containers:
   ```
   docker-compose up -d
   ```

3. Wait for the containers to start up and for the database migrations to complete.

4. Access Invoice Ninja at http://localhost

## Services

The Docker Compose setup includes the following services:

- **app**: PHP-FPM service with Invoice Ninja application code
- **webserver**: Nginx web server
- **db**: MySQL database
- **redis**: Redis for caching and queues

## Environment Variables

The Docker setup uses the `.env.docker` file for its configuration. You can modify this file to customize your installation.

## Data Persistence

- Database data is stored in a Docker volume named `invoiceninjadbdata`
- Application code is mounted from your local directory

## Production Use

Before using this setup in production, consider:

1. Modifying the `.env.docker` file with secure passwords
2. Setting up SSL certificates
3. Configuring proper backups
4. Setting APP_DEBUG=false

## Troubleshooting

If you experience any issues:

1. Check the logs:
   ```
   docker-compose logs -f
   ```

2. Access the app container:
   ```
   docker-compose exec app bash
   ```

3. Verify the database connection:
   ```
   docker-compose exec app php artisan db:monitor
   ``` 
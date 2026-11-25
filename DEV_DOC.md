# Developer Documentation

## 1. Development Environment

The infrastructure is developed and tested inside a Debian Linux virtual machine.

### Prerequisites

- A Linux virtual machine.
- Docker Engine.
- Docker Compose v2.
- GNU Make.
- Git.

Verify the installed tools:

```bash
docker --version
docker compose version
make --version
```

## 2. Project Organization

Each service has its own directory containing a Dockerfile and, when necessary, configuration files and initialization scripts.

The mandatory services are located in `srcs/requirements/`, while the bonus services are located in `srcs/requirements/bonus/`.

The `srcs/docker-compose.yaml` file manages the entire infrastructure, including service builds, dependencies, networking, volumes and secrets.

## 3. Environment Configuration

Create a `srcs/.env` file containing the following configuration variables:

```dotenv
DOMAIN_NAME=yazlaigi.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_HOST=mariadb

WP_TITLE=Inception

ADMIN_USERNAME=manager
ADMIN_EMAIL=manager@example.com

NORMAL_USER_USERNAME=visitor
NORMAL_USER_EMAIL=visitor@example.com
```

These values are examples and can be customized before the initial deployment.

The WordPress administrator username must not contain `admin` or `Admin`.

### Secrets

Create the secrets directory:

```bash
mkdir -p secrets
chmod 700 secrets
```

Create the required secret files:

```bash
touch secrets/db_password.txt
touch secrets/wp_admin_password.txt
touch secrets/wp_user_password.txt
touch secrets/redis_password.txt
touch secrets/ftp_password.txt

chmod 600 secrets/*.txt
```

Populate each file with its corresponding password before starting the infrastructure.

Docker Compose mounts these files inside the authorized containers under `/run/secrets/`.

The `.env` file and the `secrets/` directory must never be committed to the Git repository.

### Storage Directories

Create the directories required by the persistent volumes:

```bash
sudo mkdir -p /home/yazlaigi/data/mariadb
sudo mkdir -p /home/yazlaigi/data/wordpress
```

### Domain Configuration

Configure the domain `yazlaigi.42.fr` in the `/etc/hosts` file of the machine accessing the infrastructure.

The domain must resolve to the virtual machine's IP address or the appropriate port-forwarding address.

## 4. Building and Launching

From the root of the project, execute:

```bash
make
```

Alternatively, use Docker Compose directly:

```bash
sudo docker compose -f srcs/docker-compose.yaml up --build -d
```

Each service is built from its own Dockerfile.

WordPress depends on MariaDB's health check to ensure that the database is available before WordPress starts.

All services use the `unless-stopped` restart policy.

## 5. Container Management

### List Containers

```bash
sudo docker compose -f srcs/docker-compose.yaml ps
```

### Display Logs

```bash
sudo docker compose -f srcs/docker-compose.yaml logs
```

Display logs for a specific service:

```bash
sudo docker compose -f srcs/docker-compose.yaml logs wordpress
```

### Access a Container

```bash
sudo docker compose -f srcs/docker-compose.yaml exec wordpress sh
```

### Restart a Service

```bash
sudo docker compose -f srcs/docker-compose.yaml restart wordpress
```

### Rebuild a Service

```bash
sudo docker compose -f srcs/docker-compose.yaml up -d --build wordpress
```

### Stop the Infrastructure

```bash
sudo docker compose -f srcs/docker-compose.yaml down
```

### Monitor Resource Usage

```bash
sudo docker stats
```

## 6. Networking

All services communicate through a dedicated Docker bridge network.

Docker's internal DNS allows containers to communicate using their service names instead of hardcoded IP addresses.

The following ports are published on the host:

| Port | Purpose |
|---|---|
| 443 | HTTPS access through NGINX |
| 21 | FTP control connection |
| 21100–21110 | FTP passive data connections |

The remaining services communicate through the internal Docker network.

NGINX acts as the HTTPS entry point and reverse proxy for Adminer, the static website and cAdvisor. It communicates with WordPress through FastCGI.

## 7. Persistent Storage

The infrastructure uses two named Docker volumes backed by host directories.

| Volume | Host Directory | Container Directory |
|---|---|---|
| `mariadb_data` | `/home/yazlaigi/data/mariadb` | `/var/lib/mysql` |
| `wordpress_data` | `/home/yazlaigi/data/wordpress` | `/var/www/html` |

The WordPress volume is shared between WordPress, NGINX and FTP.

NGINX mounts this volume in read-only mode, while WordPress and FTP require write access.

MariaDB stores its database files in its dedicated volume.

### Inspecting Volumes

```bash
sudo docker volume ls
```

```bash
sudo docker volume inspect <volume_name>
```

### Data Persistence

Data remains on the host filesystem when containers are stopped, removed or recreated.

Removing Docker volume definitions does not automatically remove the contents of the host directories backing these volumes.

Deleting the host directories permanently removes the corresponding stored data.

Database backups should be performed using appropriate MariaDB backup tools rather than copying active database files directly.

## 8. Service Initialization

Initialization scripts automate the configuration of the services.

- NGINX generates its TLS certificate and starts the web server.
- MariaDB initializes the database and database user when required.
- WordPress configures the website and creates the required users using WP-CLI.
- Redis starts with password authentication.
- FTP configures its local user and shared directory.
- Adminer starts its PHP web server.
- The static website runs through a dedicated NGINX server.
- cAdvisor collects container resource metrics.

Long-running service processes are executed in the foreground to allow Docker to manage their lifecycle.

## 9. Troubleshooting

### A container is not running

Inspect its status and logs:

```bash
sudo docker compose -f srcs/docker-compose.yaml ps
sudo docker compose -f srcs/docker-compose.yaml logs <service>
```

### WordPress cannot connect to MariaDB

Verify that:

- MariaDB is running and healthy.
- Both containers belong to the same Docker network.
- The database hostname is `mariadb`.
- The database credentials are correct.

### The website is inaccessible

Verify that:

- NGINX is running.
- Port 443 is available.
- The domain resolves to the correct address.
- The HTTPS certificate is configured.

### Persistent data is missing

Inspect the Docker volumes and verify that the corresponding host directories exist and have the required permissions.

## 10. Security Considerations

- Sensitive credentials are provided through Docker secrets.
- HTTPS is configured using TLS 1.2 and TLS 1.3.
- Internal services do not publish unnecessary ports.
- NGINX accesses WordPress files through a read-only mount.
- Redis requires password authentication.
- FTP should only be used in trusted environments because it is unencrypted.
- Administrative and monitoring interfaces should be restricted to trusted users.

The infrastructure is designed for educational purposes and requires additional security hardening before production deployment.
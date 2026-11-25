*This project has been created as part of the 42 curriculum by yazlaigi.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum that introduces containerization and infrastructure management using Docker and Docker Compose.

The objective is to build a complete infrastructure inside a virtual machine, where each service runs in its own Docker container using a custom Dockerfile.

The infrastructure includes three mandatory services:

- NGINX with TLS encryption.
- WordPress with PHP-FPM.
- MariaDB as the database server.

Additionally, five bonus services have been implemented:

- Redis for WordPress object caching.
- FTP for remote file management.
- Adminer for database administration.
- A static personal portfolio website.
- cAdvisor for container resource monitoring.

The project focuses on container isolation, networking, persistent storage, security, service orchestration and automated deployment.

## Architecture

The infrastructure consists of eight Docker containers connected through a dedicated Docker bridge network managed by Docker Compose.

| Service | Purpose | Port |
|---------|---------|------|
| NGINX | HTTPS entry point and reverse proxy | 443 |
| WordPress | Content management with PHP-FPM | 9000 |
| MariaDB | Relational database | 3306 |
| Redis | WordPress object caching | 6379 |
| FTP | Remote WordPress file management | 21 |
| Adminer | Database administration interface | 8080 |
| Website | Static personal portfolio | 8080 |
| cAdvisor | Container resource monitoring | 8080 |

Each service is built using its own Dockerfile.

NGINX handles HTTPS connections and routes requests to the appropriate service. WordPress communicates with MariaDB and Redis through the internal Docker network.

### Available interfaces

- WordPress: https://yazlaigi.42.fr/
- Adminer: https://yazlaigi.42.fr/adminer/
- Portfolio: https://yazlaigi.42.fr/portfolio/
- cAdvisor: https://yazlaigi.42.fr/cadvisor/

### Persistent storage

Two Docker volumes backed by host directories are used to preserve data:

- `/home/yazlaigi/data/wordpress`
- `/home/yazlaigi/data/mariadb`

The FTP service shares the WordPress volume to provide remote file management.

Persistent storage allows WordPress files and database contents to survive container removal and recreation.

## Instructions

### Prerequisites

- A Linux virtual machine.
- Docker Engine.
- Docker Compose v2.
- GNU Make.
- Git.
- A web browser.

### Environment configuration

Create a `.env` file inside the `srcs/` directory with the following variables:

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

These values are examples and can be customized before the first deployment.

The WordPress administrator username must not contain `admin` or `Admin`.

### Docker secrets

Create a `secrets/` directory at the root of the repository:

```bash
mkdir -p secrets
chmod 700 secrets
```

Create the following files:

```bash
touch secrets/db_password.txt
touch secrets/wp_admin_password.txt
touch secrets/wp_user_password.txt
touch secrets/redis_password.txt
touch secrets/ftp_password.txt

chmod 600 secrets/*.txt
```

Each file must contain its corresponding password.

Docker Compose makes these secrets available inside the appropriate containers through `/run/secrets/`.

Passwords must never be hardcoded inside Dockerfiles or committed to the Git repository.

### Persistent storage

Create the directories required by the Docker volumes:

```bash
sudo mkdir -p /home/yazlaigi/data/wordpress
sudo mkdir -p /home/yazlaigi/data/mariadb
```

These directories preserve WordPress files and MariaDB data independently of the container lifecycle.

### Domain configuration

Add the following entry to the `/etc/hosts` file of the machine accessing the website:

```text
127.0.0.1 yazlaigi.42.fr
```

If accessing the website from another machine, replace `127.0.0.1` with the appropriate virtual machine IP address or port-forwarding address.

### Build and launch

From the root of the repository, run:

```bash
make
```

Verify that the services are running:

```bash
sudo docker compose -f srcs/docker-compose.yaml ps
```

Access the WordPress website:

```text
https://yazlaigi.42.fr
```

A browser security warning may appear because the infrastructure uses a self-signed TLS certificate.

### Network configuration

All eight services communicate through a dedicated Docker bridge network named `inception` in the Compose configuration.

Only the following ports are published on the Docker host:

| Port | Service |
|---|---|
| 443 | NGINX HTTPS |
| 21 | FTP control connection |
| 21100–21110 | FTP passive data connections |

MariaDB, WordPress PHP-FPM, Redis, Adminer, the static website and cAdvisor communicate through the internal Docker network without directly publishing their ports.

### Service reliability

All containers use the `unless-stopped` restart policy.

MariaDB includes a health check that verifies database connectivity by executing a SQL query. WordPress waits until MariaDB becomes healthy before starting.

## Docker Concepts and Comparisons

### Virtual Machines vs. Docker

Virtual machines virtualize hardware and run a complete operating system with their own kernel.

Docker containers provide process-level isolation while sharing the host operating system's kernel. This makes containers generally more lightweight, faster to start and less resource-intensive than virtual machines.

In this project, Docker runs inside a Linux virtual machine.

### Secrets vs. Environment Variables

Environment variables are used to configure services dynamically without modifying their source code or Dockerfiles.

Docker secrets provide sensitive information through files mounted inside containers, reducing exposure through environment variables.

In this project, environment variables store configuration values, while Docker secrets store database, WordPress, Redis and FTP passwords.

### Docker Network vs. Host Network

A Docker bridge network provides an isolated network where containers communicate using their service names.

Host networking removes network isolation between a container and the host by sharing the host's network namespace.

This project uses a dedicated bridge network named `inception` to enable internal communication between services.

### Docker Volumes vs. Bind Mounts

Docker volumes are managed by Docker and provide persistent storage independently of the container lifecycle.

Bind mounts directly map a host file or directory into a container.

This project uses named Docker volumes backed by specific host directories under `/home/yazlaigi/data/`, preserving WordPress files and MariaDB data across container recreation.

## Resources

The following resources were used as references throughout the development of this project:

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [WP-CLI Documentation](https://wp-cli.org/)
- [Redis Documentation](https://redis.io/docs/)
- [Adminer](https://www.adminer.org/)
- [cAdvisor Documentation](https://github.com/google/cadvisor)
- [Debian Documentation](https://www.debian.org/doc/)

### AI Usage

ChatGPT was used as a learning and technical assistance tool throughout the development of this project.

AI assistance was used for:

- Understanding Docker and system administration concepts.
- Reviewing Dockerfiles.
- Understanding error messages.
- Assisting with the static portfolio website.
- Preparing project documentation.

The configurations and proposed solutions were reviewed and tested in the virtual machine to ensure proper functionality and understanding.
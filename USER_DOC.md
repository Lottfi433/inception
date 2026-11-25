# User Documentation

## 1. Overview

The Inception project provides a containerized web infrastructure composed of eight services.

| Service | Description |
|---------|-------------|
| NGINX | Provides secure HTTPS access. |
| WordPress | Allows users to create and manage website content. |
| MariaDB | Stores website data. |
| Redis | Improves WordPress performance through caching. |
| FTP | Allows remote file management. |
| Adminer | Provides a web interface for database administration. |
| Website | Displays a static personal portfolio. |
| cAdvisor | Monitors container resource usage. |

## 2. Starting and Stopping the Project

From the root of the project directory, start the infrastructure:

```bash
make
```

To stop the infrastructure:

```bash
make down
```

Stopping the infrastructure does not delete persistent WordPress or MariaDB data.

## 3. Accessing the Services

The following services are accessible through a web browser:

| Service | URL |
|---|---|
| WordPress | https://yazlaigi.42.fr/ |
| WordPress administration | https://yazlaigi.42.fr/wp-admin/ |
| Adminer | https://yazlaigi.42.fr/adminer/ |
| Portfolio | https://yazlaigi.42.fr/portfolio/ |
| cAdvisor | https://yazlaigi.42.fr/cadvisor/ |

A browser security warning may appear because the project uses a self-signed TLS certificate.

The domain name must be configured to resolve to the infrastructure's address.

### WordPress Administration

To manage the website:

1. Open the WordPress administration page.
2. Log in using the administrator credentials.
3. Use the dashboard to manage posts, pages, users, themes and plugins.

Normal users can log in using their own credentials and interact with the website according to their assigned permissions.

### Database Administration

To access the database through Adminer:

1. Open the Adminer page.
2. Select MySQL as the database system.
3. Enter `mariadb` as the server name.
4. Enter the database username, password and database name.
5. Click Login.

### FTP Access

Connect to the FTP service using an FTP client such as `lftp`:

```bash
lftp -u ftpuser localhost
```

Enter the FTP password when prompted.

The FTP service provides access to the WordPress files. Replace `localhost` with the virtual machine's address when connecting remotely.

FTP is unencrypted and should only be used in a trusted environment.

### Container Monitoring

The cAdvisor dashboard provides information about container resource usage, including:

- CPU usage.
- Memory usage.
- Network activity.
- Filesystem usage.

The monitoring interface should only be accessible to trusted administrators.

## 4. Credentials Management

Configuration values and usernames are stored in:

```text
srcs/.env
```

Passwords are stored in the following secret files:

| File | Purpose |
|---|---|
| `secrets/db_password.txt` | MariaDB user password |
| `secrets/wp_admin_password.txt` | WordPress administrator password |
| `secrets/wp_user_password.txt` | WordPress normal user password |
| `secrets/redis_password.txt` | Redis authentication password |
| `secrets/ftp_password.txt` | FTP user password |

These files must remain private and must never be committed to the Git repository.

Changing a secret file after initial deployment does not necessarily update an existing account's password. Existing credentials must also be updated through the corresponding service.

## 5. Checking Service Status

To verify that the services are running:

```bash
sudo docker compose -f srcs/docker-compose.yaml ps
```

All eight containers should be running, and MariaDB should report a healthy status.

To check container logs:

```bash
sudo docker compose -f srcs/docker-compose.yaml logs
```

To monitor resource usage:

```bash
sudo docker stats
```

## 6. Data Persistence

WordPress files and MariaDB data are stored persistently on the virtual machine.

Stopping, restarting or recreating containers does not normally delete this data.

Do not manually delete the persistent storage directories unless you intend to reset the infrastructure and permanently remove its stored data.
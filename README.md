# Inception

> A small production-like web stack (**Nginx + WordPress/PHP-FPM + MariaDB**) built from scratch with **Docker** and **Docker Compose**, served over **TLS 1.2/1.3**, with credentials handled through **Docker secrets**.

![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![Docker Compose](https://img.shields.io/badge/Compose-2496ED?logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?logo=nginx&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?logo=mariadb&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-21759B?logo=wordpress&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=white)

## Architecture

```
                 HTTPS :443 (TLS 1.2 / 1.3)
  client ───────────────────────────────▶ ┌───────────┐
                                          │   nginx   │  reverse proxy, TLS termination
                                          └─────┬─────┘
                                                │ FastCGI :9000
                                          ┌─────▼─────┐
                                          │ wordpress │  PHP 8.2-FPM + WP-CLI
                                          └─────┬─────┘
                                                │ MySQL :3306
                                          ┌─────▼─────┐
                                          │  mariadb  │
                                          └───────────┘
        private bridge network "inception"   ·   only port 443 is exposed
        volumes: wordpress_data, mariadb_data (persisted on the host)
```

## What this project demonstrates

- **Hand-written Dockerfiles** on `debian:bookworm-slim` (no ready-made images), with apt cache cleanup to keep images small.
- **Service orchestration** with Docker Compose: dependencies, restart policies, an isolated bridge network, and a single exposed port.
- **TLS termination** in Nginx (self-signed certificate, TLSv1.2/1.3 only) and FastCGI proxying to PHP-FPM.
- **Secrets management**: passwords are mounted as Docker secrets in `/run/secrets/`, never baked into images or committed to git; non-sensitive config lives in `.env`.
- **Idempotent entrypoints**: MariaDB and WordPress are initialised on first start only (database, users, WP install via WP-CLI), then simply restarted.
- **Data persistence** with named volumes bound to the host, and Makefile targets to build, inspect, reset and clean the stack.

## Project structure

```
.
├── Makefile                 # build / up / down / logs / reset targets
├── secrets/                 # one password per file (git-ignored, not committed)
└── srcs/
    ├── .env                 # non-sensitive configuration (domain, DB name, users)
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/           # Dockerfile + nginx.conf
        ├── wordpress/       # Dockerfile + php-fpm pool + entrypoint (WP-CLI)
        └── mariadb/         # Dockerfile + server config + entrypoint
```

## Getting started

**Requirements:** Linux, Docker, Docker Compose, GNU Make.

1. Put one password per file (no trailing newline) in `secrets/`:
   `db_root_password.txt`, `db_password.txt`, `wp_admin_password.txt`, `wp_user_password.txt`.
2. Adjust `srcs/.env` (domain, users) and the volume paths in `srcs/docker-compose.yml` / `Makefile`.
3. Point the domain to your machine, e.g. add `127.0.0.1 <login>.42.fr` to `/etc/hosts`.
4. Run:

```bash
make            # build images and start the stack
make ps         # container status
make logs       # follow logs
make down       # stop
make reset_all  # wipe persisted data
```

Then open `https://<login>.42.fr` (admin panel at `/wp-admin`).

## Design choices

| Choice | Why |
|---|---|
| Containers vs VMs | Containers share the host kernel: faster to start, lighter, reproducible. |
| Secrets vs env vars | Env vars leak easily (`docker inspect`, logs); secrets are files readable only by the services that need them. |
| Bridge network vs host network | Services talk by DNS name on an isolated network; only Nginx is reachable from outside. |
| Volumes | Database and site files survive container rebuilds. |

More details in [DEV_DOC.md](DEV_DOC.md) and [USER_DOC.md](USER_DOC.md).

---
*Project from the [42](https://42.fr) curriculum (42 Paris) by Eddy Kirsner.*

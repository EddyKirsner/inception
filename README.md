*This project has been created as part of the 42 curriculum by ekirsner.*

# Inception

## Description

Inception is a project that consists of setting up a small web infrastructure using Docker.  
The goal is to learn how to containerize services and make them work together using Docker Compose.

The infrastructure is composed of three services:

- **Nginx**: acts as a reverse proxy and handles HTTPS connections.
- **WordPress**: the web application that serves the website.
- **MariaDB**: the database used by WordPress to store data such as users, posts, and settings.

Each service runs inside its own container, and Docker Compose orchestrates the communication between them.

The project also uses Docker volumes to persist data and Docker secrets to securely manage credentials.

---

## Instructions

### Prerequisites

The project must be run on a Linux system or a virtual machine with a Linux kernel.

You must have installed:

- Docker
- Docker Compose
- GNU Make

---

### Setup

1. Create the following directories: 

2. In `srcs/docker-compose.yml`, replace `<login>` in the volume paths with your own username.

3. Set passwords in the files located in the `secrets/` directory.  
Each file must contain only one password and no newline.

4. Configure the `.env` file with your desired values.

---

### Running the project

 home/login/data

"sudo make" 

This command builds the Docker images and starts the containers.

---

### Stopping the project

To stop the containers:

sudo make down


---

### Resetting the project

If you want to reset the database or encounter an issue, run:

sudo make reset_all


---

### Accessing the website

Once the containers are running, open your browser and go to:

https://(your WP_URL(in .env))

To access the WordPress administration panel:

https://(your WP_URL(in .env))/wp-admin

To access the WordPress as a wp user administration panel:

https://<WP_URL>/wp-login.php

---

## Technical Choices

### Virtual Machines vs Docker

Virtual machines emulate a full operating system including its own kernel.  
Docker containers share the host system kernel, making them much lighter and faster to start.  
Docker simplifies application deployment and makes environments easier to reproduce.

---

### Secrets vs Environment Variables

Environment variables store configuration values but may expose sensitive information.  
Docker secrets allow sensitive data such as passwords to be stored securely and accessed only by the required containers.

---

### Docker Network vs Host Network

Docker networks isolate containers while allowing them to communicate through internal DNS names.  
Host networking removes this isolation and exposes containers directly to the host network.  
Using Docker networks improves security and container separation.

---

### Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker and used to persist container data.  
Bind mounts directly link a directory from the host machine to the container.  
In this project, named volumes are configured with bind mounts to store persistent data inside `/home/<login>/data`.

---

## Resources

- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- Nginx documentation: https://nginx.org/en/docs/
- WordPress documentation: https://wordpress.org/support/
- MariaDB documentation: https://mariadb.org/documentation/

AI tools were used to clarify Docker concepts, improve documentation structure, and assist in writing explanations for this project.

### Inception

For this project, 3 services must be containerised using docker:

-nignx a server and reverse proxy handling https connexions
-mariadb database storing wordpress data
-wordpress php ftm application serving the website

To set up the project you have to
-create both "mariadb" and "wordpress" directory in user/home/data. these directory will be used later for bind mount volume
-install docker on your computer or vm
-create a repo to store everything your docker will need
-create a Makefile to run your docker environment.
-create a "secrets" directory at the root of your project to store your credentials (for security, make sure to not include passwords in yours secrets file).
-then you can create a directory with a docker-compose.yml, a ".env" and requirements directory to store each services.

-for each services create a repository with a dockerfile to install dependencies and some stuff.
-for mariadb you must write a entrypoint.sh because you have to run your db once time for initialising.

-once everything's done, you can write your dockercompose to create dns for each services, create a inception network and set up named mounted bind volumes.

with makefile, you can manage your containers with sudo make down, sudo make up or sudo make re.
you can to erase your volumes for debugging with sudo make reset*.

to see yours containers, use sudo docker ps or sudo docker ps -a
to see yours docker images, use sudo docker images
to see outputs of containers, use sudo docker logs --tail=(number of your choice) (services name of your choice)
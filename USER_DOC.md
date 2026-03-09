### Inception

The stack provides a WordPress website served through an Nginx reverse proxy, with a MariaDB database used to store the website data.

To run the containerised program you have to:

-Make sure to use a linux kernel in your host machine or vm
-In home/data, create 2 directory named mariadb and wordpress
-In inception/srcs/docker-compose.yml replace in volumes parts, replace data in "/home/user/data/mariadb" or "/home/user/data/mariadb" by your username
-In inception/secrets you can set a password in each file. one password by file and no return to line.
-If you want to reset database or any problem in encontred, try to write "sudo make reset_all" and "sudo make re"
--To launch the program, go to the root of the project and use "sudo make up"
-to stop the program, go to the root of the project and use "sudo make down"
-you have to set the .env replacing environment data by data of your choice (excepted MYSQL_DATABASE, MYSQL_USER, MYSQL_HOST)
-once the program is up, you can write https://(your WP_URL) in the url bar
-you can use https://(your WP_URL)/wp-admin/ to connect as an admin
-you can use https://(your WP_URL)/wp-user-php/ to connect as an user
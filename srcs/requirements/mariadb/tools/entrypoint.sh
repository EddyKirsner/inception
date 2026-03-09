#!/bin/sh
set -eu

MYSQL_ROOT_PASSWORD=$(tr -d '\r\n' < /run/secrets/db_root_password)
MYSQL_PASSWORD=$(tr -d '\r\n' < /run/secrets/db_password)

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
PIDFILE="/run/mysqld/mysqld.pid"
INIT_FLAG="$DATADIR/.db_initialized"

mkdir -p /run/mysqld "$DATADIR"
chown -R mysql:mysql /run/mysqld "$DATADIR"

unset MYSQL_HOST MYSQL_TCP_PORT MYSQL_UNIX_PORT

if [ ! -f "$INIT_FLAG" ]; then
	if [ ! -d "$DATADIR/mysql" ]; then
		mariadb-install-db --user=mysql --datadir="$DATADIR" --skip-test-db >/dev/null
	fi

	mariadbd \
		--user=mysql \
		--datadir="$DATADIR" \
		--socket="$SOCKET" \
		--pid-file="$PIDFILE" \
		--skip-networking \
		&
	pid="$!"

	i=60
	while [ "$i" -gt 0 ]; do
		if mariadb-admin --no-defaults --protocol=socket --socket="$SOCKET" ping --silent >/dev/null 2>&1; then
			break
		fi
		i=$((i - 1))
		sleep 1
	done

	if [ "$i" -eq 0 ]; then
		kill "$pid" >/dev/null 2>&1 || true
		wait "$pid" 2>/dev/null || true
		exit 1
	fi

	mariadb --no-defaults --protocol=socket --socket="$SOCKET" -uroot <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	touch "$INIT_FLAG"
	chown mysql:mysql "$INIT_FLAG"

	mariadb-admin --no-defaults --protocol=socket --socket="$SOCKET" -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown >/dev/null
	wait "$pid"
fi

exec mariadbd \
	--user=mysql \
	--datadir="$DATADIR" \
	--socket="$SOCKET" \
	--bind-address=0.0.0.0 \
	--port=3306
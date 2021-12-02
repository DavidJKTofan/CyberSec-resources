#!/bin/ash

/usr/bin/mysqld --user=root --bind-address=127.0.0.1 --port 3306 &

# wait for mysql to start
sleep 5

# Setup MySQL Database
DBPASS=$(echo $RANDOM | md5sum | head -c 15)
mysql -e "DROP DATABASE test; CREATE DATABASE toydb"
mysql -e "CREATE USER 'dbuser'@'localhost'"
mysql -e "GRANT ALL PRIVILEGES ON toydb.* To 'dbuser'@'localhost' IDENTIFIED BY '${DBPASS}';"
sed -i "s/DBPASS/${DBPASS}/g" /app/database.js
mysql toydb < /app/database.sql
rm -rf /app/database.sql

/usr/bin/supervisord -c /etc/supervisord.conf
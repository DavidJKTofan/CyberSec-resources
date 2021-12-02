FROM node:alpine

# Install packages
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.6/main' >> /etc/apk/repositories
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.6/community' >> /etc/apk/repositories
RUN apk add --update --no-cache supervisor mariadb mariadb-client

# Setup MySQL
RUN mkdir -p /var/run/mysqld && \
    chown root:mysql /var/run/mysqld && \
    chmod 774 /var/run/mysqld
RUN mysql_install_db --user=mysql --ldata=/var/lib/mysql
RUN sed -i 's/skip-networking//g' /etc/my.cnf.d/mariadb-server.cnf

# Setup app
RUN mkdir -p /app

# Add application
WORKDIR /app
COPY challenge .

# Install dependencies
RUN yarn

# Setup superivsord
COPY config/supervisord.conf /etc/supervisord.conf

# Expose the port node-js is reachable on
EXPOSE 1337

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Migrate DB and start the node-js application
ENTRYPOINT /entrypoint.sh
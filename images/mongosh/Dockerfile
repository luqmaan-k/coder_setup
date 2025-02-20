# Use Coder's enterprise base image
FROM codercom/enterprise-base:ubuntu

# Switch to root for package installation
USER root
ENV DEBIAN_FRONTEND=noninteractive

# Install wget, gnupg, and any other required packages for apt-key
RUN apt-get update && apt-get install -y --no-install-recommends wget gnupg && \
    rm -rf /var/lib/apt/lists/*

# Add MongoDB’s official GPG key and repository (using MongoDB 6.0 for Ubuntu Jammy)
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-6.0.list

# Update package lists and install MongoDB
RUN apt-get update && \
    apt-get install -y --no-install-recommends mongodb-org && \
    rm -rf /var/lib/apt/lists/*

# Create a persistent data directory in /home/coder and set proper ownership to coder
RUN mkdir -p /home/coder/mongodb-data && \
    chown -R coder:coder /home/coder/mongodb-data

# Modify the MongoDB configuration to use /home/coder/mongodb-data for both dbPath and logPath.
RUN sed -i 's|dbPath: /var/lib/mongodb|dbPath: /home/coder/mongodb-data|g' /etc/mongod.conf && \
    sed -i 's|path: /var/log/mongodb/mongod.log|path: /home/coder/mongodb-data/mongod.log|g' /etc/mongod.conf

# Copy the startup script that will launch MongoDB
COPY start-mongodb.sh /usr/local/bin/start-mongodb.sh
RUN chmod +x /usr/local/bin/start-mongodb.sh

# Switch to coder user
USER coder

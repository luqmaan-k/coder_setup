#!/bin/bash
set -e

# Define locations and variables
PERSISTENT_DIR="/home/coder/neo4j"
DATA_DIR="${PERSISTENT_DIR}/data"
NEO4J_HOME="/opt/neo4j"
CONFIG_FILE="${NEO4J_HOME}/conf/neo4j.conf"

# Optional: set ADVERTISED_ADDRESS via an environment variable, otherwise default to localhost.
# In production, set ADVERTISED_ADDRESS to your externally accessible hostname.
: ${ADVERTISED_ADDRESS:="localhost"}

# Create the persistent directory and data directory if they don't exist
if [ ! -d "$PERSISTENT_DIR" ]; then
  echo "Creating persistent directory at $PERSISTENT_DIR"
  mkdir -p "$PERSISTENT_DIR"
fi

if [ ! -d "$DATA_DIR" ]; then
  echo "Creating Neo4j data directory at $DATA_DIR"
  mkdir -p "$DATA_DIR"
fi

# Set proper ownership so that the neo4j user can write to it
echo "Setting ownership of $PERSISTENT_DIR to neo4j:adm"
sudo chown -R neo4j:adm "$PERSISTENT_DIR"

# Configure Neo4j settings in neo4j.conf
# Set persistent data directory
if ! grep -q "^server.directories.data=" "$CONFIG_FILE"; then
  echo "Configuring Neo4j to use persistent data directory at $DATA_DIR"
  echo "server.directories.data=${DATA_DIR}" | sudo tee -a "$CONFIG_FILE" > /dev/null
else
  echo "Neo4j data directory already configured in $CONFIG_FILE"
fi

# Disable authentication
if ! grep -q "^dbms.security.auth_enabled=false" "$CONFIG_FILE"; then
  echo "Disabling Neo4j authentication"
  echo "dbms.security.auth_enabled=false" | sudo tee -a "$CONFIG_FILE" > /dev/null
else
  echo "Neo4j authentication already disabled in $CONFIG_FILE"
fi

# Configure Bolt to listen on all interfaces
if ! grep -q "^server.bolt.listen_address=0.0.0.0:7687" "$CONFIG_FILE"; then
  echo "Configuring Neo4j Bolt to listen on 0.0.0.0:7687"
  echo "server.bolt.listen_address=0.0.0.0:7687" | sudo tee -a "$CONFIG_FILE" > /dev/null
else
  echo "Neo4j Bolt listen_address already configured in $CONFIG_FILE"
fi

# Set the advertised address to the externally accessible host
if ! grep -q "^server.bolt.advertised_address=" "$CONFIG_FILE"; then
  echo "Configuring Neo4j Bolt advertised address as ${ADVERTISED_ADDRESS}:7687"
  echo "server.bolt.advertised_address=${ADVERTISED_ADDRESS}:7687" | sudo tee -a "$CONFIG_FILE" > /dev/null
else
  echo "Neo4j Bolt advertised address already configured in $CONFIG_FILE"
fi

# Disable TLS for Bolt (for plain WebSocket connections)
if ! grep -q "^server.bolt.tls_level=DISABLED" "$CONFIG_FILE"; then
  echo "Disabling TLS on Bolt"
  echo "server.bolt.tls_level=DISABLED" | sudo tee -a "$CONFIG_FILE" > /dev/null
else
  echo "Neo4j Bolt TLS level already configured in $CONFIG_FILE"
fi

# Start Neo4j in background mode as the neo4j user
echo "Starting Neo4j..."
sudo -u neo4j ${NEO4J_HOME}/bin/neo4j start

# Wait a few seconds for the server to fully initialize (adjust as needed)
sleep 10

echo "Neo4j is now running. You can access the Neo4j Browser at http://${ADVERTISED_ADDRESS}:7474"

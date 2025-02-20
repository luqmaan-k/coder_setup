#!/bin/bash
# Start MongoDB in the background using the provided configuration.
mongod --config /etc/mongod.conf &

# Wait a moment to let MongoDB start up.
sleep 2

# If any arguments are provided, execute them; otherwise, keep the container alive.
if [ "$#" -gt 0 ]; then
  exec "$@"
else
  # Tailing /dev/null ensures the container remains running.
  tail -f /dev/null
fi


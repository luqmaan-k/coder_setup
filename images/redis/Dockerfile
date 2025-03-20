# Use Coder's enterprise base image
FROM codercom/enterprise-base:ubuntu

# Switch to root for package installation
USER root

# Set environment to non-interactive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install development tools, editors, and redis-server
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      nano \
      vim \
      neovim \
      redis-server \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y python3-redis

# Modify Redis configuration for development:
# - Disable protected mode (allowing connections from any IP)
# - Bind to 0.0.0.0 so that it’s accessible externally
# - Ensure no authentication is required (default is commented out)
RUN sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf && \
    sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf && \
    sed -i 's/^# requirepass .*/# requirepass disabled/' /etc/redis/redis.conf

# Ensure `python` points to python3
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Create a virtual environment in /opt/venv (outside of the home directory)
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools && \
    /opt/venv/bin/pip install \
      numpy \
      redis \
      pandas \
      matplotlib \
      jupyter \
      ipykernel && \
    chown -R coder:coder /opt/venv

# Clean up package caches
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Switch to coder user
USER coder

# Set up the Jupyter kernel from the virtual environment
RUN /opt/venv/bin/python -m ipykernel install --user --name=venv --display-name="Redis"

# Use Coder's enterprise base image
FROM codercom/enterprise-base:ubuntu

# Switch to root for package installation
USER root

# Set environment to non-interactive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install development tools, Node.js, and npm
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nano \
    vim \
    neovim \
    curl \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g npm@latest \
    && rm -rf /var/lib/apt/lists/*

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Switch back to coder user
USER coder


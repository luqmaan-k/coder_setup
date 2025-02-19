# Use Coder's enterprise base image
FROM codercom/enterprise-base:ubuntu

# Switch to root for package installation
USER root

# Set environment to non-interactive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install development tools and editors
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    vim \
    neovim \
    gcc \
    g++ \
    clang \
    cmake \
    make \
    gdb \
    libopenmpi-dev \
    libomp-dev \
    && rm -rf /var/lib/apt/lists/*

# Set Vim as the default editor for vi
RUN update-alternatives --set vi /usr/bin/vim

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Switch back to coder user
USER coder


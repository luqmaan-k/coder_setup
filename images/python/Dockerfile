# Use Coder's enterprise base image
FROM codercom/enterprise-base:ubuntu

# Switch to root for package installation
USER root

# Set environment to non-interactive to suppress prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install Python and development tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3 \
      python3-pip \
      python3-venv \
      python3-dev \
      build-essential && \
    rm -rf /var/lib/apt/lists/*

# Ensure `python` points to python3
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Create a virtual environment in /home/coder/venv and install data science packages including Jupyter and ipykernel
RUN python3 -m venv /home/coder/venv && \
    /home/coder/venv/bin/pip install --upgrade pip setuptools && \
    /home/coder/venv/bin/pip install \
      numpy \
      pandas \
      matplotlib \
      seaborn \
      scikit-learn \
      tensorflow \
      jupyter \
      torch \
      ipykernel && \
    chown -R coder:coder /home/coder/venv

# Switch to coder user
USER coder

# Set up the Jupyter kernel from the virtual environment
RUN /home/coder/venv/bin/python -m ipykernel install --user --name=venv --display-name="DataScience"

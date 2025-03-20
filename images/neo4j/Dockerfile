# Use Coder's enterprise base image
FROM codercom/enterprise-base:ubuntu

# Switch to root for package installation
USER root

# Set environment to non-interactive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages: development tools, editors, OpenJDK 21, and wget for downloading Neo4j
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      nano \
      vim \
      neovim \
      openjdk-21-jdk-headless \
      wget && \
    rm -rf /var/lib/apt/lists/*

# Define Neo4j version and tarball details
ENV NEO4J_VERSION=2025.02.0
ENV NEO4J_TARBALL=neo4j-enterprise-${NEO4J_VERSION}-unix.tar.gz
ENV NEO4J_DOWNLOAD_URL=https://dist.neo4j.org/${NEO4J_TARBALL}
ENV NEO4J_HOME=/opt/neo4j

# Accept the evaluation license agreement for Neo4j Enterprise
ENV NEO4J_ACCEPT_LICENSE_AGREEMENT=eval

# Download and extract the Neo4j tarball, move it to /opt, and create a symlink
RUN wget -q ${NEO4J_DOWNLOAD_URL} -O /tmp/${NEO4J_TARBALL} && \
    tar zxf /tmp/${NEO4J_TARBALL} -C /tmp && \
    mv /tmp/neo4j-enterprise-${NEO4J_VERSION} /opt/ && \
    ln -s /opt/neo4j-enterprise-${NEO4J_VERSION} ${NEO4J_HOME} && \
    rm /tmp/${NEO4J_TARBALL}

# Pre-accept the license using neo4j-admin to avoid interactive prompts at first run
RUN ${NEO4J_HOME}/bin/neo4j-admin server license --accept-evaluation

# Create a dedicated neo4j user and group, then set ownership for the Neo4j installation directory (Ubuntu recommendation: neo4j:adm)
RUN groupadd neo4j && \
    useradd -g neo4j neo4j -s /bin/bash && \
    chown -R neo4j:adm /opt/neo4j-enterprise-${NEO4J_VERSION}

# Copy the runtime initialization script into /opt and make it executable
COPY start-neo4j.sh /opt/start-neo4j.sh
RUN chmod +x /opt/start-neo4j.sh

# (Do NOT create any directories under /home/coder here because that volume is mounted at runtime)

# Clean up package lists and temporary files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Switch back to coder user
USER coder


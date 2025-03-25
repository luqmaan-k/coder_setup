# Use Coder's enterprise base image
FROM codercom/enterprise-base:ubuntu

# Switch to root for package installation
USER root

# Set environment to non-interactive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install development tools, editors, wget and Java (required for these apps)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      nano \
      vim \
      neovim \
      wget \
      openjdk-17-jdk && \
    rm -rf /var/lib/apt/lists/*

# Create persistent directories for data
RUN mkdir -p /home/coder/hbase_data \
             /home/coder/cassandra_data \
             /home/coder/spark_logs \
             /home/coder/kafka_data

# Copy the pre-downloaded tarballs into the image
COPY hbase-2.5.11-bin.tar.gz /tmp/
COPY apache-cassandra-5.0.3-bin.tar.gz /tmp/
COPY spark-3.5.5-bin-hadoop3.tgz /tmp/
COPY kafka_2.13-4.0.0.tgz /tmp/

### Install Apache HBase
# Extract HBase and create a minimal hbase-site.xml setting hbase.rootdir to /home/coder/hbase_data
RUN tar xzvf /tmp/hbase-2.5.11-bin.tar.gz -C /opt/ && \
    mv /opt/hbase-2.5.11 /opt/hbase && \
    echo '<?xml version="1.0"?>' > /opt/hbase/conf/hbase-site.xml && \
    echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> /opt/hbase/conf/hbase-site.xml && \
    echo '<configuration>' >> /opt/hbase/conf/hbase-site.xml && \
    echo '  <property>' >> /opt/hbase/conf/hbase-site.xml && \
    echo '    <name>hbase.rootdir</name>' >> /opt/hbase/conf/hbase-site.xml && \
    echo '    <value>file:///home/coder/hbase_data</value>' >> /opt/hbase/conf/hbase-site.xml && \
    echo '  </property>' >> /opt/hbase/conf/hbase-site.xml && \
    echo '</configuration>' >> /opt/hbase/conf/hbase-site.xml

### Install Apache Cassandra
# Extract Cassandra and update cassandra.yaml to store data under /home/coder/cassandra_data
RUN tar xzvf /tmp/apache-cassandra-5.0.3-bin.tar.gz -C /opt/ && \
    mv /opt/apache-cassandra-5.0.3 /opt/cassandra && \
    sed -i 's|/var/lib/cassandra|/home/coder/cassandra_data|g' /opt/cassandra/conf/cassandra.yaml

### Install Apache Spark
# Extract Spark and configure event logging to use /home/coder/spark_logs
RUN tar xzvf /tmp/spark-3.5.5-bin-hadoop3.tgz -C /opt/ && \
    mv /opt/spark-3.5.5-bin-hadoop3 /opt/spark && \
    echo "spark.eventLog.enabled true" >> /opt/spark/conf/spark-defaults.conf && \
    echo "spark.eventLog.dir file:///home/coder/spark_logs" >> /opt/spark/conf/spark-defaults.conf

### Install Apache Kafka
# Extract Kafka and update server.properties to use /home/coder/kafka_data for log storage
RUN tar xzvf /tmp/kafka_2.13-4.0.0.tgz -C /opt/ && \
    mv /opt/kafka_2.13-4.0.0 /opt/kafka && \
    sed -i 's|log.dirs=.*|log.dirs=/home/coder/kafka_data|g' /opt/kafka/config/server.properties

# Clean up apt caches and temporary files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /opt/hbase/logs /opt/cassandra/logs /opt/kafka/logs /opt/spark/logs && \
    chown -R coder:coder /opt/hbase /opt/cassandra /opt/spark /opt/kafka

# Switch back to coder user
USER coder

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="/opt/hbase/bin:/opt/cassandra/bin:/opt/spark/bin:/opt/kafka/bin:${PATH}"

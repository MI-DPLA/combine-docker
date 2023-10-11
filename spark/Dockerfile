FROM ghcr.io/mi-dpla/combine-docker/spark-cluster-base:latest

# Arguments
ARG SPARK_VERSION
ENV SPARK_VERSION=$SPARK_VERSION
ARG HADOOP_VERSION_SHORT
ENV HADOOP_VERSION_SHORT=$HADOOP_VERSION_SHORT

# Download and install Spark
RUN cd /tmp \
 && curl https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT}.tgz -o /tmp/spark.tgz \
 && tar -xvf spark.tgz \
 && mv /tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT} /opt/spark
ENV SPARK_HOME=/opt/spark

# Copy configurations
COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf

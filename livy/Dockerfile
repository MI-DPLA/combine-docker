FROM ghcr.io/mi-dpla/combine-docker/django

# Arguments
ARG SCALA_VERSION
ARG ELASTICSEARCH_HADOOP_CONNECTOR_VERSION
ENV SCALA_VERSION=$SCALA_VERSION
ENV ELASTICSEARCH_HADOOP_CONNECTOR_VERSION=$ELASTICSEARCH_HADOOP_CONNECTOR_VERSION

RUN apt-get install -y r-base

# Download and install Livy
RUN cd /opt \
  && git clone https://github.com/MI-DPLA/livy \
  && cd livy \
  && git checkout combine-livy \
  && mvn package -DskipTests \
  && mkdir logs \
  && ln -s /combinelib/ingestion3_${SCALA_VERSION}-0.0.1.jar /opt/livy/rsc/target/jars/ingestion3.jar

# Copy configurations
COPY livy/livy.conf /opt/livy/conf/livy.conf
RUN cat /opt/livy/conf/livy.conf
COPY livy/livy-env.sh /opt/livy/conf/livy-env.sh
COPY livy/log4j.properties /opt/livy/conf/log4j.properties

# Create symlink to ElasticSearch/Hadoop connector
RUN ln -s /combinelib/elasticsearch-hadoop-${ELASTICSEARCH_HADOOP_CONNECTOR_VERSION}.jar /opt/livy/rsc/target/jars/elasticsearch-hadoop-${ELASTICSEARCH_HADOOP_CONNECTOR_VERSION}.jar

# Remove ivy cache directory
# https://github.com/MI-DPLA/combine-docker/issues/5
RUN rm -r /root/.m2

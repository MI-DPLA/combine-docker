FROM combine-docker_combine-django:latest

# Arguments
ARG LIVY_TAGGED_RELEASE
ARG SCALA_VERSION
ARG ELASTICSEARCH_HADOOP_CONNECTOR_VERSION
ENV LIVY_TAGGED_RELEASE=$LIVY_TAGGED_RELEASE
ENV SCALA_VERSION=$SCALA_VERSION
ENV ELASTICSEARCH_HADOOP_CONNECTOR_VERSION=$ELASTICSEARCH_HADOOP_CONNECTOR_VERSION

# Download and install Livy
RUN cd /opt \
 && git clone https://github.com/apache/incubator-livy livy \
 && cd livy \
 && git checkout -b tags/${LIVY_TAGGED_RELEASE} ${LIVY_TAGGED_RELEASE} \
 && mvn package -DskipTests \
 && mkdir logs \
 && ln -s /combinelib/ingestion3_${SCALA_VERSION}-0.0.1.jar /opt/livy/rsc/target/jars/ingestion3.jar

# Copy configurations
ENV FOO=foobar
COPY livy/livy.conf /opt/livy/conf/livy.conf
RUN cat /opt/livy/conf/livy.conf
COPY livy/livy-env.sh /opt/livy/conf/livy-env.sh
COPY livy/log4j.properties /opt/livy/conf/log4j.properties
COPY combinelib/ /combinelib/

# Create symlink to ElasticSearch/Hadoop connector
RUN ln -s /combinelib/elasticsearch-hadoop-${ELASTICSEARCH_HADOOP_CONNECTOR_VERSION}.jar /opt/livy/rsc/target/jars/elasticsearch-hadoop-${ELASTICSEARCH_HADOOP_CONNECTOR_VERSION}.jar

# Remove ivy cache directory
# https://github.com/MI-DPLA/combine-docker/issues/5
RUN rm -r /root/.m2

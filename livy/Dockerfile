FROM combine-docker_combine-django:latest

# Arguments
ARG LIVY_TAGGED_RELEASE
ARG SCALA_VERSION
ENV LIVY_TAGGED_RELEASE=v0.6.0-incubating
ENV SCALA_VERSION=$SCALA_VERSION

# Download and install Livy
RUN cd /opt \
 && git clone https://github.com/apache/incubator-livy livy \
 && cd livy \
 && git checkout -b tags/v0.6.0-incubating v0.6.0-incubating \
 && mvn package -DskipTests \
 && mkdir logs \
 && ln -s /combinelib/ingestion3_${SCALA_VERSION}-0.0.1.jar /opt/livy/rsc/target/jars/ingestion3.jar

# Copy configurations
COPY livy.conf /opt/livy/conf/livy.conf
COPY livy-env.sh /opt/livy/conf/livy-env.sh

# Create symlink to ElasticSearch/Hadoop connector
RUN ln -s /combinelib/elasticsearch-hadoop-5.6.2.jar /opt/livy/rsc/target/jars/elasticsearch-hadoop-5.6.2.jar

# Remove ivy cache directory
# https://github.com/MI-DPLA/combine-docker/issues/5
RUN rm -r /root/.m2

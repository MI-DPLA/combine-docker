
# echo
echo "Running Combine-Docker first build, this should be run only once!"

# format Hadoop namenode
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode && echo 'Y' | ${HADOOP_PREFIX}/bin/hdfs namenode -format"

# Combine db create
docker-compose run combine-django /bin/bash -c "mysql -h 10.5.0.4 -u root -pcombine < /tmp/combine.sql"

# Combine db migrations and superuser create
docker-compose run combine-django /bin/bash -c "/tmp/combine_db_prepare.sh"
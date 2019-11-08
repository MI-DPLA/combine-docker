echo "Running Combine-Docker build script.  Note: this may take some time, anywhere from 5-20 minutes depending on your hardware."

# source .env file
source ./.env

# bring down Combine docker containers, if running
docker-compose down
echo $COMBINE_BRANCH

# init Combine app submodule and use localsettings docker template
#git submodule init
#git submodule update
cd combine/combine
#git fetch
#git checkout $COMBINE_BRANCH
#git pull
if [[ ! -f "./combine/localsettings.py" ]]; then
    cp ./combine/localsettings.py.docker ./combine/localsettings.py
fi
if [[ ! -d "./static/" ]]; then
    mkdir -p static/js/
    cp ./core/static/* static/
fi
mv ./core/static/[^j]*/*.js static/js/
mv ./core/static/*.js static/js/
if [[ ! -f "./static/js/livy-ui.js" ]]; then
    git clone https://github.com/apache/incubator-livy ~/livy
    cp ~/livy/server/src/main/resources/org/apache/livy/server/ui/static/js/*.js ./static/js/
fi
cd ../../

# build images
docker volume rm combine_python_env hadoop_binaries spark_binaries livy_binaries combine_tmp
docker-compose build

# format Hadoop namenode
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode"
docker-compose run hadoop-namenode /bin/bash -c "echo 'Y' | /opt/hadoop/bin/hdfs namenode -format"

# Combine db migrations and superuser create
docker-compose run combine-django /bin/bash -c "bash /tmp/combine_db_prepare.sh"

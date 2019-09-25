echo "Running Combine-Docker UPDATE script.  Note: this may take some time, anywhere from 5-20 minutes depending on your hardware."

# source .env file
source ./.env

# bring down Combine docker containers, if running
docker-compose down
echo $COMBINE_BRANCH

# init Combine app submodule and use localsettings docker template
git submodule init
git submodule update
cd combine/combine
git fetch
git checkout $COMBINE_BRANCH
git pull
cd ../../

# build images
docker volume rm combine_python_env hadoop_binaries spark_binaries livy_binaries combine_tmp
docker-compose build

# run migrations in Combine Django app
bin/combine_migrations.sh

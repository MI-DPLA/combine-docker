#!/bin/bash

#######################################################################
### 
### The intent of this script is to install the Combine-Docker
### application and log messages to an output file in the process.
### It's not pretty code; sorry.  My shell scripts are typically
### cobbled-together hacks, and this is no exception.
###
### This script also invokes the scripts:
###
###  - buildstatic.sh
###  - combine_db_prepare.sh
###
###


# get datetime when script is run; use this for logfile names
RUNDATE=`date +%Y-%m-%d_%H-%m-%S`
WORKDIR=$(pwd)

# source .env file containing details about software versions, Django host port used
source ./.env

# we will log output in output files in subdirectories named according to date-time of build run
if [ ! -d $WORKDIR/buildlogs ]
then
    mkdir $WORKDIR/buildlogs
fi
BUILDLOGDIR=$WORKDIR/buildlogs/build-log_$RUNDATE
mkdir $BUILDLOGDIR
export BUILDLOG=$BUILDLOGDIR/build-log_$RUNDATE.log

echo ""
echo ""

echo "####################################################################################################"
echo "### BUILDLOG:  Running Combine-Docker build script. "
echo "### BUILDLOG:  Note: this may take some time, depending on your hardware and remote server response"
echo "### BUILDLOG" | tee -a $BUILDLOG
echo "### BUILDLOG:  Base install directory (WORKDIR) is:  $WORKDIR" | tee -a $BUILDLOG
echo "### BUILDLOG:  " | tee -a $BUILDLOG
echo "### BUILDLOG:  To see logs as they're created:  tail -f $BUILDLOG "
echo "### BUILDLOG:"
echo "### BUILDLOG:  hit ENTER to continue..."
read ANSWER
echo "### BUILDLOG:  Base install directory (WORKDIR) is:  $WORKDIR" | tee -a $BUILDLOG
echo "### BUILDLOG: "

# bring down Combine docker containers, if running
echo "### BUILDLOG:  Bringing down Docker containers (if they're running)"  | tee -a $BUILDLOG
docker-compose down 2>&1 | sed -e 's/^/    /g'
echo | tee -a $BUILDLOG

echo "### BUILDLOG:  Setting up nginx with basic config"  | tee -a $BUILDLOG
# basic setup for nginx
touch $WORKDIR/nginx/error.log
if [[ ! -f "$WORKDIR/nginx/nginx.conf" ]]; then
  cp $WORKDIR/nginx/nginx.conf.template $WORKDIR/nginx/nginx.conf
fi

echo "### BUILDLOG:  Current COMBINE_BRANCH is:  $COMBINE_BRANCH"

# init Combine app submodule and use localsettings docker template
echo "### BUILDLOG:     Initializing Combine app submodule" 2>&1 | tee -a $BUILDLOG
echo "### BUILDLOG:     Working with Combine git branch:  $COMBINE_BRANCH" 2>&1 | tee -a $BUILDLOG
echo "### BUILDLOG:"   | tee -a $BUILDLOG
echo "### BUILDLOG:     Run:  git submodule init"   | tee -a $BUILDLOG
#git submodule init 2>&1 | sed -e 's/^/    /g' | tee -a $BUILDLOG
#echo ""   | tee -a $BUILDLOG

#echo "### BUILDLOG:     Run:  git submodule update"   | tee -a $BUILDLOG
#git submodule update 2>&1 | sed -e 's/^/    /g' | tee -a $BUILDLOG
#echo ""   | tee -a $BUILDLOG


#echo "### BUILDLOG:  Git fetching desired Combine git branch" 2>&1 | tee -a $BUILDLOG
#cd $WORKDIR/combine/combine
#git fetch 2>&1 | sed -e 's/^/    /g' | tee -a $BUILDLOG
#echo ""  | tee -a $BUILDLOG

#echo "### BUILDLOG:  Git checkout desired Combine git branch" 2>&1 | tee -a $BUILDLOG
#git checkout $COMBINE_BRANCH | sed -e 's/^/    /g' | tee -a $BUILDLOG
#echo "" | tee -a $BUILDLOG

#echo "### BUILDLOG:  Git pull" 2>&1 | tee -a $BUILDLOG
#git pull | sed -e 's/^/    /g' | tee -a $BUILDLOG
#echo "" | tee -a $BUILDLOG

echo "### BUILDLOG:  Configure some defaults" 2>&1 | tee -a $BUILDLOG

if [[ ! -f "./combine/localsettings.py" ]]; then
    cp ./combine/combine/combine/localsettings.py.docker ./combine/localsettings.py
fi
sed -i 's/3306/3307/' ./combine/combine/combine/settings.py # mysql port is 3307 in docker, 3306 by default

if [[ ! -d "$WORKDIR/combine/combine/static/js/" ]]; then
  mkdir -p $WORKDIR/combine/combine/static/js/
fi
echo "" | tee -a $BUILDLOG

cd $WORKDIR

# build images
echo "### BUILDLOG:  Removing existing Docker images...they may not exist" 2>&1 | tee -a $BUILDLOG
docker volume rm combine-docker_combine_python_env \
                 combine-docker_combine_tmp \
                 combine-docker_combinelib \
                 combine-docker_hadoop_binaries \
                 combine-docker_livy_binaries \
                 combine-docker_spark_binaries \
                 combine-docker_livy_binaries \
		 2>&1 | sed -e 's/^/    /g' | tee -a $BUILDLOG
echo ""   | tee -a $BUILDLOG


echo "### BUILDLOG:  run:  docker-compose build"   | tee -a $BUILDLOG
docker-compose build 2>&1 | sed -e 's/^/    /g' | tee -a $BUILDLOG
echo ""   | tee -a $BUILDLOG

# format Hadoop namenode
echo "### BUILDLOG:  formatting hadoop-namenode" 2>&1 | tee -a $BUILDLOG
echo "### BUILDLOG:"   | tee -a $BUILDLOG
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode"   2>&1 | sed -e 's/^/    /g' | tee -a $BUILDLOG
docker-compose run hadoop-namenode /bin/bash -c "echo 'Y' | /opt/hadoop/bin/hdfs namenode -format"  2>&1| sed -e 's/^/    /g' | tee -a $BUILDLOG
echo ""   | tee -a $BUILDLOG


# Combine db migrations and superuser create

echo "########################################################################"
echo " The next step might take a LONG time to run.  CTRL-C now if you want to "
echo " terminate the installer early for debugging purposes.  Otherwise:"
echo " "
echo "     Hit ENTER to continue"

read junk


echo "### BUILDLOG:  Combine db migrations and creation of superuser; Be patient...this takes some time" 2>&1 | tee -a $BUILDLOG
echo "###   The /tmp/combine_db_prepare.sh script creates 'combine' mysql db in the mysql docker container," 2>&1 | tee -a $BUILDLOG
echo "###   and runs 'python /opt/combine/manage.py <various operations>'" 2>&1 | tee -a $BUILDLOG
echo "###" 2>&1 | tee -a $BUILDLOG
echo "###   combine_db_prepare.sh begin time:  `date`" 2>&1 | tee -a $BUILDLOG
echo "" 2>&1 | tee -a $BUILDLOG
docker-compose 2>&1 run combine-django /bin/bash -c "bash /tmp/combine_db_prepare.sh"  | sed -e 's/^/    /g' | tee -a $BUILDLOG
echo "" 2>&1 | tee -a $BUILDLOG
echo "###   combine_db_prepare.sh end time:  `date`" 2>&1 | tee -a $BUILDLOG
echo "" 2>&1 | tee -a $BUILDLOG

echo "### BUILDLOG ###############################################################################################:"   | tee -a $BUILDLOG
echo "### BUILDLOG ###############################################################################################:"   | tee -a $BUILDLOG
echo "### BUILDLOG:"   | tee -a $BUILDLOG
echo "" | tee -a $BUILDLOG
echo "### BUILDLOG:  Passing control to buildstatic.sh" 2>&1 | tee -a $BUILDLOG
echo "### BUILDLOG:"   | tee -a $BUILDLOG
echo "### BUILDLOG:"   | tee -a $BUILDLOG
echo ""   | tee -a $BUILDLOG
$WORKDIR/buildstatic.sh

echo "### BUILDLOG ###############################################################################################:"   | tee -a $BUILDLOG
echo "### BUILDLOG ###############################################################################################:"   | tee -a $BUILDLOG
echo "### BUILDLOG:"   | tee -a $BUILDLOG
echo "### BUILDLOG:  build.sh has completed." 2>&1 | tee -a $BUILDLOG
echo "### BUILDLOG:"   | tee -a $BUILDLOG
echo ""   | tee -a $BUILDLOG


echo "### BUILDLOG:  Docker containers on the system:"    | tee -a $BUILDLOG
docker container ls --all | sed -e 's/^/    /g' | tee -a $BUILDLOG
echo ""    | tee -a $BUILDLOG


echo "### BUILDLOG:  Docker volumes on the system:"    | tee -a $BUILDLOG
docker volume ls | sed -e 's/^/    /g' | tee -a $BUILDLOG
echo ""    | tee -a $BUILDLOG

cat | tee -a $BUILDLOG <<EOF

The installation of the Combine-Docker application is complete.

If all went well, then you can start the application by running:

    docker-compose up

By default, the application will listen to ports 80/443 of localhost
on this system.  Add an external-facing IP or hostname to the app
by editing the configuration file:

    ./docker-compose.yml

The changes needed are more fully documented in the
./docs/combine_docker_ubuntu_installation_instructions.md file.

Output from this installer can be found in the file:

    $BUILDLOG

EOF


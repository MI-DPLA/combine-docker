#!/usr/bin/env bash


###
### my logging logic is flawed in this file and needs to be revisited /pdk
###

echo "### BUILDLOG:  beginning the /tmp/combine_db_prepare.sh script" | tee -a $BUILDLOG

BUILDLOG=$1

# run combine migrations
echo "    waiting for MySQL container to be ready..." | tee -a $BUILDLOG
while [ ! "`mysqladmin ping -h mysql --port=3307 -pcombine --silent`" ]; do
    echo "    waiting..." | tee -a $BUILDLOG
    sleep 1
done
echo "    MySQL container is ready!"  | tee -a $BUILDLOG

echo "### BUILDLOG:  Creating the combine db in mysql" 2>&1 | tee -a $BUILDLOG
mysql -h mysql --port=3307 -u root -pcombine < /tmp/combine.sql 2>&1 | tee -a $BUILDLOG


echo "### BUILDLOG:  Running /opt/combine/manage.py makemigrations" 2>&1 | tee -a $BUILDLOG
python /opt/combine/manage.py makemigrations 2>&1 | tee -a $BUILDLOG 

echo "### BUILDLOG:  Running /opt/combine/manage.py migrate" 2>&1 | tee -a $BUILDLOG
python /opt/combine/manage.py migrate 2>&1 | tee -a $BUILDLOG

echo "### BUILDLOG:  Running /opt/combine/manage.py makemigrations core" 2>&1 | tee -a $BUILDLOG
python /opt/combine/manage.py makemigrations core 2>&1 | tee -a $BUILDLOG

echo "### BUILDLOG:  Running /opt/combine/manage.py migrate core" 2>&1 | tee -a $BUILDLOG
python /opt/combine/manage.py migrate core 2>&1 | tee -a $BUILDLOG

echo "### BUILDLOG:  Running /opt/combine/manage.py createsuperuser" 2>&1 | tee -a $BUILDLOG
python /opt/combine/manage.py createsuperuser 2>&1 | tee -a $BUILDLOG

echo "### BUILDLOG:  Running /opt/combine/manage.py collectstatic" 2>&1 | tee -a $BUILDLOG
python /opt/combine/manage.py collectstatic --noinput --clear 2>&1 | tee -a $BUILDLOG

echo "### BUILDLOG:  /tmp/combine_db_prepare.sh script has finished" | tee -a $BUILDLOG

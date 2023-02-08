#!/usr/bin/env bash

echo "### BUILDLOG:  beginning the /tmp/combine_db_prepare.sh script" 

# run combine migrations
echo "    waiting for MySQL container to be ready..."
while [ ! "`mysqladmin ping -h mysql --port=3307 -pcombine --silent`" ]; do
    echo "    waiting..." 
    sleep 1
done
echo "    MySQL container is ready!" 

echo "### BUILDLOG:  Creating the combine db in mysql" 2>&1 
mysql -h mysql --port=3307 -u root -pcombine < /tmp/combine.sql 

echo "### BUILDLOG:  Running /opt/combine/manage.py makemigrations" 
python /opt/combine/manage.py makemigrations

echo "### BUILDLOG:  Running /opt/combine/manage.py migrate"
python /opt/combine/manage.py migrate

echo "### BUILDLOG:  Running /opt/combine/manage.py makemigrations core"
python /opt/combine/manage.py makemigrations core

echo "### BUILDLOG:  Running /opt/combine/manage.py migrate core"
python /opt/combine/manage.py migrate core

echo "### BUILDLOG:  Running /opt/combine/manage.py createsuperuser"
python /opt/combine/manage.py createsuperuser

echo "### BUILDLOG:  Running /opt/combine/manage.py collectstatic"
python /opt/combine/manage.py collectstatic --noinput --clear

echo "### BUILDLOG:  /tmp/combine_db_prepare.sh script has finished"

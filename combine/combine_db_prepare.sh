#!/usr/bin/env bash

BUILDLOG=$1

# run combine migrations
echo "    waiting for MySQL container to be ready..." | tee -a $BUILDLOG
while [ ! "`mysqladmin ping -h mysql --port=3307 -pcombine --silent`" ]; do
    echo "    waiting..." | tee -a $BUILDLOG
    sleep 1
done
echo "    MySQL container is ready!"  | tee -a $BUILDLOG
mysql -h mysql --port=3307 -u root -pcombine < /tmp/combine.sql 2>&1 | tee -a $BUILDLOG
python /opt/combine/manage.py makemigrations 2>&1 | tee -a $BUILDLOG
python /opt/combine/manage.py migrate 2>&1 | tee -a $BUILDLOG
python /opt/combine/manage.py makemigrations core 2>&1 | tee -a $BUILDLOG
python /opt/combine/manage.py migrate core 2>&1 | tee -a $BUILDLOG
python /opt/combine/manage.py createsuperuser 2>&1 | tee -a $BUILDLOG
python /opt/combine/manage.py collectstatic --noinput --clear 2>&1 | tee -a $BUILDLOG

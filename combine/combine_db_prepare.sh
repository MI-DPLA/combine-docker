#!/usr/bin/env bash

# run combine migrations
echo "waiting for MySQL container to be ready..."
while [ ! "`mysqladmin ping -h mysql --port=3307 -p$MYSQL_ROOT_PASSWORD --silent`" ]; do
    echo "waiting..."
    sleep 1
done
echo "ready!"
mysql -h mysql --port=3307 -p$MYSQL_ROOT_PASSWORD < /tmp/combine.sql
python /opt/combine/manage.py makemigrations
python /opt/combine/manage.py migrate
python /opt/combine/manage.py makemigrations core
python /opt/combine/manage.py migrate core
python /opt/combine/manage.py createsuperuser
python /opt/combine/manage.py collectstatic --noinput --clear

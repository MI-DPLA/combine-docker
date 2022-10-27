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
HOSTNAME=`hostname`
echo "### BUILDLOG:  running on $HOSTNAME"
mysql -h mysql --port=3307 -u root -pcombine < /tmp/combine.sql 

echo " "
echo " "
echo " "

echo "### BUILDLOG:  Running /opt/combine/manage.py makemigrations" 
echo "### BUILDLOG:  running on $HOSTNAME"
python /opt/combine/manage.py makemigrations

echo " "
echo " "
echo "### BUILDLOG:  running ls /opt/"
ls -l /opt
echo " "

echo "### BUILDLOG:  running ls /opt/combine"
ls -l /opt/combine
echo " "

echo "### BUILDLOG:  running ls /opt/combine/combine"
ls -l /opt/combine/combine
echo " "


echo "### BUILDLOG:  find any settings.py files "
find / -name settings.py

#echo "###"
#echo "### BUILDLOG:  cat any settings.py files"
#cat `find . -name settings.py -print`

#echo "###"
echo "### BUILDLOG:  find any localsettings.py files"
find / -name localsettings.py -print

echo "### BUILDLOG:  Running /opt/combine/manage.py migrate"
echo "### BUILDLOG:  running on $HOSTNAME"
python /opt/combine/manage.py migrate

echo "### BUILDLOG:  Running /opt/combine/manage.py makemigrations core"
echo "### BUILDLOG:  running on $HOSTNAME"
python /opt/combine/manage.py makemigrations core

echo "### BUILDLOG:  Running /opt/combine/manage.py migrate core"
echo "### BUILDLOG:  running on $HOSTNAME"
python /opt/combine/manage.py migrate core

echo "### BUILDLOG:  Running /opt/combine/manage.py createsuperuser"
echo "### BUILDLOG:  running on $HOSTNAME"
python /opt/combine/manage.py createsuperuser

echo "### BUILDLOG:  Running /opt/combine/manage.py collectstatic"
echo "### BUILDLOG:  running on $HOSTNAME"
python /opt/combine/manage.py collectstatic --noinput --clear

echo "### BUILDLOG:  /tmp/combine_db_prepare.sh script has finished"

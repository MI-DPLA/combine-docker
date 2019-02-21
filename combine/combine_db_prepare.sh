mysql -h 10.5.0.4 -u root -pcombine < /tmp/combine.sql
python /opt/combine/manage.py makemigrations
python /opt/combine/manage.py migrate
echo "from django.contrib.auth.models import User; User.objects.create_superuser('combine'"," 'root@none.com'"," 'combine')" | python /opt/combine/manage.py shell
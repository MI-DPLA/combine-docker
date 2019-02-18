## First Build Notes

### Create MySQL combine database & run Migrations

internal:
```
mysql -h 10.5.0.4 -u root -pcombine < /tmp/combine.sql
./manage.py makemigrations
./manage.py migrate
echo "from django.contrib.auth.models import User; User.objects.create_superuser('combine'"," 'root@none.com'"," 'combine')" | python /opt/combine/manage.py shell
```

docker:
```
docker-compose run combine-django /bin/bash -c "/tmp/combine_db_prepare.sh"
```


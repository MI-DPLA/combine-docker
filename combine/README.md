## First Build Notes

### Create MySQL combine database.

internal:
```
mysql -h 10.5.0.4 -u root -pcombine < /tmp/combine.sql
```

docker:
```
docker-compose run combine-django /bin/bash -c "mysql -h 10.5.0.4 -u root -pcombine < /tmp/combine.sql"
```

### Run Migrations

internal:
```
./manage.py makemigrations
./manage.py migrate
echo "from django.contrib.auth.models import User; User.objects.create_superuser('combine'"," 'root@none.com'"," 'combine')" | python /opt/combine/manage.py shell
```

docker:
```
docker-compose run combine-django /bin/bash -c "/tmp/combine_db_prepare.sh"
```


### ToDo

  * if dockerized, handle not checking supervisor for celery status
  * configure Mongo host
  * configure elasticsearch host
  * create indices for Mongo collections:
  `https://github.com/WSULib/combine-playbook/blob/master/roles/combine/tasks/main.yml#L98`
  * going to have to wait for MySQL to start the first time (and in general)
    * ping port `3306`?
  * `dockerized` branch
    * will need to revisit supervisor hard sets to `None`

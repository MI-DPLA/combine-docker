## First Build Notes

Create MySQL combine database:
```
docker-compose run combine-django /bin/bash -c "mysql -h 10.5.0.4 -u root -pcombine < /tmp/combine.sql"
```

Run db prepare script:
```
docker-compose run combine-django /bin/bash -c "/tmp/combine_db_prepare.sh"
```

And that should run:
```
./manage.py makemigrations
./manage.py migrate
"from django.contrib.auth.models import User; User.objects.create_superuser('combine'"," 'root@none.com'"," '{{ django_combine_user_password }}')" | python /opt/combine/manage.py shell
```

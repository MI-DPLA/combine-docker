FROM combine-docker_combine-django:latest

RUN pip3.7 install supervisor && \
    mkdir -p /var/log/supervisor

COPY ./celery/supervisord.conf /etc/supervisor/supervisord.conf

#RUN service start supervisor

#RUN  celery -A core worker -l info --concurrency 1

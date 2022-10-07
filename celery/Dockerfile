FROM combine_combine-django:latest

ENV RUNLEVEL=1
RUN echo exit 0 > /usr/sbin/policy-rc.d
RUN apt-get update && apt-get install -y supervisor

COPY ./celery/supervisord.conf /etc/supervisor/supervisord.conf

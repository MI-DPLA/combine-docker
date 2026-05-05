FROM ghcr.io/mi-dpla/combine-docker/django:latest

ENV RUNLEVEL=1
RUN echo exit 0 > /usr/sbin/policy-rc.d && \
  apt-get update && apt-get install -y supervisor && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY ./celery/supervisord.conf /etc/supervisor/supervisord.conf

FROM homeassistant/home-assistant:latest as homeassistant

FROM python:3.7

VOLUME /config
WORKDIR /usr/src/app

# Copy build scripts
COPY --from=homeassistant /usr/src/app/virtualization/Docker/ virtualization/Docker/
RUN virtualization/Docker/setup_docker_prereqs

# Install hass component dependencies
COPY --from=homeassistant /usr/src/app/requirements_all.txt requirements_all.txt

# Uninstall enum34 because some dependencies install it but breaks Python 3.4+.
# See PR #8103 for more info.
RUN pip3 install --no-cache-dir -r requirements_all.txt && \
    pip3 install --no-cache-dir mysqlclient psycopg2 uvloop==0.12.2 cchardet cython tensorflow

# Copy source
COPY --from=homeassistant /usr/src/app/. .

CMD [ "python", "-m", "homeassistant", "--config", "/config" ]

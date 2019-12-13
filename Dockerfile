FROM eu.gcr.io/tm-preview/tm-superset-base-image:191213.072550  # deps for superset 0.35.1

ARG SUPERSET_VERSION=not_set
ARG ASSETS_HOME=/usr/local/lib/python3.6/site-packages/superset/static/assets/images

# Configure environment
ENV GUNICORN_BIND=0.0.0.0:8088 \
    GUNICORN_LIMIT_REQUEST_FIELD_SIZE=0 \
    GUNICORN_LIMIT_REQUEST_LINE=0 \
    GUNICORN_TIMEOUT=60 \
    GUNICORN_WORKERS=2 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:/home/superset:$PYTHONPATH \
    SUPERSET_REPO=apache/incubator-superset \
    SUPERSET_VERSION=${SUPERSET_VERSION} \
    SUPERSET_HOME=/var/lib/superset
ENV GUNICORN_CMD_ARGS="--workers ${GUNICORN_WORKERS} --timeout ${GUNICORN_TIMEOUT} --bind ${GUNICORN_BIND} --limit-request-line ${GUNICORN_LIMIT_REQUEST_LINE} --limit-request-field_size ${GUNICORN_LIMIT_REQUEST_FIELD_SIZE}"

########## BEGIN From contrib/docker image
WORKDIR /home/superset

COPY requirements.txt .
COPY requirements-dev.txt .
COPY contrib/docker/requirements-extra.txt .

RUN pip install --upgrade setuptools pip \
    && pip install -r requirements.txt -r requirements-dev.txt -r requirements-extra.txt \
    && rm -rf /root/.cache/pip

COPY --chown=superset:superset superset superset

ENV PATH=/home/superset/superset/bin:$PATH \
    PYTHONPATH=/home/superset/superset/:$PYTHONPATH

USER superset

RUN cd superset/assets && \
    rm -rf build && \
    rm -rf node_modules && \
    npm ci && \
    npm run build && \
    rm -rf node_modules
########## END

# logo
COPY assets/images/tm_logo_220_54.png $ASSETS_HOME

# Configure Filesystem
VOLUME /home/superset \
    /etc/superset \
    /var/lib/superset
WORKDIR /home/superset

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
CMD ["gunicorn", "superset:app"]
USER superset

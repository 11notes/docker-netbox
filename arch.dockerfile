# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      APP_PYTHON_VERSION=0.0

# :: FOREIGN IMAGES
  FROM 11notes/util AS util
  FROM 11notes/util:bin AS util-bin
  FROM 11notes/distroless:localhealth AS distroless-localhealth


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: NETBOX REQUIREMENTS
  FROM alpine AS netbox
  COPY --from=util-bin / /
  ARG APP_VERSION

  RUN set -ex; \
    apk --no-cache --update add \
      curl \
      git;

  RUN set -ex; \
    eleven git clone netbox-community/netbox.git v${APP_VERSION}; \
    mv /netbox /opt;

  RUN set -ex; \
    eleven git clone netbox-community/netbox-docker.git;

  RUN set -ex; \
    cd /opt/netbox; \
    sed -i -e '/gunicorn/d' requirements.txt; \
    sed -i -e 's/social-auth-core/social-auth-core\[all\]/g' requirements.txt; \
    sed -i -e 's/django-storages/django-storages\[azure,boto3,dropbox,google,libcloud,sftp\]/g' requirements.txt; \
    cat /netbox-docker/requirements-container.txt >> /opt/netbox/requirements.txt; \
    cp /netbox-docker/docker/granian.py /opt/netbox/netbox/netbox/granian.py;

# :: NETBOX
  FROM 11notes/python:${APP_PYTHON_VERSION} AS build
  USER root
  ARG APP_UID \
      APP_GID \
      APP_ROOT
  COPY --from=util / /
  COPY --from=netbox /opt/netbox /opt
  COPY --from=netbox /opt/netbox/requirements.txt /opt/netbox/requirements.txt
  COPY --from=distroless-localhealth / /

  RUN set -ex; \
    apk --no-cache --update add \
      uwsgi \
      libldap \
      postgresql-client;

  RUN set -ex; \
    pip install \
      uv;

  RUN set -ex; \
    eleven mkdir ${APP_ROOT}/{etc,var}; \
    eleven mkdir ${APP_ROOT}/var/{reports,media,scripts};

  RUN set -ex; \
    sed -i '/^--no-binary/d' /opt/netbox/requirements.txt; \
    uv pip install \
      --only-binary=:all: \
      -r /opt/netbox/requirements.txt; \
    rm -f /opt/netbox/requirements.txt; \
    rm -rf /pip/wheels;

  COPY ./rootfs /

  RUN set -ex; \
    ln -sf ${APP_ROOT}/etc/config.py /opt/netbox/netbox/configuration.py; \
    mkdir -p /opt/netbox/static;

  RUN set -ex; \
    cd /opt/netbox; \
    SECRET_KEY="$(head -c 64 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 60)" \
      python manage.py collectstatic --no-input;

  RUN set -ex; \
    chmod +x -R /usr/local/bin; \
    chown -R ${APP_UID}:${APP_GID} \
      /opt/netbox \
      ${APP_ROOT};


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=build / /

# :: PERSISTENT STORAGE
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: HEALTH
  HEALTHCHECK --interval=5s --timeout=2s --start-period=60s \
    CMD ["/usr/local/bin/localhealth", "http://127.0.0.1:8080/login/", "-I"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
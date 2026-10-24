ARG APP_UID=1000
ARG APP_GID=1000

# :: Util
  FROM 11notes/util AS util
    
  FROM alpine AS netbox
  ARG APP_VERSION

  RUN set -ex; \
    apk --no-cache --update add \
      curl \
      git; \
    mkdir -p /opt/netbox; \
    curl -SL https://github.com/netbox-community/netbox/archive/v${APP_VERSION}.tar.gz | tar --strip-components=1 -zxC /opt/netbox; \
    git clone https://github.com/netbox-community/netbox-docker; \
    cd /opt/netbox; \
    sed -i -e '/gunicorn/d' requirements.txt; \
    sed -i -e 's/social-auth-core/social-auth-core\[all\]/g' requirements.txt; \
    sed -i -e 's/django-storages/django-storages\[azure,boto3,dropbox,google,libcloud,sftp\]/g' requirements.txt; \
    cat /netbox-docker/requirements-container.txt >> /opt/netbox/requirements.txt;

  FROM 11notes/alpine:stable AS build
  COPY --from=netbox /opt/netbox /opt/netbox
  USER root

  RUN set -ex; \
    apk add --no-cache --upgrade \
      build-base \
      cargo \
      jpeg-dev \
      libffi-dev \
      libxslt-dev \
      libxml2-dev \
      openldap-dev \
      openssl-dev \
      pkgconf \
      postgresql-dev \
      py3-pip \
      python3-dev \
      xmlsec-dev \
      zlib-dev;

  RUN set -ex; \
    pip3 install -r /opt/netbox/requirements.txt --prefix=/install --ignore-installed --break-system-packages;

# :: Header
  FROM 11notes/alpine:stable

  # :: arguments
    ARG TARGETARCH \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID

    # :: python image
    ARG PIP_ROOT_USER_ACTION=ignore \
        PIP_BREAK_SYSTEM_PACKAGES=1 \
        PIP_DISABLE_PIP_VERSION_CHECK=1 \
        PIP_NO_CACHE_DIR=1

  # :: environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT} \
        APP_OPT_ROOT=/opt/netbox/netbox

    ENV NETBOX_ADMIN="admin" \
        NETBOX_ADMIN_EMAIL="info@home.arpa"

  # :: multi-stage
    COPY --from=util /usr/local/bin /usr/local/bin
    COPY --from=netbox /opt/netbox /opt
    COPY --from=build /install /usr

# :: Run
  USER root

  # :: install application
    RUN set -ex; \
      eleven printenv; \
      apk --no-cache --update add \
        uwsgi \
        uwsgi-python \
        libldap \
        libxml2 \
        libxslt \
        xmlsec \
        postgresql-client \
        python3 \
        py3-packaging;

    RUN set -ex; \
      eleven mkdir ${APP_ROOT}/{etc,var}; \
      eleven mkdir ${APP_ROOT}/var/{reports,media,scripts}; \
      ln -sf ${APP_ROOT}/etc/config.py ${APP_OPT_ROOT}/configuration.py;

    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin; \
      chown -R ${APP_UID}:${APP_GID} \
        /opt/netbox \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s --start-period=60s \
    CMD ["curl", "-kILs", "--fail", "http://localhost:3000/login/"]

# :: Start
  USER ${APP_UID}:${APP_GID}
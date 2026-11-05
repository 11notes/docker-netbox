#!/bin/ash
  if [ -z "${1}" ]; then
    cd /opt/netbox

    if ! ./manage.py migrate --check >/dev/null 2>&1; then
      eleven log info "updating database ..."
      ./manage.py migrate --no-input
      ./manage.py trace_paths --no-input
      ./manage.py reindex --lazy
    fi

    ash /usr/local/bin/superuser.sh

    export GRANIAN_PORT=${GRANIAN_PORT:-8080}
    export GRANIAN_WORKERS=${GRANIAN_WORKERS:-4}

    set -- granian \
      --host "::" \
      --interface "wsgi" \
      --no-ws \
      --respawn-failed-workers \
      --loop "uvloop" \
      --log \
      --log-level "warning" \
      --working-dir "/opt/netbox" \
      --static-path-route "/static" \
      --static-path-mount "/opt/netbox/static/" \
      --static-path-dir-to-file index.html \
      "netbox.granian:application"

    eleven log start
  fi

  exec "$@"
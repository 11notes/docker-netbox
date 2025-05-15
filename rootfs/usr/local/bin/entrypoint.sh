#!/bin/ash
  if [ -z "${1}" ]; then
    cd /opt/netbox

    if cat /opt/netbox/netbox/configuration.py | grep -q "SECRET_KEY = False"; then
      sed -i 's/SECRET_KEY = False/SECRET_KEY = '\'$(eleven randomString 51)\''/' /netbox/etc/config.py
      eleven log warning "no secret key was set, generating random secret key and adding to config"
    fi

    if ! ./manage.py migrate --check >/dev/null 2>&1; then
      eleven log info "updating database ..."
      ./manage.py migrate --no-input
      ./manage.py trace_paths --no-input
      ./manage.py reindex --lazy
    fi

    ash /usr/local/bin/superuser.sh

    set -- "uwsgi" \
      uwsgi.ini
    
    eleven log start
  fi

  exec "$@"
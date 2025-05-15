#!/bin/ash
  cd /opt/netbox
  NETBOX_ADMIN_TOKEN=$(eleven randomString 40)
  ./manage.py shell --interface python <<END
from users.models import Token, User
if not User.objects.filter(username='${NETBOX_ADMIN}'):
    u = User.objects.create_superuser('${NETBOX_ADMIN}', '${NETBOX_ADMIN_EMAIL}', '${NETBOX_ADMIN_PASSWORD}')
    Token.objects.create(user=u, key='${NETBOX_ADMIN_TOKEN}')
    print("super user ${NETBOX_ADMIN} (API: ${NETBOX_ADMIN_TOKEN}) was successfully created")
END
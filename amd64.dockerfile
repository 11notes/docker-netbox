# :: Header
    FROM netboxcommunity/netbox:v2.11-ldap


# :: Run
    USER root

    # :: copy root filesystem changes
        COPY ./rootfs /

    # :: install
        RUN set -ex; \
            addgroup --gid 1000 -S netbox; \
		    adduser --uid 1000 -D -S -h /opt/netbox/netbox -s /sbin/nologin -G netbox netbox;

    # :: docker -u 1000:1000 (no root initiative)
        RUN set -ex; \
            chown -R netbox:netbox \
                /opt/netbox/netbox \
                /etc/netbox

# :: Start
    USER netbox
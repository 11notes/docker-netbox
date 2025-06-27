![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# NETBOX
![size](https://img.shields.io/docker/image-size/11notes/netbox/4.3.3?color=0eb305)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![version](https://img.shields.io/docker/v/11notes/netbox/4.3.3?color=eb7a09)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![pulls](https://img.shields.io/docker/pulls/11notes/netbox?color=2b75d6)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)[<img src="https://img.shields.io/github/issues/11notes/docker-NETBOX?color=7842f5">](https://github.com/11notes/docker-NETBOX/issues)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

Run NetBox smaller, lightweight and more secure than ever

# SYNOPSIS 📖
**What can I do with this?** This image will give you a rootless and lightweight NetBox installation. NetBox exists to empower network engineers. Since its release in 2016, it has become the go-to solution for modeling and documenting network infrastructure for thousands of organizations worldwide. As a successor to legacy IPAM and DCIM applications, NetBox provides a cohesive, extensive, and accessible data model for all things networked. By providing a single robust user interface and programmable APIs for everything from cable maps to device configurations, NetBox serves as the central source of truth for the modern network.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! All the other images on the market that do exactly the same don’t do or offer these options:

> [!IMPORTANT]
>* This image runs as 1000:1000 by default, most other images run everything as root
>* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
>* This image contains a proper health check that verifies the app is actually working, most other images have either no health check or only check if a port is open or ping works
>* This repository has an auto update feature that will automatically build the latest version if released, most other providers don't do this
>* This image is smaller than most other images

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | 11notes/netbox:4.3.3 | netboxcommunity/netbox:v4.3.3 |
| ---: | :---: | :---: |
| **image size on disk** | 538MB | 702MB |
| **process UID/GID** | 1000/1000 | 0/0 |
| **distroless?** | ❌ | ❌ |
| **rootless?** | ✅ | ❌ |


# VOLUMES 📁
* **/netbox/etc** - Directory of the config.py
* **/netbox/var** - Directory of reports, uploads and scripts

# COMPOSE ✂️
```yaml
name: "netbox"
services:
  postgres:
    image: "11notes/postgres:16"
    read_only: true
    environment:
      TZ: "Europe/Zurich"
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - "postgres.etc:/postgres/etc"
      - "postgres.var:/postgres/var"
      - "postgres.cmd:/run/cmd"
    tmpfs:
      - "/run/postgresql:uid=1000,gid=1000"
      - "/postgres/log:uid=1000,gid=1000"
    networks:
      backend:
    restart: "always"

  cron:
    depends_on:
      postgres:
        condition: "service_healthy"
        restart: true
    image: "11notes/cron:4.6"
    environment:
      TZ: "Europe/Zurich"
      CRONTAB: |-
        0 3 * * * cmd-socket '{"bin":"backup"}' > /proc/1/fd/1
    volumes:
      - "postgres.cmd:/run/cmd"
    restart: "always"

  redis:
    image: "11notes/redis:7.4.2"
    environment:
      REDIS_PASSWORD: ${REDIS_PASSWORD}
      TZ: "Europe/Zurich"
    volumes:
      - "redis.etc:/redis/etc"
      - "redis.var:/redis/var"
    networks:
      backend:
    restart: always

  app:
    depends_on:
      postgres:
        condition: "service_healthy"
        restart: true
      redis:
        condition: "service_healthy"
        restart: true
    image: "11notes/netbox:4.3.3"
    environment:
      TZ: "Europe/Zurich"
      NETBOX_ADMIN_PASSWORD: ${NETBOX_ADMIN_PASSWORD}
    volumes:
      - "etc:/netbox/etc"
      - "var:/netbox/var"
    tmpfs:
      - "/run:uid=1000,gid=1000"
    ports:
      - "3000:3000/tcp"
    networks:
      frontend:
      backend:
    restart: "always"

volumes:
  etc:
  var:
  postgres.etc:
  postgres.var:
  postgres.cmd:
  redis.etc:
  redis.var:

networks:
  frontend:
  backend:
    internal: true
```

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /netbox | home directory of user docker |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [4.3.3](https://hub.docker.com/r/11notes/netbox/tags?name=4.3.3)

### There is no latest tag, what am I supposed to do about updates?
It is of my opinion that the ```:latest``` tag is dangerous. Many times, I’ve introduced **breaking** changes to my images. This would have messed up everything for some people. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:4.3.3``` you can use ```:4``` or ```:4.3```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/netbox:4.3.3
docker pull ghcr.io/11notes/netbox:4.3.3
docker pull quay.io/11notes/netbox:4.3.3
```

# SOURCE 💾
* [11notes/netbox](https://github.com/11notes/docker-NETBOX)

# PARENT IMAGE 🏛️
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH 🧰
* [netbox](https://github.com/netbox-community/netbox)
* [11notes/util](https://github.com/11notes/docker-util)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-netbox/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-netbox/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-netbox/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 27.06.2025, 08:20:32 (CET)*
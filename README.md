![banner](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/banner/README.png)

# NETBOX
![size](https://img.shields.io/badge/image_size-1GB-green?color=%2338ad2d)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)![pulls](https://img.shields.io/docker/pulls/11notes/netbox?color=2b75d6)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)[<img src="https://img.shields.io/github/issues/11notes/docker-netbox?color=7842f5">](https://github.com/11notes/docker-netbox/issues)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

run netbox rootless

# SYNOPSIS 📖
**What can I do with this?** This image will give you a [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) Netbox installation.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image is auto updated to the latest version via CI/CD
>* ... this image is built and compiled from source
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | **size on disk** | **init default as** | **[distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)** | supported architectures
| ---: | ---: | :---: | :---: | :---: |
| 11notes/netbox | 1GB | 1000:1000 | ❌ | amd64, arm64, armv7 |
| netboxcommunity/netbox | 1GB | 0:0 | ❌ | amd64, arm64 |

# VOLUMES 📁
* **/netbox/etc** - Directory of the config.py
* **/netbox/var** - Directory of reports, uploads and scripts

# COMPOSE ✂️
```yaml
name: "netbox"

x-lockdown: &lockdown
  # prevents write access to the image itself
  read_only: true
  # prevents any process within the container to gain more privileges
  security_opt:
    - "no-new-privileges=true"

services:
  postgres:
    image: "11notes/postgres:18"
    <<: *lockdown
    environment:
      TZ: "Europe/Zurich"
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "5432:5432/tcp"
    networks:
      frontend:
    volumes:
      - "postgres.etc:/postgres/etc"
      - "postgres.var:/postgres/var"
    tmpfs:
      - "/postgres/run:uid=1000,gid=1000"
      - "/postgres/log:uid=1000,gid=1000"
    restart: "always"

  redis:
    image: "11notes/redis:8"
    <<: *lockdown
    environment:
      REDIS_PASSWORD: "${REDIS_PASSWORD}"
      TZ: "Europe/Zurich"
    networks:
      backend:
    volumes:
      - "redis.etc:/redis/etc"
      - "redis.var:/redis/var"
    tmpfs:
      - "/run:uid=1000,gid=1000"
    restart: "always"

  netbox:
    depends_on:
      postgres:
        condition: "service_healthy"
        restart: true
      redis:
        condition: "service_healthy"
        restart: true
    image: "11notes/netbox:4.7.4"
    <<: *lockdown
    environment:
      TZ: "Europe/Zurich"
      DB_PASSWORD: "${POSTGRES_PASSWORD}"
      REDIS_PASSWORD: "${REDIS_PASSWORD}"
      SECRET_KEY: "${SECRET_KEY}"
      API_TOKEN_PEPPER_1: "${API_TOKEN_PEPPER}"
      NETBOX_ADMIN: "admin"
      NETBOX_ADMIN_PASSWORD: ${NETBOX_ADMIN_PASSWORD}
    volumes:
      - "etc:/netbox/etc"
      - "var:/netbox/var"
    tmpfs:
      - "/run:uid=1000,gid=1000"
    ports:
      - "3000:8080/tcp"
    networks:
      frontend:
      backend:
    restart: "always"

volumes:
  etc:
  var:
  postgres.etc:
  postgres.var:
  redis.etc:
  redis.var:

networks:
  frontend:
  backend:
    internal: true
```
To find out how you can change the default UID/GID of this container image, consult the [RTFM](https://github.com/11notes/RTFM/blob/main/linux/container/image/11notes/how-to.changeUIDGID.md#change-uidgid-the-correct-way).

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

* [4.7.4](https://hub.docker.com/r/11notes/netbox/tags?name=4.7.4)

### There is no latest tag, what am I supposed to do about updates?
It is my opinion that the ```:latest``` tag is a bad habbit and should not be used at all. Many developers introduce **breaking changes** in new releases. This would messed up everything for people who use ```:latest```. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:4.7.4``` you can use ```:4``` or ```:4.7```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version. Which in theory should not introduce breaking changes.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/netbox:4.7.4
docker pull ghcr.io/11notes/netbox:4.7.4
docker pull quay.io/11notes/netbox:4.7.4
```

# SOURCE 💾
* [11notes/netbox](https://github.com/11notes/docker-netbox)

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

*created 06.11.2026, 10:18:05 (CET)*
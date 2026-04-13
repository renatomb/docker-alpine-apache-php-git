# docker-alpine-apache-php-git

Alpine-based image that ships Apache httpd, PHP (with a curated set of common modules) and Git so you can drop a PHP application in a container and immediately clone, serve, and update it. The image was created with “ship-it-to-the-client” scenarios in mind, where you need a reproducible stack that remains lightweight and easy to automate.

## Why this image?

- **Tiny and fast:** Alpine + Apache + PHP with no-frills defaults keeps the image small and boot times short.
- **Batteries included:** Pre-installs the most-used PHP extensions, Git, and OpenSSH tooling so you can `git clone` private repos on first boot.
- **Stateful when you need it:** Everything important lives under `/data`, making it trivial to persist sources, logs, and config on the host.
- **Helper tooling:** Small shell helpers (e.g., `genkey`, `fix-permission`, `error-log`) handle repetitive setup tasks inside the container.
- **Secure-by-context:** Intended for intranet deployments where you control the environment and need automation more than hardened defaults.

## Table of contents

1. [Prerequisites](#prerequisites)
2. [Quick start](#quick-start)
3. [Volume layout](#volume-layout)
4. [Helper commands](#helper-commands)
5. [Working with Git](#working-with-git)
6. [Installing extra packages](#installing-extra-packages)
7. [Docker Compose example](#docker-compose-example)
8. [Security considerations](#security-considerations)
9. [License](#license)
10. [Credits](#credits)

## Prerequisites

- [Docker] 20.10+ (or an equivalent compatible engine).
- Ability to reach [Docker Hub image][image] `renatomb/alpine-apache-php-git`.
- Optional: a Git repository (public or private) containing the PHP application you want to serve.

## Quick start

Pick a container name (`mywebapp`) and host port (`8888`) then launch the image. Two common workflows are shown below.

### Keep the code inside the container

```bash
docker run -d -p 8888:80 --name mywebapp renatomb/alpine-apache-php-git
```

### Persist the `/data` volume on the host

```bash
docker run -d \
  -p 8888:80 \
  -v "$(pwd)/data:/data" \
  --name mywebapp \
  renatomb/alpine-apache-php-git
```

Mounting `/data` lets you edit sources, inspect logs, or back up configuration directly from the host. Replace `$(pwd)/data` with any absolute path that suits your setup.

The first boot runs `setupvol`, generates SSH keys, and ensures `/data` is owned by the `apache` user before starting httpd in the foreground.

## Volume layout

Everything that matters is under `/data`, meaning a single bind mount (or Docker volume) keeps stateful pieces safe:

| Path (in container) | Typical contents | Host path when mounted |
| --- | --- | --- |
| `/data/localhost` | Virtual host roots (htdocs, etc.) | `…/data/localhost` |
| `/data/etc` | Apache configuration files | `…/data/etc` |
| `/data/log` | httpd logs (`access.log`, `error.log`, …) | `…/data/log` |
| `/data/ssh` | Shared SSH keypair + config | `…/data/ssh` |

The image rewires `/etc/apache2`, `/var/log/apache2`, `/var/www/.ssh`, and `/var/www/localhost` to symlink into `/data` so that Apache and your application always read/write from the persistent volume.

## Helper commands

Every helper lives in `/usr/local/bin` inside the container and is available via `docker exec mywebapp <command>`.

| Command | Purpose |
| --- | --- |
| `pubkey` | Prints (and ensures the existence of) the shared SSH public key located at `/data/ssh/id_ed25519.pub`. |
| `genkey [force|copy]` | Creates the SSH keypair if missing, optionally regenerates it (`force`) or copies it back to root’s home (`copy`). |
| `fix-permission` | Recursively sets `/data` ownership to the `apache` user/group; run after manipulating files as root. |
| `error-log` | Tails the current Apache `error.log` to your terminal. |
| `clear-log` | Truncates `error.log` if it has grown too large. |
| `install <apk packages…>` | Thin wrapper around `apk add --no-cache` for installing extra Alpine packages at runtime. |
| `start` | Internal bootstrapper that runs `setupvol`, `genkey`, and `fix-permission` before Apache starts. |

### SSH key management

Private repositories usually require the container to expose its public key:

```bash
# Show the current public key
docker exec mywebapp pubkey

# Regenerate (removes the old pair)
docker exec mywebapp genkey force

# Re-copy a host-edited key back to /root/.ssh
docker exec mywebapp genkey copy
```

## Working with Git

- The `apache` and `root` users share the same SSH keypair, so PHP code can call Git directly if needed.
- For initial deployments, it is often easiest to clone the application from the host via `docker exec`:

```bash
docker exec mywebapp git clone git@bitbucket.org:<user>/<repo>.git /data/localhost/htdocs
```

- When you clone as `root`, run `docker exec mywebapp fix-permission` afterward so Apache can read and write the files without permission issues.

## Installing extra packages

Need another PHP extension or system utility? Use the bundled helper (which delegates to `apk add`):

```bash
docker exec mywebapp install php-zip
```

For package names, refer to the [Alpine Packages][alpine-pkg] index.

## Docker Compose example

Minimal stack (web + MariaDB) using Compose:

```yaml
services:
  db:
    image: mariadb
    command: --default-authentication-plugin=mysql_native_password --sql_mode="" --lower_case_table_names=1
    restart: always
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: areallystrongpassword
    volumes:
      - ./mysql_data:/var/lib/mysql
      - ./mysql_import:/home/import
    networks:
      - websvcs

  websys:
    image: renatomb/alpine-apache-php-git:php8.3
    restart: always
    ports:
      - "80:80"
    volumes:
      - ./sistema/data:/data
      - ./sistema/conf:/etc/apache2/
    networks:
      - websvcs
    depends_on:
      - db

networks:
  websvcs:
```

Adjust the paths so they match your host layout. Copy `./sistema/conf` from a running container if you need to tweak Apache before committing changes back to version control.

## Security considerations

This image is designed for controlled networks (lab, intranet, on-site customer servers). Before exposing it to the public internet, review and harden the following defaults:

- SSH keys are generated without passphrases and stored under `/data/ssh`.
- The same SSH key is shared between `root` and `apache` for convenience.
- Strict host key checking is disabled for `github.com` and `bitbucket.org` to simplify unattended clones.
- Apache ships with the stock `httpd.conf` plus `AllowOverride All`; review modules, users, and TLS settings as needed.

Nothing prevents you from hardening these items—feel free to bake your own derivative image, swap the `setupvol` logic, or manage keys externally if you require stricter controls.

## Available Tags / PHP Versions

Please check [alpine-apache-php-git repository tags](https://hub.docker.com/repository/docker/renatomb/alpine-apache-php-git/tags) to see all available PHP versions.

## License

Do whatever you want.

## About the author

Renato Monteiro Batista is a Brazilian Computer Engineer, if you like this kind of project feel free to get in touch.

- [Github](https://github.com/renatomb)
- [Docker Hub](https://hub.docker.com/repositories/renatomb)
- [Links tree](https://r3n4t0.cyou)

## Credits

Inspired by [gliderlabs/alpine] and [httpd], standing on the shoulders of the [Alpine Linux][alpine] community.

[alpine]: http://alpinelinux.org/
[docker]: https://www.docker.com/get-started
[alpine-pkg]: https://pkgs.alpinelinux.org/packages
[gliderlabs/alpine]: https://hub.docker.com/r/gliderlabs/alpine/
[httpd]: https://hub.docker.com/_/httpd
[image]: http://hub.docker.com/r/renatomb/alpine-apache-php-git

# docker-alpine-apache-php-git

A lightweight infrastructure to run php web apps in a container. Based on  distro [Alpine Linux][alpine] projected to be a small size package to distribute your software.

## Use case

You're developing a web-based php software and want to deploy it at your customer without too much infrastructure setup. Just deploy what you need.

### How to deploy?

- Install [docker]
- Get [image] on docker hub
- Clone your software from git
- Or just fork it and adapt to your needs

### How does it works?
- It will install:
   - php-apache2
   - curl
   - php-cli
   - php-json
   - php-phar
   - php-openssl
   - php-mysqli
   - php7-session
   - php-curl
   - php-pdo
   - php-simplexml
   - php-gd
   - git
   - openssh-client
   - openssh-keygen
   - need additional package? check-out [Alpine Packages][alpine-pkg]
- A ssh key will be generated so you can clone private git repos
- Clone your desired git repo
- You're up and running

### Data
All relevant data will be stored on `/data` path. This allows you to persist your source code on host machine, or even keep your source-code inside containers without risk of unwanted access and modification.

# Usage
In all examples container will be refered as **mywebapp**, change to your desired name or refer to it using docker container ID, port will be refered as **8888**, change to whatever you need.

## Start
If you want to keep your source-code inside the container and out of sight of your user, execute:
```
docker run -d -p 8888:80 --name mywebapp renatomb/alpine-apache-php-git
```
If you want to persist your data outside docker, execute:
```
docker run -v /local/path:/data -d -p 8888:80 --name mywebapp renatomb/alpine-apache-php-git
```
Remember to change `/local/path` to your local path. If you want to save on current directory just replace it by `$(pwd)`.

## SSH Public Key
Public key will be necessary for clonning private git repositories. When you first start your container it will be automatically generated.

If you persist your data outside your container, your keys will be available in `/local/path/ssh` path, replace it if you need.

### Viewing your public key
If you're clonning private git repositories, you'll need to allow your container to access them, to do this you'll need to view your public ssh key. Just execute:
```
docker exec mywebapp pubkey
```

### Generating a new SSH Key
Whenever you need to generate a new ssh key, just execute (with container running):
```
docker exec mywebapp genkey force
```
Existing key will be removed and a new one will be generated.

### Replacing root's SSH key
If your replaced the SSH key outside docker changing files in `/local/path/ssh`, please replace it to root user using:
```
docker exec mywebapp genkey copy
```

## httpd

### Config files
Will be available at `/data/etc/` inside container or `/local/path/etc` outside it.

### Logs
Log files will be available at `/data/log` inside container or `/local/path/log` outside it.

You can also view your error.log using:
```
docker exec mywebapp error-log
```

Whenever you need to clear error.log, use:
```
docker exec mywebapp clear-log
```

### htdocs
Your data will be stored at `/data/localhost` inside container or `/local/path/localhost` outside it.

I recommend that you use git for any code changes.

## Using git
Apache has the same SSH key as root, so you can use git directly from your PHP code.

You can also use git directly from shell, mainly to make your initial clone. Just execute:

```
docker exec mywebapp git clone git@bitbucket.org:<yourUser>/<yourRep>.git
```

### Permissions
When you do git directly from shell, it will be executed as root. So you can have trouble with apache's permission to access your files. To solve it:
```
docker exec mywebapp fix-permission
```

## alpine packages
If you need to install additional [alpine packages][alpine-pkg] you can execute:
```
docker exec mywebapp install <packageName>
```

# Security

This software is designed for internal (intranet) use. Some security questions may have been undermine to make deployment easier. Please review some security questions before running it over internet:

- Generated SSH key is without password;
- Same SSH key is shared between root and apache user;
- Remote key verification disabled for hosts github.com and bitbucket.org;
- httpd.conf with default config;

NOTE: *As this image designed for internal use, those modifications allow you to run and update your software in an automated way. Sharing SSH key with apache also allows your software to call git directly from your PHP code.*

# License

Do whatever you want.

# Inspired by
This project was inspired by [gliderlabs/alpine] and [httpd].

[alpine]: http://alpinelinux.org/
[docker]: https://www.docker.com/get-started
[alpine-pkg]: https://pkgs.alpinelinux.org/packages
[gliderlabs/alpine]: https://hub.docker.com/r/gliderlabs/alpine/
[httpd]: https://hub.docker.com/_/httpd
[image]: http://hub.docker.com/r/renatomb/alpine-apache-php-git
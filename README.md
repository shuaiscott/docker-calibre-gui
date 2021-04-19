## Deprecated at Release
I just realized the guys at Linuxserver created a container where you can run calibre gui. Check them out [HERE](https://hub.docker.com/r/linuxserver/calibre)

## Usage

Here are some example snippets to help you get started creating a container.

### docker-compose ([recommended](https://docs.linuxserver.io/general/docker-compose))

Compatible with docker-compose v2 schemas.

```yaml
---
version: "2.1"
services:
  calibre-gui:
    image: ghcr.io/shuaiscott/calibre-gui
    container_name: calibre-gui
    environment:
      - USER_ID=1000
      - GROUP_ID=1000
      - TZ=Europe/London
    volumes:
      - </path/to/appdata/config>:/config
      - </path/to/book/library>:/library
      - </path/to/ingest>:/downloads
    ports:
      - 5800:5800
    restart: unless-stopped
```

### docker cli

```
docker run -d \
  --name=calibre-gui \
  -e USER_ID=1000 \
  -e GROUP_ID=1000 \
  -e TZ=Europe/London \
  -p 5800:5800 \
  -v </path/to/appdata/config>:/config \
  -v </path/to/book/library>:/library \
  -v </path/to/ingest>:/downloads \
  --restart unless-stopped \
  ghcr.io/shuaiscott/calibre-gui
```


## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 5800` | Application WebUI |
| `-e USER_ID=1000` | for UserID - see below for explanation |
| `-e GROUP_ID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London. |
| `-v /config` | Configuration files. |
| `-v /library` | Book library |
| `-v /downloads` | Non processed books |


## Environment Variables

Some environment variables can be set to customize the behavior of the container
and its application.  The following list give more details about them.

Environment variables can be set directly in your `Dockerfile` via the `ENV`
instruction or dynamically by adding one or more arguments `-e "<VAR>=<VALUE>"`
to the `docker run` command.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`APP_NAME`| Name of the application. | `DockerApp` |
|`USER_ID`| ID of the user the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`GROUP_ID`| ID of the group the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `1000` |
|`SUP_GROUP_IDS`| Comma-separated list of supplementary group IDs of the application. | (unset) |
|`UMASK`| Mask that controls how file permissions are set for newly created files. The value of the mask is in octal notation.  By default, this variable is not set and the default umask of `022` is used, meaning that newly created files are readable by everyone, but only writable by the owner. See the following online umask calculator: http://wintelguy.com/umask-calc.pl | (unset) |
|`TZ`| [TimeZone] of the container.  Timezone can also be set by mapping `/etc/localtime` between the host and the container. | `Etc/UTC` |
|`KEEP_APP_RUNNING`| When set to `1`, the application will be automatically restarted if it crashes or if a user quits it. | `0` |
|`APP_NICENESS`| Priority at which the application should run.  A niceness value of -20 is the highest priority and 19 is the lowest priority.  By default, niceness is not set, meaning that the default niceness of 0 is used.  **NOTE**: A negative niceness (priority increase) requires additional permissions.  In this case, the container should be run with the docker option `--cap-add=SYS_NICE`. | (unset) |
|`TAKE_CONFIG_OWNERSHIP`| When set to `1`, owner and group of `/config` (including all its files and subfolders) are automatically set during container startup to `USER_ID` and `GROUP_ID` respectively. | `1` |
|`CLEAN_TMP_DIR`| When set to `1`, all files in the `/tmp` directory are deleted during the container startup. | `1` |
|`DISPLAY_WIDTH`| Width (in pixels) of the application's window. | `1280` |
|`DISPLAY_HEIGHT`| Height (in pixels) of the application's window. | `768` |
|`SECURE_CONNECTION`| When set to `1`, an encrypted connection is used to access the application's GUI (either via a web browser or VNC client).  See the [Security](#security) section for more details. | `0` |
|`VNC_PASSWORD`| Password needed to connect to the application's GUI.  See the [VNC Password](#vnc-password) section for more details. | (unset) |
|`X11VNC_EXTRA_OPTS`| Extra options to pass to the x11vnc server running in the Docker container.  **WARNING**: For advanced users. Do not use unless you know what you are doing. | (unset) |
|`ENABLE_CJK_FONT`| When set to `1`, open-source computer font `WenQuanYi Zen Hei` is installed.  This font contains a large range of Chinese/Japanese/Korean characters. | `0` |

## Config Directory
Inside the container, the application's configuration should be stored in the
`/config` directory.

This directory is also used to store the VNC password.  See the
[VNC Pasword](#vnc-password) section for more details.

**NOTE**: By default, during the container startup, the user which runs the
application (i.e. user defined by `USER_ID`) will claim ownership of the
entire content of this directory.  This behavior can be changed via the
`TAKE_CONFIG_OWNERSHIP` environment variable.  See the
[Environment Variables](#environment-variables) section for more details.

## Ports

Here is the list of ports used by container.  They can be mapped to the host
via the `-p <HOST_PORT>:<CONTAINER_PORT>` parameter.  The port number inside the
container cannot be changed, but you are free to use any port on the host side.

| Port | Mapping to host | Description |
|------|-----------------|-------------|
| 5800 | Mandatory | Port used to access the application's GUI via the web interface. |
| 5900 | Optional | Port used to access the application's GUI via the VNC protocol.  Optional if no VNC client is used. |

## User/Group IDs

When using data volumes (`-v` flags), permissions issues can occur between the
host and the container.  For example, the user within the container may not
exists on the host.  This could prevent the host from properly accessing files
and folders on the shared volume.

To avoid any problem, you can specify the user the application should run as.

This is done by passing the user ID and group ID to the container via the
`USER_ID` and `GROUP_ID` environment variables.

To find the right IDs to use, issue the following command on the host, with the
user owning the data volume on the host:

    id <username>

Which gives an output like this one:
```
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom),27(sudo),46(plugdev),113(lpadmin)
```

The value of `uid` (user ID) and `gid` (group ID) are the ones that you should
be given the container.

## Locales
The default locale of the container is set to `POSIX`.  If this cause issues
with your application, the proper locale can be set via your `Dockerfile`, by adding these two lines:
```
ENV LANG=en_US.UTF-8
RUN locale-gen en_CA.UTF-8
```

**NOTE**: Locales are not supported by `musl` C standard library on `Alpine`.
See:
  * http://wiki.musl-libc.org/wiki/Open_Issues#C_locale_conformance
  * https://github.com/gliderlabs/docker-alpine/issues/144

## Accessing the GUI

Assuming that container's ports are mapped to the same host's ports, the
graphical interface of the application can be accessed via:

  * A web browser:
```
http://<HOST IP ADDR>:5800
```

  * Any VNC client:
```
<HOST IP ADDR>:5900
```

## Security

By default, access to the application's GUI is done over an unencrypted
connection (HTTP or VNC).

Secure connection can be enabled via the `SECURE_CONNECTION` environment
variable.  See the [Environment Variables](#environment-variables) section for
more details on how to set an environment variable.

When enabled, application's GUI is performed over an HTTPs connection when
accessed with a browser.  All HTTP accesses are automatically redirected to
HTTPs.

When using a VNC client, the VNC connection is performed over SSL.  Note that
few VNC clients support this method.  [SSVNC] is one of them.

### SSVNC

[SSVNC] is a VNC viewer that adds encryption security to VNC connections.

While the Linux version of [SSVNC] works well, the Windows version has some
issues.  At the time of writing, the latest version `1.0.30` is not functional,
as a connection fails with the following error:
```
ReadExact: Socket error while reading
```
However, for your convienence, an unoffical and working version is provided
here:

https://github.com/jlesage/docker-baseimage-gui/raw/master/tools/ssvnc_windows_only-1.0.30-r1.zip

The only difference with the offical package is that the bundled version of
`stunnel` has been upgraded to version `5.49`, which fixes the connection
problems.

### Certificates

Here are the certificate files needed by the container.  By default, when they
are missing, self-signed certificates are generated and used.  All files have
PEM encoded, x509 certificates.

| Container Path                  | Purpose                    | Content |
|---------------------------------|----------------------------|---------|
|`/config/certs/vnc-server.pem`   |VNC connection encryption.  |VNC server's private key and certificate, bundled with any root and intermediate certificates.|
|`/config/certs/web-privkey.pem`  |HTTPs connection encryption.|Web server's private key.|
|`/config/certs/web-fullchain.pem`|HTTPs connection encryption.|Web server's certificate, bundled with any root and intermediate certificates.|

**NOTE**: To prevent any certificate validity warnings/errors from the browser
or VNC client, make sure to supply your own valid certificates.

**NOTE**: Certificate files are monitored and relevant daemons are automatically
restarted when changes are detected.

### VNC Password

To restrict access to your application, a password can be specified.  This can
be done via two methods:
  * By using the `VNC_PASSWORD` environment variable.
  * By creating a `.vncpass_clear` file at the root of the `/config` volume.
    This file should contains the password in clear-text.  During the container
    startup, content of the file is obfuscated and moved to `.vncpass`.

The level of security provided by the VNC password depends on two things:
  * The type of communication channel (encrypted/unencrypted).
  * How secure access to the host is.

When using a VNC password, it is highly desirable to enable the secure
connection to prevent sending the password in clear over an unencrypted channel.

Access to the host by unexpected users with sufficient privileges can be
dangerous as they can retrieve the password with the following methods:
  * By looking at the `VNC_PASSWORD` environment variable value via the
    `docker inspect` command.  By defaut, the `docker` command can be run only
    by the root user.  However, it is possible to configure the system to allow
    the `docker` command to be run by any users part of a specific group.
  * By decrypting the `/config/.vncpass` file.  This requires the user to have
    the appropriate permission to read the file:  it has to be root or be the
    user defined by the `USER_ID` environment variable.  Also, to be able to
    retrieve the correct decryption key, one needs to know that the content of
    the file was generated by `x11vnc`.

### DH Parameters

Diffie-Hellman (DH) parameters define how the [DH key-exchange] is performed.
More details about this algorithm can be found on the [OpenSSL Wiki].

DH Parameters are saved into the PEM encoded file located inside the container
at `/config/certs/dhparam.pem`.  By default, when this file is missing, 2048
bits DH parameters are automatically generated.  Note that this one-time
operation takes some time to perform and increases the startup time of the
container.

[SSVNC]: http://www.karlrunge.com/x11vnc/ssvnc.html
[DH key-exchange]: https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange
[OpenSSL Wiki]: https://wiki.openssl.org/index.php/Diffie_Hellman

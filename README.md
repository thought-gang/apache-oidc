# apache-oidc

A Docker Image with an Apache HTTP Server with the OIDC module preinstalled

## Getting Started

In order to get some benefit out this container you will need to things:

* Content which you want to protect though OpenID Connect Authentcation
* A registration with an OpenID Connect Provider (Google, Azure, etc.).
  The OIDC provider will with three things:

    * A meta url with the confiuration details and keystore of the OIDC Provider
    * A ClientID to identify your application
    * A ClientSecret to authenticate your server against the OpenID Connect Provider

Additionally you will need a redirect url which serves to which the user is redirected after he
has successfully identified himslef at the OIDC Provider. There is now meaning to this 
addreess except that it must be on this server and it does not interfere with the content
you have wnat to share.

Lastly, you should seet an encryption password to secure the cookies to reidentify users during future 
request.

*Note:* The five settings mentioned above are the bare minimum got get started for any realistic use cases - especially limiting access to members of a certain domain - you should refer to the excellent  documentation of the [mod_auth_openidc module at GitHub](https://github.com/zmartzone/mod_auth_openidc)


### Usage

#### Running your container

For simple use cases you may want

```shell
docker run -e OIDC_REDIRECT_URL=http://localhost/login/redirect_uri \
           -e OIDC_CRYPTO_PASSPHRASE=<Your secret> \
           -e OIDC_PROVIDER_METADATA_URL=https://accounts.google.com/.well-known/openid-configuration \
           -e OIDC_CLIENT_ID=<Your ClientID> \
           -e OIDC_CRYPTO_PASSPHRASE=<Your ClientSecret> \
           -v /var/www/html:<web root directory> \
           -p 80:80 \
           thoughtgang/apache-oid:latest \
```

If you need a more fine grained control over hte configuration settings you may want to edit the  [auth_openidc.conf](auth_openidc.conf) and mount that in to the container:

```shell
docker run -v /etc/apache2/mods-available/auth_openidc.conf:<path to your auth_openidc.conf> \
           -v /var/www/html:<web root directory> \
           -p 80:80 \
           thoughtgang/apache-oid:latest \
```

Finally you may want to use this image as the basis for your own images with the following Dockerfile:

```
FROM thoughtgang/apache-oidc:latest

COPY <your content>  /var/www/html

ENV OIDC_REDIRECT_URL=http://<your server adress>/login/redirect_uri
ENV OIDC_CRYPTO_PASSPHRASE=<Your secret>
ENV OIDC_PROVIDER_METADATA_URL=https://accounts.google.com/.well-known/openid-configuration
ENV OIDC_CLIENT_ID=<Your ClientID>
ENV OIDC_CLIENT_SECRET=<Your ClientSecret>
```


### Environment Variables

#### Basic configuration

* `OIDC_REDIRECT_URL` - The redirect_uri for this OpenID Connect client; this is a vanity URL
that must ONLY point to a path on your server protected by this module
but it must NOT point to any actual content that needs to be served.
You can use a relative URL like /protected/redirect_uri if you want to
support multiple vhosts that belong to the same security domain in a dynamic way
* `OIDC_CRYPTO_PASSPHRASE` - Set a password for crypto purposes, this is used for:
  - encryption of the (temporary) state cookie
  - encryption of cache entries, that may include the session cookie, see: OIDCCacheEncrypt and OIDCSessionType

   Note that an encrypted cache mechanism can be shared between servers if they use the same OIDCCryptoPassphrase
If the value begins with exec: the resulting command will be executed and the
first line returned to standard output by the program will be used as the password.
The command may be absolute or relative to the web server root.

* `OIDC_PROVIDER_METADATA_URL` - URL where OpenID Connect Provider metadata can be found (e.g. https://accounts.google.com/.well-known/openid-configuration)
The obtained metadata will be cached and refreshed every 24 hours.
If set, individual entries below will not have to be configured but can be used to add
extra entries/endpoints to settings obtained from the metadata.
If OIDCProviderMetadataURL is not set, the entries below it will have to be configured for a single
static OP configuration or OIDCMetadataDir will have to be set for configuration of multiple OPs.

* `OIDC_CLIENT_ID` -  Client identifier used in calls to the OpenID Connect Provider.

* `OIDC_CLIENT_SECRET` - Client secret used in calls to the OpenID Connect Provider.

#### Advanged configuration

* `OIDC_SCOPE` - A space separated list of OIDC to request (e.g. ENV OIDC_SCOPE="openid profile email" would get you name and email associated with the login). Defaults to *openid*

* `OIDC_SESSION_TYPE` -  The OIDC session type (aka OIDCSessionType config value). 
> :warning: The default value is changed from `server-cache` to  `client-cookie` by default to facilitate the use in a cluster environment.

* `OIDC_SESSION_INACTIVITY_TIMEOUT` The value for the config parameter OIDCSessionInactivityTimeout. The default value is 300s aka 5 min.)

* `OIDC_SESSION_MAX_DURATION` The value for the config parameter OIDCSessionMaxDuration. The default value is 28800s aka 8 h.

#### Volumes

* `/var/www/html` - Root directory for the web server

#### Useful File Locations

* `/etc/apache2/mods-available/mode_openidc.conf` - Confiuration file for the OIDC module

## Find Us

* [GitHub](https://github.com/thought-gang/apache-oidc)
* [Docker.io](https://hub.docker.com/repository/docker/thoughtgang/apache-oidc)


## Authors

* **Felix Hoßfeld** - *Initial work* - [Thought Gang GmbH](https://www.thoughtgang.de/)

See also the list of [contributors](https://github.com/your/repository/contributors) who 
participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

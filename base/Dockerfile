FROM alpine:edge
MAINTAINER Winston H.

ENV SS_GIT_PATH="https://github.com/shadowsocks/shadowsocks-libev" \
    OBFS_GIT_PATH="https://github.com/shadowsocks/simple-obfs" 
# 设置中国时区
ENV TZ 'Asia/Shanghai'
RUN apk upgrade --no-cache \
    && apk add --no-cache bash tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo '${TZ}' > /etc/timezone \
    && rm -rf /var/cache/apk/*
# 导入edge最新源
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk --update --no-cache add supervisor sudo bash curl vim wget openssl openssh dbus nginx ca-certificates libcrypto1.1 libev libsodium mbedtls pcre c-ares \
php7-fpm php7-mcrypt php7-soap php7-openssl php7-gmp php7-pdo_odbc php7-json php7-dom php7-pdo php7-zip php7-mysqli php7-sqlite3 php7-apcu php7-pdo_pgsql php7-bcmath php7-gd php7-odbc php7-pdo_mysql php7-pdo_sqlite php7-gettext php7-xmlreader php7-xmlrpc php7-bz2 php7-memcached php7-iconv php7-pdo_dblib php7-curl php7-ctype php7-mbstring \
&& apk add --no-cache --virtual TMP git autoconf automake make build-base zlib-dev gettext-dev asciidoc xmlto libpcre32 libev-dev libsodium-dev libtool linux-headers mbedtls-dev openssl-dev pcre-dev c-ares-dev g++ gcc \
&& addgroup alpine \
&& adduser  -G alpine -s /bin/sh -D alpine \
&& echo "alpine:alpine" | /usr/sbin/chpasswd \
&& echo "alpine    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
# Install Shadowsocks + plugin
&& cd /tmp \
&& git clone ${SS_GIT_PATH} \
&& cd ${SS_GIT_PATH##*/} \
&& git submodule update --init --recursive \
&& ./autogen.sh \
&& ./configure --prefix=/usr && make \
&& make install \
&& cd /tmp \
&& plugin_VERSION=$(curl -s https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest | grep tag_name | awk  -F '"' '{print $4}') \
&& wget https://github.com/shadowsocks/v2ray-plugin/releases/download/$plugin_VERSION/v2ray-plugin-linux-amd64-$plugin_VERSION.tar.gz \
&& tar -xzvf v2ray-plugin-linux-amd64-*.tar.gz \
&& mv v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin \
&& apk del TMP \
&& rm -rf /tmp/* /var/cache/apk/* 

# 配置SSH
RUN sudo mkdir -p /var/run/sshd \
&& sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config \
&& sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config \
&& sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config \
&& sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config \
&& sed -i "s/#X11Forwarding no/X11Forwarding yes/g" /etc/ssh/sshd_config \
&& sed -i "s/#PermitUserEnvironment no/PermitUserEnvironment yes/g" /etc/ssh/sshd_config \
&& echo "ForwardX11Trusted yes" >> /etc/ssh/ssh_config
# 配置 PHP
ENV PHP_FPM_USER="www" \
    PHP_FPM_GROUP="www" \
    PHP_FPM_LISTEN_MODE="0660" \
    PHP_MEMORY_LIMIT="512M" \
    PHP_MAX_UPLOAD="50M" \
    PHP_MAX_FILE_UPLOAD="200" \
    PHP_MAX_POST="100M" \
    PHP_DISPLAY_ERRORS="On" \
    PHP_DISPLAY_STARTUP_ERRORS="On" \
    PHP_ERROR_REPORTING="E_COMPILE_ERROR\|E_RECOVERABLE_ERROR\|E_ERROR\|E_CORE_ERROR" \
    PHP_CGI_FIX_PATHINFO=0
RUN sed -i "s|;listen.owner\s*=\s*nobody|listen.owner = ${PHP_FPM_USER}|g" /etc/php7/php-fpm.conf && \
    sed -i "s|;listen.group\s*=\s*nobody|listen.group = ${PHP_FPM_GROUP}|g" /etc/php7/php-fpm.conf && \
    sed -i "s|;listen.mode\s*=\s*0660|listen.mode = ${PHP_FPM_LISTEN_MODE}|g" /etc/php7/php-fpm.conf && \
    sed -i "s|user\s*=\s*nobody|user = ${PHP_FPM_USER}|g" /etc/php7/php-fpm.conf && \
    sed -i "s|group\s*=\s*nobody|group = ${PHP_FPM_GROUP}|g" /etc/php7/php-fpm.conf && \
    sed -i "s|;log_level\s*=\s*notice|log_level = notice|g" /etc/php7/php-fpm.conf #uncommenting line
RUN sed -i "s|display_errors\s*=\s*Off|display_errors = ${PHP_DISPLAY_ERRORS}|i" /etc/php7/php.ini && \
    sed -i "s|display_startup_errors\s*=\s*Off|display_startup_errors = ${PHP_DISPLAY_STARTUP_ERRORS}|i" /etc/php7/php.ini && \
    sed -i "s|error_reporting\s*=\s*E_ALL & ~E_DEPRECATED & ~E_STRICT|error_reporting = ${PHP_ERROR_REPORTING}|i" /etc/php7/php.ini && \
    sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php7/php.ini && \
    sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${PHP_MAX_UPLOAD}|i" /etc/php7/php.ini && \
    sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php7/php.ini && \
    sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php7/php.ini && \
    sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= ${PHP_CGI_FIX_PATHINFO}|i" /etc/php7/php.ini && \
    sed -i "s|;*date.timezone =.*|date.timezone = ${TZ}|i" /etc/php7/php.ini #config timezone
# /etc/php7/php-fpm.conf
# /etc/php7/php.ini
# V2Ray
RUN mkdir -p /usr/bin/v2ray/ \
&& cd /tmp \
&& V2Ray_VERSION=$(curl -s https://api.github.com/repos/v2ray/v2ray-core/releases/latest | grep tag_name | awk  -F '"' '{print $4}') \
&& wget https://github.com/v2ray/v2ray-core/releases/download/$V2Ray_VERSION/v2ray-linux-64.zip \
&& unzip v2ray-linux-64.zip \
&& chmod +x v2ray v2ctl \
&& mv v2* /usr/bin/v2ray/ \
&& mv *.dat /usr/bin/v2ray/ \
&& rm -rf v2ray-linux-64.zip /tmp/* \
&& mkdir /var/log/v2ray/ \
&& mkdir -p /etc/v2ray \
&& mkdir -p /home/alpine/www

ADD etc /etc
ADD www /home/alpine/www
# 使用entrypoint.sh，便于定制自己的镜像
COPY entrypoint.sh /usr/sbin/entrypoint.sh
# 配置nginx
COPY default.conf /etc/nginx/conf.d/default.conf

WORKDIR /home/alpine
EXPOSE 80 22 4000/udp
USER alpine
ENTRYPOINT ["entrypoint.sh"]

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

# 使用entrypoint.sh，便于定制自己的镜像
COPY entrypoint.sh /usr/sbin/entrypoint.sh

# 配置SSH
RUN sudo mkdir -p /var/run/sshd \
&& sudo sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config \
&& sudo sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config \
&& sudo sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config \
&& sudo sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config \
&& sudo sed -i "s/#X11Forwarding no/X11Forwarding yes/g" /etc/ssh/sshd_config \
&& sudo sed -i "s/#PermitUserEnvironment no/PermitUserEnvironment yes/g" /etc/ssh/sshd_config \
&& sudo echo "ForwardX11Trusted yes" >> /etc/ssh/ssh_config
# 配置nginx
RUN mkdir -p /run/nginx
COPY nginx.conf /etc/nginx/nginx.conf
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
&& mkdir -p /etc/v2ray
ADD etc /etc

WORKDIR /home/alpine
EXPOSE 80 22
USER alpine
ENTRYPOINT ["entrypoint.sh"]

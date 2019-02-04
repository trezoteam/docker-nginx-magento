FROM debian:stretch-slim

RUN apt-get update && apt-get install wget make gcc -y \
    && NPS_VERSION=1.11.33.4 \
    && NGINX_VERSION=1.11.5 \
    && cd /opt \
    && apt-get install build-essential openssl geoip-database libgeoip-dev zlib1g-dev libpcre3 libpcre3-dev unzip libssl-dev -y \
    && wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip \
    && unzip release-${NPS_VERSION}-beta.zip \
    && mv incubator-pagespeed-ngx-release-${NPS_VERSION}-beta ngx_pagespeed-release-${NPS_VERSION}-beta/ \
    && cd ngx_pagespeed-release-${NPS_VERSION}-beta/ \
    && wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz \
    && tar -xzvf ${NPS_VERSION}.tar.gz \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -xvzf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION}/ \
    && ./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --pid-path=/var/run/nginx.pid --lock-path=/var/lock/nginx.lock --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/access.log --user=www-data --group=www-data --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --without-http_uwsgi_module --without-http_scgi_module --without-http_memcached_module --with-http_geoip_module --with-ipv6 --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_v2_module --add-module=/opt/ngx_pagespeed-release-${NPS_VERSION}-beta/ \
    && make \
    && make install \
    && mkdir /etc/nginx/sites-available/ \
    && mkdir /etc/nginx/sites-enabled/ \
    && mkdir /etc/nginx/conf.d/ 

RUN apt-get purge wget make gcc build-essential libgeoip-dev zlib1g-dev libpcre3-dev unzip libssl-dev -y --autoremove && rm -Rf /var/cache/* && rm -Rf /opt/*
RUN rm -Rf /etc/nginx/ && mkdir /etc/nginx && mkdir /etc/nginx/sites-enabled

COPY ./config /etc/nginx
COPY entrypoint.sh /entrypoint.sh

RUN groupadd http_group && useradd -m http_user -g http_group

CMD ["/entrypoint.sh"]

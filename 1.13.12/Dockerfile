FROM debian:stretch-slim 

ENV NPS_RELEASE_NUMBER="1.13.35.2"
ENV NPS_VERSION="1.13.35.2-stable"
ENV NGINX_VERSION="1.13.12"

# Set up variables and install dependencies
RUN apt-get update && apt-get install build-essential openssl geoip-database libgeoip-dev zlib1g-dev libpcre3 libpcre3-dev unzip libssl-dev uuid-dev wget -y 

# PAGESPEED/PSOL
RUN cd /tmp/ \
    && wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.zip \
    && unzip v${NPS_VERSION}.zip \
    && nps_dir=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d) \
    && cd "$nps_dir" \
    && psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz \
    && [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL) \
    && wget ${psol_url} \
    && tar -xzvf $(basename ${psol_url}) \
    \
    && cd /tmp/ \
    && wget https://github.com/openresty/headers-more-nginx-module/archive/v0.33.tar.gz \
    && tar -xvf v0.33.tar.gz \
    \
    && cd /tmp/ \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -xvzf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION}/ \
    && ./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --pid-path=/var/run/nginx.pid --lock-path=/var/lock/nginx.lock --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/access.log --user=www-data --group=www-data --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --without-http_uwsgi_module --without-http_scgi_module --without-http_memcached_module --with-http_geoip_module --with-ipv6 --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_v2_module --add-module=/tmp/$nps_dir ${PS_NGX_EXTRA_FLAGS}  --add-module=/tmp/headers-more-nginx-module-0.33/ \
    && make \
    && make install

# Clean up
RUN apt-get purge wget make gcc build-essential libgeoip-dev zlib1g-dev libpcre3-dev unzip libssl-dev -y --autoremove && rm -Rf /var/cache/* && rm -Rf /opt/* 
RUN rm -Rf /tmp/* /etc/nginx/ && mkdir /etc/nginx && mkdir /etc/nginx/sites-enabled 

COPY ./config /etc/nginx
COPY entrypoint.sh /entrypoint.sh

RUN groupadd http_group && useradd -m http_user -g http_group

CMD ["/entrypoint.sh"]

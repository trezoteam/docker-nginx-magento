#!/bin/bash
for store in $(tr '|' $'\n' <<< "$STORES") ; do
    domain="$(cut -f1 -d: <<< "$store")"
    mage_type="$(cut -f2 -d: <<< "$store")"
    mage_code="$(cut -f3 -d: <<< "$store")"
    server_root="$(cut -f4 -d: <<< "$store")"
    cp /etc/nginx/sites-available/{template,${domain}.conf}
    ln -s ../sites-available/${domain}.conf /etc/nginx/sites-enabled/
    sed -i "s/#REPLACE_SERVER_NAME/${domain}/g" /etc/nginx/sites-available/${domain}.conf
    sed -i "s/#REPLACE_MVERSION/${MVERSION}/g" /etc/nginx/sites-available/${domain}.conf
    sed -i "s!#REPLACE_SERVER_ROOT!${server_root}!g" /etc/nginx/sites-available/${domain}.conf
    if [ "$MVERSION" = "m2" ];then
        sed -i "s/\(\s*\)proxy_pass.*/\1proxy_pass http:\/\/varnish:6081;/g" /etc/nginx/sites-available/${domain}.conf
    fi
    if ! grep "${domain} ${mage_code};" /etc/nginx/conf.d/mage_code.conf ; then
    	sed -i "s/\(\s*\)#REPLACE_MAGE_CODE_MAPPING/\1#REPLACE_MAGE_CODE_MAPPING\n\1${domain} ${mage_code};/g" /etc/nginx/conf.d/mage_code.conf
    fi
    if ! grep "${domain} ${mage_type};" /etc/nginx/conf.d/mage_type.conf ; then
        sed -i "s/\(\s*\)#REPLACE_MAGE_TYPE_MAPPING/\1#REPLACE_MAGE_TYPE_MAPPING\n\1${domain} ${mage_type};/g" /etc/nginx/conf.d/mage_type.conf
    fi
done

# Take any server root from the config files
PROJECT_ROOT=$(grep -w root /etc/nginx/sites-enabled/ -R | head -n1 | grep -Po 'root\K[^;]*')
outsider_uid=$(ls -l $PROJECT_ROOT/composer.json | cut -f 3 -d ' ')
outsider_gid=$(ls -l $PROJECT_ROOT/composer.json | cut -f 4 -d ' ')

if [[ $outsider_uid =~ ^[0-9]*$ ]]; then
    usermod http_user -u $outsider_uid
fi

if [[ $outsider_gid =~ ^[0-9]*$ ]]; then
    usermod http_group -g $outsider_gid
fi

sed -i "s/#REPLACE_PHP_BACKEND_MAPPING/default php${PHP_VERSION/\./_}_backend;/g" /etc/nginx/conf.d/php-backend-mappings.conf #TODO: allow domain-specific mapping
sed -i "s/#REPLACE_PAGESPEED/$PAGESPEED/g" /etc/nginx/conf.d/pagespeed.conf

if nginx -t ; then
    exec nginx -g "daemon off;"
else
    echo "Nginx did not start, config issue?"
fi


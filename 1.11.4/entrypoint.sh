#!/bin/bash
MVERSION="m2"
PAGESPEED="off"
STORES='loja1.dominio.com.br:store:default:/var/www/html|loja2.dominio.com.br:store:default:/var/www/html'
for store in $(tr '|' $'\n' <<< "$STORES") ; do
    domain="$(cut -f1 -d: <<< "$store")"
    mage_type="$(cut -f2 -d: <<< "$store")"
    mage_code="$(cut -f3 -d: <<< "$store")"
    server_root="$(cut -f3 -d: <<< "$store")"
    cp /etc/nginx/sites-available/{template,${domain}.conf}
    ln -s ../sites-available/${domain}.conf /etc/nginx/sites-enabled/
    sed -i "s/#REPLACE_SERVER_NAME/${domain}/g" /etc/nginx/sites-available/${domain}.conf
    sed -i "s/#REPLACE_MVERSION/${MVERSION}/g" /etc/nginx/sites-available/${domain}.conf
    sed -i "s/#REPLACE_SERVER_ROOT/${server_root}/g" /etc/nginx/sites-available/${domain}.conf
    sed -i "s/\(\s*\)#REPLACE_MAGE_CODE_MAPPING/\1#REPLACE_MAGE_CODE_MAPPING\n\1${domain} ${mage_code};/g" /etc/nginx/conf.d/mage_code.conf
    sed -i "s/\(\s*\)#REPLACE_MAGE_TYPE_MAPPING/\1#REPLACE_MAGE_TYPE_MAPPING\n\1${domain} ${mage_type};/g" /etc/nginx/conf.d/mage_type.conf
done

sed -i "s/#REPLACE_PAGESPEED/$PAGESPEED/g" /etc/nginx/conf.d/pagespeed.conf

if nginx -t ; then
    exec nginx 
else
    echo "Nginx did not start, config issue?"
fi

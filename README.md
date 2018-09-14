# docker-nginx-magento
# Usage
Export the following environment variables (with either docker run or docker-compose):

```
MVERSION="m2" #Possible values: m1, m2
PAGESPEED="off" #Possible values: on, off
# A tad more complex, this variable should be a list of stores separated by pipe ('|'). 
# Each store should cotain the domain, type (store,view,etc.), code (default,etc.) and 
# path to code in filesystem separated by a colon (':')
STORES='loja1.dominio.com.br:store:default:/var/www/html|loja2.dominio.com.br:store:default:/var/www/html' 
```

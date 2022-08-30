
FROM ubuntu:20.04

RUN set -eux;  

RUN apt-get update -yq && \
    apt-get install -yq software-properties-common apt-utils nano zip 

RUN add-apt-repository ppa:ondrej/php \
   && apt-get update 

RUN echo " SE INSTALA gnupg ca-certificates git curl wget apt-transport-https dirmngr php7.2"
RUN apt-get  install -y \
    gnupg ca-certificates git curl wget apt-transport-https dirmngr php8.1 php8.1-cli php8.1-common\
    php8.1-xdebug php8.1-xml php8.1-yaml php8.1-zip php8.1-solr php8.1-soap php8.1-opcache \
    php8.1-mysql php8.1-mbstring php8.1-json php8.1-geoip php8.1-curl php8.1-pdo-mysql php8.1-ldap




#Instalo composer
RUN set -eux; \
	cd /tmp; \
	curl -sS https://getcomposer.org/installer | php; \
	mv composer.phar /usr/local/bin/composer

RUN apt-get update -yq \
    && apt-get  install -yq \
    && curl -L https://deb.nodesource.com/setup_lts.x | bash \
    && apt-get update -yq \
    && apt-get install -yq \
        nodejs



RUN set -eux; \
	{ \
    echo '<VirtualHost *:80>'; \
	echo '  ServerAdmin webmaster@localhost'; \
	echo '  ServerName wms.famiq.com.ar'; \
	echo '  ServerAlias wms.famiq.com.ar'; \
	echo '  DocumentRoot /var/www/html/public'; \
	echo '      <Directory "/var/www/html/public">'; \
	echo '  	    AllowOverride None'; \
	echo '  	    Order Allow,Deny'; \
	echo '  	    Allow from All'; \
	echo '  	    <IfModule mod_rewrite.c>'; \
	echo '  	    Options -MultiViews'; \
	echo '  	    RewriteEngine On'; \
	echo '			RewriteCond %{HTTP:Authorization} ^(.+)$'; \
	echo '			RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]'; \
	echo '  	    RewriteCond %{REQUEST_FILENAME} !-f'; \
	echo '  	    RewriteRule ^(.*)$ index.php [QSA,L]'; \
	echo '  	    </IfModule>'; \
	echo '      </Directory>'; \
	echo '  ErrorLog ${APACHE_LOG_DIR}/error.log'; \
	echo '  CustomLog ${APACHE_LOG_DIR}/access.log combined'; \
    echo '</VirtualHost>'; \
} > /etc/apache2/sites-available/wms-local.famiq.com.ar.conf



#configuracion de xdebug 

ARG XDEBUG_INI=/etc/php/7.2/apache2/conf.d/20-xdebug.ini

RUN echo "xdebug.mode = debug" >> ${XDEBUG_INI} \
    && echo "xdebug.start_with_request = yes" >> ${XDEBUG_INI} \
    && echo "xdebug.client_host = host.docker.internal" >> ${XDEBUG_INI} \
    && echo "xdebug.client_port = 9000" >> ${XDEBUG_INI}


RUN a2dissite 000-default.conf;\
 	a2ensite wms-local.famiq.com.ar ;\
 	a2enmod rewrite;

RUN update-rc.d apache2 defaults

RUN systemctl enable apache2

WORKDIR /var/www/html

# importante para que apache se ejecute en segundo plano. 
CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
LABEL description = "apache-php7.2 con composer y mysql pdo "
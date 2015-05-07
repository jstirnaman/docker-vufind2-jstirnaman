FROM ubuntu:latest
MAINTAINER Jason Stirnaman <stirnamanj@gmail.com>

EXPOSE 80 3306 8080 443

VOLUME ["/usr/local/vufind", "/opt/local/data"]

# Install additional packages and VuFind dependencies
RUN apt-get -y update
RUN apt-get check
RUN apt-get -y install \
    openjdk-7-jdk mysql-server-5.6 mysql-client-5.6 \
    apache2 \
    php5 php5-dev php-pear php5-json php5-ldap \
    php5-mcrypt php5-mysql php5-xsl php5-intl php5-gd

ENV VUFIND2_HTTPD_CONF="/usr/local/vufind/local/httpd-vufind.conf"
ENV VUFIND2_HTTPD_LINK="/etc/apache2/sites-enabled/httpd-vufind2.conf"
# Silence Jetty console on Ubuntu
ENV JETTY_CONSOLE=/dev/null
# add our user and group first to make sure their IDs get assigned consistently, regardless of other deps added later
RUN groupadd -r vufind \
  && useradd -r -g vufind vufind
RUN mkdir /var/log/vufind
RUN touch /var/log/vufind/vufind2.log
RUN chown -R vufind:www-data /usr/local/vufind /opt/local/data /var/log/vufind
RUN chmod -R g+wx /usr/local/vufind /opt/local/data /var/log/vufind

# config to enable .htaccess
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN a2enmod rewrite

RUN service mysql start
RUN service apache2 start

USER vufind
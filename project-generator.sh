#!/bin/bash

SCRIPTNAME=${0##*/}

function print_usage() {
    echo "Usage: $SCRIPTNAME <project name>"
}

## Check the number of arguments.
if [ $# -ne 1 ]; then
    print_usage
    exit 1
fi

source ~/.project_generator

mkdir ${PROJECT_BASE}/$1
mkdir ${PROJECT_BASE}/$1/logs
mkdir ${PROJECT_BASE}/$1/www
mkdir ${PROJECT_BASE}/$1/conf

echo "##### Creating directory for : $1 #####"

ls ${PROJECT_BASE}/$1 -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'

echo "##### Creating apache conf #####"

touch ${PROJECT_BASE}/$1/conf/apache.conf
echo "<VirtualHost *:80>" > ${PROJECT_BASE}/$1/conf/apache.conf
echo "	ServerName $1.dev" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "	ServerAdmin webmaster@localhost" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo " " >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "	DocumentRoot /projects/$1/www" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "	<Directory />" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "		Options FollowSymLinks" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "		AllowOverride None" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "	</Directory>" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "	<Directory /projects/$1/www/>" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "		Options Indexes FollowSymLinks MultiViews" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "		AllowOverride All" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "		Order allow,deny" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "		allow from all" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "	</Directory>" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo " " >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "	ErrorLog ${PROJECT_BASE}/$1/logs/error.log" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "	LogLevel warn" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "	CustomLog ${PROJECT_BASE}/$1/logs/access.log combined" >> ${PROJECT_BASE}/$1/conf/apache.conf
echo "</VirtualHost>" >> ${PROJECT_BASE}/$1/conf/apache.conf

cat ${PROJECT_BASE}/$1/conf/apache.conf

echo "Enable this site in Apache's configuration ? (y/n)"
  read ACCORD
if [[ ${ACCORD} == "y" ]]
then
 sudo ln -s ${PROJECT_BASE}/$1/conf/apache.conf /etc/apache2/sites-enabled/$1
 sudo /etc/init.d/apache2 restart
fi

echo "Create database $1 ? (y/n)"
  read ACCORD
if [[ ${ACCORD} == "y" ]]
then
 mysql -u ${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -e "CREATE DATABASE $1"
fi


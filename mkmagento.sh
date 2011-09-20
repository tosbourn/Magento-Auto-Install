#!/bin/bash

#Parameters you must pass in
username="$1"
password="$2"
magentoversion="$3"

#Variables you should change for your own setup
mysqlroot="EDITME" #eg Root
mysqlpassword="EDITME" #eg Password
userstore="EDITME" #eg /srv/www/

useradd -gwww-data -Gdevelopers -p$password -d/srv/www/$username -m $username

mkdir $userstore$username/public_html/
mkdir $userstore$username/logs/

chown -R $username:www-data $userstore$username/

echo "Set up a new user called $username with the password $password"

mysql -u$mysqlroot -p$mysqlpassword <<EOMYSQL
CREATE DATABASE $username;
CREATE USER $username;
GRANT ALL ON $username.* TO '$username' IDENTIFIED BY '$password';
exit
EOMYSQL

echo "Created database ($username) for $username with the password $password"

cd $userstore$username/public_html/

echo "About to download Magento version $magentoversion - this could take a while"

wget http://www.magentocommerce.com/downloads/assets/$magentoversion/magento-$magentoversion.tar.gz

tar -zxvf magento-$magentoversion.tar.gz
mv magento/* magento/.htaccess .
chmod -R 777 var var/.htaccess app/etc media
chown -R $username:www-data app/etc/ var/ media/
rm -rf downloader/pearlib/cache/* downloader/pearlib/download/*
rm -rf magento/ magento-$magentoversion.tar.gz

echo "Done - Remember to set up the appropriate hosts file and DNS settings, I cannae help you there."

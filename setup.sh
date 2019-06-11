#####################################################################################################
#																			  						#
# 	Copyright (C) 1 Click Services LTD - All Rights Reserved 				  						#
# 	Unauthorized copying of this file, via any medium is strictly prohibited  						#
# 	Proprietary and confidential											  						#
#																									#
#	PROJECT:		Outbound Mail Cluster															#
# 	FILE:			setup.sh																		#
#	DESCRIPTION:	Host Automated Setup Script														#
#																									#
#	VERSION:		0.1.1																			#
#	AUTHOR:			Daniel McGiff <daniel.mcgiff@1clickcloud.net>									#
#	DATE:			23rd May 2019																	#
#	UPDATED:		10th June 2019																	#
#																									#
#####################################################################################################

#Download and Extract MailScanner
wget https://s3.amazonaws.com/msv5/release/MailScanner-5.1.3-2.deb.tar.gz
tar -xvf MailScanner-5.1.3-2.deb.tar.gz
cd MailScanner-5.1.3-2/

#Run MailScanner Install Script
./install.sh

#install opendkim
apt-get install opendkim opendkim-tools

#add dkimsync user
adduser --disabled-password --gecos "" dkimsync

#create and set permissions on DKIM directories
mkdir /var/dkim
mkdir /var/dkim/private

chmod 750 /var/dkim/gen_dkim_tables 
chmod 750 /var/dkim/private

cp /opt/outbound-mail/gen_dkim_tables /var/dkim/

chown -R dkimsync:dkimsync /var/dkim

#install HTTPS transport, lsb and ca-certificates
apt-get -y install apt-transport-https lsb-release ca-certificates

#setup Sury Repos for PHP
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

#install Apache, PHP and Dependencies
apt-get update
apt-get install php7.3 apache2 php7.3-mysqli php7.3-gd php7.3-mbstring php7.3-curl php7.3-ldap php7.3-xml libgcrypt11-dev zlib1g-dev dnsutils

#clone MailWatch repo
mkdir /opt/mailwatch
cd /opt/mailwatch
git clone --depth=1 https://github.com/mailwatch/MailWatch.git --branch 1.2 --single-branch .

#Copy MailWatchConf into place

cp /opt/outbound-mail/MailWatchConf.pm /usr/share/MailScanner/perl/custom/

#Add SymLinks for other MailScanner scripts

ln -s /opt/mailwatch/MailScanner_perl_scripts/MailWatch.pm /usr/share/MailScanner/perl/custom
ln -s /opt/mailwatch/MailScanner_perl_scripts/SQLBlackWhiteList.pm /usr/share/MailScanner/perl/custom
ln -s /opt/mailwatch/MailScanner_perl_scripts/SQLSpamSettings.pm /usr/share/MailScanner/perl/custom

#Install FixLatin Perl Module

cpan App::cpanminus
cpanm Encoding::FixLatin

#copy conf.php into place
cp /opt/outbound-mail/conf.php /opt/mailwatch/mailscanner/

#run upgrade.php
php /opt/mailwatch/upgrade.php

#copy apache configuration into place
cp /opt/outbound-mail/apache.conf /etc/apache2/sites-enabled/000-default.conf

#create Apache Log Directory
mkdir /var/log/apache2/mailwatch

#copy MailScanner configs into place
cp /opt/outbound-mail/MailScanner.conf /etc/MailScanner/MailScanner.conf
cp /opt/outbound-mail/MailScanner.defaults /etc/MailScanner/defaults
cp /opt/outbound-mail/spamassassin.conf /etc/MailScanner/spamassassin.conf

#generate bayesian data and set permissions
mkdir /etc/MailScanner/bayes
chown root:www-data /etc/MailScanner/bayes
chmod g+rws /etc/MailScanner/bayes
sa-learn --sync
chown root:www-data /etc/MailScanner/bayes/bayes_*
chmod g+rw /etc/MailScanner/bayes/bayes_*

#copy opendkim configs into place
cp /opt/outbound-mail/opendkim.conf /etc/opendkim.conf
cp /opt/outbound-mail/opendkim.default /etc/default/opendkim
cp /opt/outbound-mail/TrustedHosts /var/dkim/TrustedHosts

#copy postfix config into place
cp /opt/outbound-mail/main.cf /etc/postfix/main.cf
cp /opt/outbound-mail/header_checks /etc/postfix/header_checks

#set permissions on mail queues
chown postfix:mtagroup /var/spool/MailScanner/incoming
chown postfix:mtagroup /var/spool/MailScanner/ramdisk_store
chown postfix:postfix /var/spool/postfix/hold
chown postfix:postfix /var/spool/postfix/incoming
chmod 777 /var/spool/postfix/hold
chmod 777 /var/spool/postfix/incoming

#setup Adding of Postfix relay information to message detail
cp tools/Postfix_relay/mailwatch-postfix-relay /etc/cron.hourly
chmod +x /etc/cron.hourly/mailwatch-postfix-relay
cp tools/Postfix_relay/mailwatch_postfix_relay.php /usr/local/bin
cp tools/Postfix_relay/mailwatch_mailscanner_relay.php /usr/local/bin
chmod +x /usr/local/bin/mailwatch_postfix_relay.php
chmod +x /usr/local/bin/mailwatch_mailscanner_relay.php

#enable mod_rewrite
a2enmod rewrite
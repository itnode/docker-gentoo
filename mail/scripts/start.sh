#!/bin/bash

# Set default env vars
if [ -z "$MAIL_HOSTNAME" ]; then
 MAIL_HOSTNAME="mail"
fi
if [ -z "$MAIL_HOSTNAME_FQDN" ]; then
  MAIL_HOSTNAME_FQDN="mail.example.com"
fi
if [ -z "$POSTMASTER_ADDRESS" ]; then
  POSTMASTER_ADDRESS="postmaster@example.com"
fi

sed -i -e "s/%MAIL_HOSTNAME%/$MAIL_HOSTNAME/g" /etc/postfix/main.cf
sed -i -e "s/%MAIL_HOSTNAME_FQDN%/$MAIL_HOSTNAME_FQDN/g" /etc/postfix/main.cf
sed -i -e "s/%MAIL_HOSTNAME_FQDN%/$MAIL_HOSTNAME_FQDN/g" /etc/opendkim/TrustedHosts
sed -i -e "s/%POSTMASTER_ADDRESS%/$POSTMASTER_ADDRESS/g" /etc/dovecot/dovecot.conf

if [ ! -e /etc/ssl/mailcerts/.ssl-generated ]; then
	openssl genrsa -des3 -passout pass:x -out /etc/ssl/mailcerts/mail.pass.key 2048 && \
	openssl rsa -passin pass:x -in /etc/ssl/mailcerts/mail.pass.key -out /etc/ssl/mailcerts/mail.key
	rm /etc/ssl/mailcerts/mail.pass.key
	openssl req -new -key /etc/ssl/mailcerts/mail.key -out /etc/ssl/mailcerts/mail.csr \
	  -subj "/C=UK/ST=England/L=London/O=OrgName/OU=IT Department/CN=$MAIL_HOSTNAME_FQDN"
	openssl x509 -req -days 365 -in /etc/ssl/mailcerts/mail.csr -signkey /etc/ssl/mailcerts/mail.key -out /etc/ssl/mailcerts/mail_chained.crt
	echo "Do not remove this file." > /etc/ssl/mailcerts/.ssl-generated
fi

if [ ! -e /etc/opendkim/keys/.default-generated ]; then
	#opendkim-default-keygen
    echo "Do not remove this file." > /etc/opendkim/.default-generated
fi

# Again set the right permissions (needed when mounting from a volume)
chown -Rf vmail:vmail /var/vmail/

# Postmap intitial config files for postfix so it doesn't whine.
touch /etc/vmail/aliases /etc/vmail/domains /etc/vmail/mailboxes /etc/vmail/passwd
postmap /etc/vmail/aliases && postmap /etc/vmail/domains && postmap /etc/vmail/mailboxes

# Start our services
/usr/sbin/rsyslogd -f /etc/rsyslog.conf
/usr/sbin/opendkim -x /etc/opendkim.conf
/usr/sbin/dovecot -c /etc/dovecot/dovecot.conf
/usr/sbin/postfix -c /etc/postfix start
/bin/bash

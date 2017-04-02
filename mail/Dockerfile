FROM hub.gassmann.it/docker/gentoo

MAINTAINER Jens Gassmann 

# By default, UTC system
RUN echo 'UTC' > /etc/timezone && \
echo 'EMERGE_DEFAULT_OPTS="--autounmask-write"' >> /etc/portage/make.conf && \
echo 'MAKEOPTS="-j9"'       >> /etc/portage/make.conf && \
echo 'CONFIG_PROTECT="-*"'  >> /etc/portage/make.conf 

RUN USE="bzip2  maildir managesieve sieve ssl tcpd zlib" emerge dovecot
RUN USE="-bindist" emerge openssl openssh
RUN emerge opendkim 
RUN emerge rsyslog 
RUN emerge daemontools 
RUN emerge opensmtpd 

# Make some folders & users & stuff
RUN groupadd vmail -g 2222
RUN useradd vmail -d /var/vmail -M -s /usr/sbin/nologin -g 2222 -u 2222 && \
mkdir -m 0755 /etc/ssl/mailcerts && \
mkdir -m 0755 /etc/vmail && \
mkdir -m 0751 /var/vmail && \
chown vmail:vmail /var/vmail

# Dovecot config
RUN rm /etc/dovecot/dovecot.conf /etc/dovecot/conf.d/*
ADD conf/dovecot.conf /etc/dovecot/dovecot.conf
ADD conf/15-lda.conf /etc/dovecot/conf.d/15-lda.conf
ADD conf/20-managesieve.conf /etc/dovecot/conf.d/20-managesieve.conf
ADD conf/90-sieve-extprograms.conf /etc/dovecot/conf.d/90-sieve-extprograms.conf
ADD conf/90-sieve.conf /etc/dovecot/conf.d/90-sieve.conf

# Opensmtpd config
ADD conf/smtpd.conf /etc/smtpd.conf

# OpenDKIM config
ADD conf/opendkim.conf /etc/opendkim.conf
ADD conf/TrustedHosts /etc/opendkim/TrustedHosts

# rsyslog config
RUN rm /etc/rsyslog.conf /etc/rsyslog.d/*
ADD conf/rsyslog.conf /etc/rsyslog.conf

# Service-Config 
ADD service/ /service/

# Setup Volume
VOLUME ["/var/vmail"]
VOLUME ["/etc/vmail"]
VOLUME ["/etc/ssl/mailcerts"]

# Expose Ports
EXPOSE 465
EXPOSE 25
EXPOSE 587
EXPOSE 993
EXPOSE 143
EXPOSE 110
EXPOSE 995

CMD /usr/bin/svscan /service



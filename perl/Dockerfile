FROM hub.gassmann.it/gentoo

MAINTAINER Jens Gassmann 

# By default, UTC system
RUN echo 'UTC' > /etc/timezone && \
echo "MY_DATADIR=/database" >> /etc/portage/make.conf && \
echo 'EMERGE_DEFAULT_OPTS="--autounmask-write"' >> /etc/portage/make.conf && \
echo 'MAKEOPTS="-j9"'       >> /etc/portage/make.conf && \
echo 'CONFIG_PROTECT="-*"'  >> /etc/portage/make.conf 

RUN emerge-webrsync && emerge portage && emerge -uD world && rm -rf /usr/portage 

#RUN emerge daemontools flaggie dev-vcs/git vim 

RUN mkdir /root/.ssh/
ADD ../../id_rsa /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts

RUN chown 0600 /root/.ssh/id_rsa

ENV PERLBREW_ROOT=/opt/perl5

RUN bash -c '\wget -O - http://install.perlbrew.pl | bash'
RUN /opt/perl5/bin/perlbrew init
RUN /opt/perl5/bin/perlbrew install -j 4 -n  --noman perl-5.24.0
RUN /opt/perl5/bin/perlbrew install-cpanm
RUN /opt/perl5/bin/perlbrew switch perl-5.24.0
ENV PERLBREW_ROOT=/opt/perl5
ENV PATH=/opt/perl5/bin:/opt/perl5/perls/perl-5.24.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PERLBREW_PERL=perl-5.24.0
ENV PERLBREW_VERSION=0.76
ENV PERLBREW_MANPATH=/opt/perl5/perls/perl-5.24.0/man
ENV PERLBREW_PATH=/opt/perl5/bin:/opt/perl5/perls/perl-5.24.0/bin
ENV PERLBREW_SKIP_INIT=1

RUN ssh-keyscan gitlab.itnode.de >> /root/.ssh/known_hosts

CMD /usr/bin/svscan /service





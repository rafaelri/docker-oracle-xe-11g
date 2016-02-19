FROM ubuntu:14.04.1

MAINTAINER Rafael Ribeiro <rafaelri@gmail.com>

EXPOSE 1521
EXPOSE 8080

ENV DEBIAN_FRONTEND=noninteractive

ADD setup /setup

RUN apt-get install -y libaio1 net-tools bc curl \
  && cp /setup/chkconfig /sbin/chkconfig && chmod 755 /sbin/chkconfig \
  && ln -s /usr/bin/awk /bin/awk \
  && mkdir /var/lock/subsys && mkdir /docker-entrypoint-initdb.d \
  && curl https://raw.githubusercontent.com/rafaelri/docker-oracle-xe-11g/master/assets/oracle-xe_11.2.0-1.0_amd64.debaa \
     -o /tmp/oracle-xe_11.2.0-1.0_amd64.debaa \
  && curl https://raw.githubusercontent.com/rafaelri/docker-oracle-xe-11g/master/assets/oracle-xe_11.2.0-1.0_amd64.debab \
     -o /tmp/oracle-xe_11.2.0-1.0_amd64.debab \
  && curl https://raw.githubusercontent.com/rafaelri/docker-oracle-xe-11g/master/assets/oracle-xe_11.2.0-1.0_amd64.debac \
     -o /tmp/oracle-xe_11.2.0-1.0_amd64.debac \
  && cat /tmp/oracle-xe_11.2.0-1.0_amd64.deba* > /tmp/oracle-xe_11.2.0-1.0_amd64.deb \
  && dpkg --install /tmp/oracle-xe_11.2.0-1.0_amd64.deb \
  && rm -rf /tmp/oracle-xe_11.2.0-1.0_amd64.deb* \
  && apt-get remove -y --purge curl libcurl3 ca-certificates \
  && apt-get clean

ADD post-setup /post-setup

ENV ORACLE_BASE=/u01/app/oracle
ENV ORACLE_HOME=$ORACLE_BASE/product/11.2.0/xe
ENV SQLPLUS=$ORACLE_HOME/bin/sqlplus
ENV LSNR=$ORACLE_HOME/bin/lsnrctl
ENV ORACLE_SID=XE
ENV LISTENERS_ORA=$ORACLE_HOME/network/admin/listener.ora
ENV TEMPLATE_LISTENERS_ORA=$LISTENERS_ORA.tmpl
ENV TEMPLATEDIR=/u01/template/oracle
ENV HOME_TEMPLATEDIR=$TEMPLATEDIR/product/11.2.0/xe
ENV DATADIR=/var/lib/oracle
ENV HOME_DATADIR=$DATADIR/product/11.2.0/xe

RUN mkdir $DATADIR \
  && mkdir -p $HOME_TEMPLATEDIR \
  && cp $LISTENERS_ORA $TEMPLATE_LISTENERS_ORA \
  && mkdir -p $DATADIR/etc/default \
  && cp /post-setup/etc-oratab /etc/oratab \
  && cp /post-setup/etc-default-oracle-xe /etc/default/oracle-xe \
  && cp /post-setup/*.ora $ORACLE_HOME/config/scripts \
  && mv $ORACLE_HOME/config $HOME_TEMPLATEDIR/config \
  && mv $ORACLE_HOME/dbs $HOME_TEMPLATEDIR/dbs \
  && mkdir $HOME_TEMPLATEDIR/network \
  && mv $ORACLE_HOME/network/admin $HOME_TEMPLATEDIR/network/admin \
  && ln -s $HOME_DATADIR/config $ORACLE_HOME/config \
  && ln -s $HOME_DATADIR/dbs $ORACLE_HOME/dbs \
  && ln -s $HOME_DATADIR/log $ORACLE_HOME/log \
  && ln -s $HOME_DATADIR/network/admin $ORACLE_HOME/network/admin \
  && ln -s $DATADIR/admin $ORACLE_BASE/admin \
  && ln -s $DATADIR/diag $ORACLE_BASE/diag \
  && ln -s $DATADIR/fast_recovery_area $ORACLE_BASE/fast_recovery_area \
  && ln -s $DATADIR/oradata $ORACLE_BASE/oradata \
  && ln -s $DATADIR/oradiag_oracle $ORACLE_HOME/oradiag_oracle \
  && chown -R oracle:dba /var/lib/oracle

VOLUME $DATADIR

COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "oracle-xe" ]

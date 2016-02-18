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
ENV DATADIR=/var/lib/oracle

RUN mkdir $DATADIR \
  && mkdir -p $DATADIR/admin \
	&& mkdir -p $DATADIR/diag \
	&& mkdir -p $DATADIR/fast_recovery_area \
	&& mkdir -p $DATADIR/oradata \
	&& mkdir -p $DATADIR/oradiag_oracle \
	&& mkdir -p $DATADIR/product/11.2.0/xe/dbs \
	&& mkdir -p $DATADIR/product/11.2.0/xe/log \
	&& mkdir -p $DATADIR/product/11.2.0/xe/network \
  && mkdir -p $DATADIR/product/11.2.0/xe/network \
	&& chown -R oracle:dba /var/lib/oracle \
  && ln -s $DATADIR/admin /u01/app/oracle/admin \
  && ln -s $DATADIR/oracle-xe /etc/default/oracle-xe \
  && ln -s $DATADIR/diag /u01/app/oracle/diag \
  && ln -s $DATADIR/fast_recovery_area /u01/app/oracle/fast_recovery_area \
  && ln -s $DATADIR/oradata /u01/app/oracle/oradata \
  && ln -s $DATADIR/oradiag_oracle /u01/app/oracle/oradiag_oracle \
  && ln -s $DATADIR/product/11.2.0/xe/dbs /u01/app/oracle/product/11.2.0/xe/dbs \
  && ln -s $DATADIR/product/11.2.0/xe/log /u01/app/oracle/product/11.2.0/xe/log \
  && ln -s $DATADIR/product/11.2.0/xe/network/admin /u01/app/oracle/product/11.2.0/xe/network/admin \
  && ln -s $DATADIR/product/11.2.0/xe/config /u01/app/oracle/product/11.2.0/xe/config \
  && cp $LISTENERS_ORA $TEMPLATE_LISTENERS_ORA

VOLUME $DATADIR

COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "oracle-xe" ]

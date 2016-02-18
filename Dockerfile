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

ENV ORACLE_BASE=/u01/app/oracle
ENV ORACLE_HOME=$ORACLE_BASE/product/11.2.0/xe
ENV SQLPLUS=$ORACLE_HOME/bin/sqlplus
ENV LSNR=$ORACLE_HOME/bin/lsnrctl
ENV ORACLE_SID=XE
ENV DATA_DIR=/var/lib/oracle
ENV LISTENERS_ORA=$ORACLE_HOME/network/admin/listener.ora

RUN cp /setup/etc-default-oracle-xe /etc/default/oracle-xe \
  && sed -i "s|/u01/app/oracle/admin|/var/lib/oracle/admin|g" $ORACLE_HOME/config/scripts/XE.sh \
  && sed -i "s|/u01/app/oracle/fast_recovery_area|/var/lib/oracle/fast_recovery_area|g" $ORACLE_HOME/config/scripts/XE.sh \
  && sed -i "s|/u01/app/oracle/oradata|/var/lib/oracle/oradata|g" "$ORACLE_HOME/config/scripts/XE.sh" \
  && sed -i "s|/u01/app/oracle/oradata|/var/lib/oracle/oradata|g" "$ORACLE_HOME/config/scripts/rmanRestoreDatafiles.sql" \
  && sed -i "s|/u01/app/oracle/oradata|/var/lib/oracle/oradata|g" "$ORACLE_HOME/config/scripts/cloneDBCreation.sql" \
  && mkdir -p /u01/app/oracle/product/11.2.0/xe/log] [/u01/app/oracle/product/11.2.0/xe/log/diag/clients \
  && chown -R oracle:dba /u01/app/oracle/product/11.2.0/xe/log] [/u01/app/oracle/product/11.2.0/xe/log \
  && cp /setup/*.ora /u01/app/oracle/product/11.2.0/xe/config/scripts \
  && mkdir $DATA_DIR

VOLUME $DATA_DIR

COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "oracle-xe" ]

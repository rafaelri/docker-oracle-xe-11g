FROM ubuntu:14.04.1

MAINTAINER Rafael Ribeiro <rafaelri@gmail.com>

EXPOSE 1521
EXPOSE 8080

ENV ORACLE_BASE=/u01/app/oracle
ENV ORACLE_HOME=$ORACLE_BASE/product/11.2.0/xe
ENV SQLPLUS=$ORACLE_HOME/bin/sqlplus
ENV ORACLE_SID=XE

ENV DEBIAN_FRONTEND=noninteractive

ENV DATA_DIR=$ORACLE_BASE/data

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
  && apt-get clean \
  && mkdir -p $DATA_DIR/admin && mkdir -p $DATA_DIR/diag \
  && mkdir -p $DATA_DIR/fast_recovery_area && mkdir -p $DATA_DIR/oradata \
  && mkdir -p $DATA_DIR/oradiag_oracle && mkdir -p $DATA_DIR/product/11.2.0/xe/dbs \
  && mkdir -p $DATA_DIR/product/11.2.0/xe/log && mkdir -p $DATA_DIR/product/11.2.0/xe/network \
  && chown -R oracle:dba $DATA_DIR \
  && mv /u01/app/oracle/product/11.2.0/xe/network/admin $DATA_DIR/product/11.2.0/xe/network/admin \
  && mv /u01/app/oracle/product/11.2.0/xe/config $DATA_DIR/product/11.2.0/xe/config \
  && ln -s $DATA_DIR/admin /u01/app/oracle/admin && ln -s /u01/app/oracle/data/diag /u01/app/oracle/diag \
  && ln -s $DATA_DIR/fast_recovery_area /u01/app/oracle/fast_recovery_area \
  && ln -s $DATA_DIR/oradata /u01/app/oracle/oradata \
  && ln -s $DATA_DIR/oradiag_oracle /u01/app/oracle/oradiag_oracle \
  && ln -s $DATA_DIR/product/11.2.0/xe/dbs /u01/app/oracle/product/11.2.0/xe/dbs \
  && ln -s $DATA_DIR/product/11.2.0/xe/log /u01/app/oracle/product/11.2.0/xe/log \
  && ln -s $DATA_DIR/product/11.2.0/xe/network/admin /u01/app/oracle/product/11.2.0/xe/network/admin \
  && ln -s $DATA_DIR/product/11.2.0/xe/config /u01/app/oracle/product/11.2.0/xe/config \
  && cp /setup/init.ora /u01/app/oracle/product/11.2.0/xe/config/scripts \
  && cp /setup/initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts

VOLUME /u01/app/oracle/data


COPY docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "oracle-xe" ]

ONBUILD RUN echo "ORACLE_LISTENER_PORT=1521" > /tmp/XE.rsp \
	        && echo "ORACLE_HTTP_PORT=8080" >> /tmp/XE.rsp \
	        && echo "ORACLE_PASSWORD=${ORACLE_PASSWORD-manager}" >> /tmp/XE.rsp \
	        && echo "ORACLE_CONFIRM_PASSWORD=${ORACLE_PASSWORD-manager}" >> /tmp/XE.rsp \
	        && echo "ORACLE_DBENABLE=y" >> /tmp/XE.rsp \
          && /etc/init.d/oracle-xe configure responseFile=/setup/XE.rsp

FROM ubuntu:14.04.1

MAINTAINER Rafael Ribeiro <rafaelri@gmail.com>

ADD assets /assets

RUN (export DEBIAN_FRONTEND=noninteractive; apt-get install -y libaio1 net-tools bc)

RUN cp /assets/chkconfig /sbin/chkconfig && chmod 755 /sbin/chkconfig && ln -s /usr/bin/awk /bin/awk \
  && mkdir /var/lock/subsys && mkdir /docker-entrypoint-initdb.d \
  && cat /assets/oracle-xe_11.2.0-1.0_amd64.deba* > /assets/oracle-xe_11.2.0-1.0_amd64.deb

RUN (export DEBIAN_FRONTEND=noninteractive; dpkg --install /assets/oracle-xe_11.2.0-1.0_amd64.deb)

RUN mkdir -p /u01/app/oracle/data/admin && mkdir -p /u01/app/oracle/data/diag \
  && mkdir -p /u01/app/oracle/data/fast_recovery_area && mkdir -p /u01/app/oracle/data/oradata \
  && mkdir -p /u01/app/oracle/data/oradiag_oracle && mkdir -p /u01/app/oracle/data/product/11.2.0/xe/dbs \
  && mkdir -p /u01/app/oracle/data/product/11.2.0/xe/log && mkdir -p /u01/app/oracle/data/product/11.2.0/xe/network \
  && chown -R oracle:dba /u01/app/oracle/data \
  && mv /u01/app/oracle/product/11.2.0/xe/network/admin /u01/app/oracle/data/product/11.2.0/xe/network/admin \
  && mv /u01/app/oracle/product/11.2.0/xe/config /u01/app/oracle/data/product/11.2.0/xe/config \
  && ln -s /u01/app/oracle/data/admin /u01/app/oracle/admin && ln -s /u01/app/oracle/data/diag /u01/app/oracle/diag \
  && ln -s /u01/app/oracle/data/fast_recovery_area /u01/app/oracle/fast_recovery_area \
  && ln -s /u01/app/oracle/data/oradata /u01/app/oracle/oradata \
  && ln -s /u01/app/oracle/data/oradiag_oracle /u01/app/oracle/oradiag_oracle \
  && ln -s /u01/app/oracle/data/product/11.2.0/xe/dbs /u01/app/oracle/product/11.2.0/xe/dbs \
  && ln -s /u01/app/oracle/data/product/11.2.0/xe/log /u01/app/oracle/product/11.2.0/xe/log \
  && ln -s /u01/app/oracle/data/product/11.2.0/xe/network/admin /u01/app/oracle/product/11.2.0/xe/network/admin \
  && ln -s /u01/app/oracle/data/product/11.2.0/xe/config /u01/app/oracle/product/11.2.0/xe/config \
  && cp /assets/init.ora /u01/app/oracle/product/11.2.0/xe/config/scripts \
  && cp /assets/initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts \
  && /etc/init.d/oracle-xe configure responseFile=/assets/XE.rsp


EXPOSE 1521
EXPOSE 8080
VOLUME /u01/app/oracle/data
RUN rm -rf /assets
COPY docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "oracle-xe" ]


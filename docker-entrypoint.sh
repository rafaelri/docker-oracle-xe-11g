#!/bin/bash
if [ "$1" = 'oracle-xe' ]; then
  if [ ! -f /etc/default/oracle-xe ]; then
    mkdir -p $DATA_DIR/admin && mkdir -p $DATA_DIR/diag
    mkdir -p $DATA_DIR/fast_recovery_area && mkdir -p $DATA_DIR/oradata
    mkdir -p $DATA_DIR/oradiag_oracle && mkdir -p $DATA_DIR/product/11.2.0/xe/dbs
    mkdir -p $DATA_DIR/product/11.2.0/xe/log && mkdir -p $DATA_DIR/product/11.2.0/xe/network
    chown -R oracle:dba $DATA_DIR
    ln -s $DATA_DIR/admin /u01/app/oracle/admin && ln -s /u01/app/oracle/data/diag /u01/app/oracle/diag
    ln -s $DATA_DIR/fast_recovery_area /u01/app/oracle/fast_recovery_area
    ln -s $DATA_DIR/oradata /u01/app/oracle/oradata
    ln -s $DATA_DIR/oradiag_oracle /u01/app/oracle/oradiag_oracle
    ln -s $DATA_DIR/product/11.2.0/xe/dbs /u01/app/oracle/product/11.2.0/xe/dbs
    ln -s $DATA_DIR/product/11.2.0/xe/log /u01/app/oracle/product/11.2.0/xe/log
    mv /u01/app/oracle/product/11.2.0/xe/network/admin $DATA_DIR/product/11.2.0/xe/network/admin
    mv /u01/app/oracle/product/11.2.0/xe/config $DATA_DIR/product/11.2.0/xe/config
    ln -s $DATA_DIR/product/11.2.0/xe/network/admin /u01/app/oracle/product/11.2.0/xe/network/admin
    ln -s $DATA_DIR/product/11.2.0/xe/config /u01/app/oracle/product/11.2.0/xe/config

    echo "ORACLE_LISTENER_PORT=1521" > /tmp/XE.rsp
    echo "ORACLE_HTTP_PORT=8080" >> /tmp/XE.rsp
    echo "ORACLE_PASSWORD=${ORACLE_PASSWORD-manager}" >> /tmp/XE.rsp
    echo "ORACLE_CONFIRM_PASSWORD=${ORACLE_PASSWORD-manager}" >> /tmp/XE.rsp
    echo "ORACLE_DBENABLE=y" >> /tmp/XE.rsp
    /etc/init.d/oracle-xe configure responseFile=/tmp/XE.rsp
  fi
  service oracle-xe start
  for f in /docker-entrypoint-initdb.d/*; do
			case "$f" in
				*.sh)     echo "$0: running $f"; . "$f" ;;
				*.sql)    echo "$0: running $f"; "${sqlplus[@]}" < "$f"; echo ;;
				*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${sqlplus[@]}"; echo ;;
				*)        echo "$0: ignoring $f" ;;
			esac
			echo
		done
  tail -f `find /u01 -name listener.log`
else
  exec "$@"
fi

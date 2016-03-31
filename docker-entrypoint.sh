#!/bin/bash
if [ "$1" = 'oracle-xe' ]; then
  if [ ! -d "$DATADIR/oradata" ]; then
    echo "Setting up Oracle"

    echo "ORACLE_LISTENER_PORT=1521" > /tmp/XE.rsp
    echo "ORACLE_HTTP_PORT=8080" >> /tmp/XE.rsp
    echo "ORACLE_PASSWORD=${ORACLE_PASSWORD-manager}" >> /tmp/XE.rsp
    echo "ORACLE_CONFIRM_PASSWORD=${ORACLE_PASSWORD-manager}" >> /tmp/XE.rsp
    echo "ORACLE_DBENABLE=y" >> /tmp/XE.rsp
    /etc/init.d/oracle-xe configure responseFile=/tmp/XE.rsp

    for f in /docker-entrypoint-initdb.d/*; do
  			case "$f" in
  				*.sh)     echo "$0: running $f"; . "$f" ;;
  				*.sql)    echo "$0: running $f"; "${sqlplus[@]}" < "$f"; echo ;;
  				*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${sqlplus[@]}"; echo ;;
  				*)        echo "$0: ignoring $f" ;;
  			esac
  			echo
  		done
  fi
  echo "Starting Oracle"
  cp /post-setup/etc-oratab /etc/oratab
  cp /post-setup/etc-default-oracle-xe /etc/default/oracle-xe
  mkdir -p /u01/app/oracle/product/11.2.0/xe/log/diag/clients
  chown -R oracle:dba /u01/app/oracle/product/11.2.0/xe/log
  sed -i "s/%hostname%/$HOSTNAME/g" $LISTENERS_ORA
  sed -i "s/%port%/1521/g" $LISTENERS_ORA
  sed -i "s/%hostname%/$HOSTNAME/g" /u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora
  sed -i "s/%port%/1521/g" /u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora
  /etc/init.d/oracle-xe start
  tail -f `find /u01 -name listener.log` &
  PIDTAIL="$!"
  trap "echo 'Stopping Oracle' && service oracle-xe stop && kill $PIDTAIL" exit INT TERM
  wait
else
  exec "$@"
fi

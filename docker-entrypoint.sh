#!/bin/bash
if [ "$1" = 'oracle-xe' ]; then
  if [ -d "$DATADIR/oradata" ]; then
    echo "Setting up Oracle"

    cp /post-setup/*.ora $ORACLE_HOME/config/scripts
    echo "ORACLE_LISTENER_PORT=1521" > $ORACLE_HOME/config/XE.rsp
  	echo "ORACLE_HTTP_PORT=8080" >> $ORACLE_HOME/config/XE.rsp
  	echo "ORACLE_PASSWORD=${ORACLE_PASSWORD-manager}" >> $ORACLE_HOME/config/XE.rsp
  	echo "ORACLE_CONFIRM_PASSWORD=${ORACLE_PASSWORD-manager}" >> $ORACLE_HOME/config/XE.rsp
  	echo "ORACLE_DBENABLE=y" >> $ORACLE_HOME/config/XE.rsp

    #volumes
    chown -R oracle:dba /var/lib/oracle

    /etc/init.d/oracle-xe configure responseFile=$ORACLE_HOME/config/XE.rsp
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
  cat $TEMPLATE_LISTENERS_ORA | sed "s/%hostname%/$HOSTNAME/g" | sed "s/%port%/1521/g" > $LISTENERS_ORA
  service oracle-xe start
  tail -f `find /u01 -name listener.log` &
  PIDTAIL="$!"
  trap "echo 'Stopping Oracle' && service oracle-xe stop && kill $PIDTAIL" exit INT TERM
  wait
else
  exec "$@"
fi

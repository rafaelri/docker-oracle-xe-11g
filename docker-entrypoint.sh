#!/bin/bash
if [ "$1" = 'oracle-xe' ]; then
  if [ ! -d "$DATADIR/oradata" ]; then
    echo "Setting up Oracle"

    mkdir -p $DATADIR/admin \
    && mkdir -p $DATADIR/product/11.2.0/xe/ \
    && mkdir -p $DATADIR/product/11.2.0/xe/log/diag/clients \
    && mkdir $DATADIR/product/11.2.0/xe/network \
  	&& mkdir -p $DATADIR/diag \
  	&& mkdir -p $DATADIR/fast_recovery_area \
  	&& mkdir -p $DATADIR/oradata \
  	&& mkdir -p $DATADIR/oradiag_oracle \
    && cp -r $HOME_TEMPLATEDIR/config $HOME_DATADIR/config \
    && cp -r $HOME_TEMPLATEDIR/dbs $HOME_DATADIR/dbs  \
    && cp -r $HOME_TEMPLATEDIR/network/admin $HOME_DATADIR/network/admin \
    && chown -R oracle:dba /var/lib/oracle

    su -s /bin/bash oracle -c "$ORACLE_HOME/config/scripts/XE.sh"
    echo  alter user sys identified by \"$ORACLE_PASSWORD\"\; | su -s /bin/bash oracle -c "$SQLPLUS -s / as sysdba" > /dev/null 2>&1
    echo  alter user system identified by \"$ORACLE_PASSWORD\"\; | su -s /bin/bash oracle -c "$SQLPLUS -s / as sysdba" > /dev/null 2>&1
    echo @$ORACLE_HOME/apex/apxxepwd.sql \"$ORACLE_PASSWORD\"\; | su -s /bin/bash oracle -c "$SQLPLUS -s / as sysdba" > /dev/null 2>&1
    chmod 750 /u01/app/oracle/oradata
    chmod -R 775 /u01/app/oracle/diag
    echo "XE:$ORACLE_HOME:N" >> /etc/oratab
    chown oracle:dba /etc/oratab
    chmod 664 /etc/oratab

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

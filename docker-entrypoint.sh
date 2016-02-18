#!/bin/bash
if [ "$1" = 'oracle-xe' ]; then
  sed -i "s/%hostname%/$HOSTNAME/g" "$LISTENERS_ORA"
  sed -i "s/%port%/1521/g" "$LISTENERS_ORA"
  if [ ! -f $DATA_DIR/oradata ]; then
    echo "Setting up Oracle"

    su -s /bin/bash oracle "$ORACLE_HOME/config/scripts/XE.sh" > /dev/null 2>&1
    echo  alter user sys identified by \"$ORACLE_PASSWORD\"\; | su -s /bin/bash oracle -c "$SQLPLUS -s / as sysdba"
    echo  alter user system identified by \"$ORACLE_PASSWORD\"\; | su -s /bin/bash oracle -c "$SQLPLUS -s / as sysdba"
    echo @$ORACLE_HOME/apex/apxxepwd.sql \"$ORACLE_PASSWORD\"\; | su -s /bin/bash oracle -c "$SQLPLUS -s / as sysdba"
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
  su -s /bin/bash oracle -c "$LSNR start"
  su -s /bin/bash oracle -c "$SQLPLUS -s /nolog @$ORACLE_HOME/config/scripts/startdb.sql"
  tail -f `find /u01 -name listener.log` &
  PIDTAIL="$!"
  trap "echo 'Stopping Oracle' && su -s /bin/bash oracle -c \"$SQLPLUS -s /nolog @$ORACLE_HOME/config/scripts/stopdb.sql\" \
         su -s /bin/bash oracle -c \"$LSNR stop\" && kill $PIDTAIL" exit INT TERM
  wait
else
  exec "$@"
fi

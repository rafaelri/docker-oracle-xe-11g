#!/bin/bash
if [ "$1" = 'oracle-xe' ]; then
  if [ ! -f /etc/default/oracle-xe ]; then
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

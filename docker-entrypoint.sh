#!/bin/bash
if [ "$1" = 'oracle-xe' ]; then
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

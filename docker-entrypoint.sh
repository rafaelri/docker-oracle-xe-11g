#!/bin/bash
echo AAAA AAA AAA AAAAAAA
cat /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora
LISTENERS_ORA=/u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora
sed -i "s/%hostname%/$HOSTNAME/g" "${LISTENERS_ORA}" 
echo BBBB BBB BBB BBBBBB
cat /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora

if [ "$1" = 'oracle-xe' ]; then	
  service oracle-xe start
  for f in /docker-entrypoint-initdb.d/*; do
			case "$f" in
				*.sh)     echo "$0: running $f"; . "$f" ;;
				*.sql)    echo "$0: running $f"; "${mysql[@]}" < "$f"; echo ;;
				*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${mysql[@]}"; echo ;;
				*)        echo "$0: ignoring $f" ;;
			esac
			echo
		done
  tail -f `find /u01 -name listener.log`
else
  exec "$@"  
fi




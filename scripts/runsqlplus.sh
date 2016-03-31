#!/bin/bash

if [ -f /usr/bin/gnome-terminal ]
then
	/usr/bin/gnome-terminal -t "SQL*Plus" -e "/u01/app/oracle/product/11.2.0/xe/config/scripts/sqlplus.sh"
elif [ -f /usr/bin/konsole ]
then
	/usr/bin/konsole -T "SQL*Plus" -e "/u01/app/oracle/product/11.2.0/xe/config/scripts/sqlplus.sh"
elif [ -f /usr/bin/xterm ]
then
	/usr/bin/xterm  -T "SQL*Plus" -n "SQL*Plus" -e "/u01/app/oracle/product/11.2.0/xe/config/scripts/sqlplus.sh"
fi

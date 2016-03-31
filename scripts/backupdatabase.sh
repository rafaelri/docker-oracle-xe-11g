#!/bin/bash

if [ -f /usr/bin/gnome-terminal ]
then
	/usr/bin/gnome-terminal -t "Backup Database" -e "/u01/app/oracle/product/11.2.0/xe/config/scripts/backup.sh"
else
	/usr/bin/xterm  -T "Backup Database" -n "Backup Database" -e "/u01/app/oracle/product/11.2.0/xe/config/scripts/backup.sh"
fi

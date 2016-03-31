#!/bin/bash

if [ -f /usr/bin/gnome-terminal ]
then
	/usr/bin/gnome-terminal -t "Restore Database" -e "/u01/app/oracle/product/11.2.0/xe/config/scripts/restore.sh"
else
	/usr/bin/xterm  -T "Restore Database" -n "Restore Database" -e "/u01/app/oracle/product/11.2.0/xe/config/scripts/restore.sh"
fi

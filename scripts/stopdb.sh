#!/bin/bash
#
#       svaggu 09/28/05 -  Creation
#       svaggu 11/09/05 -  dba groupd check is added
#

xsetroot -cursor_name watch

case $PATH in
    "") PATH=/bin:/usr/bin:/sbin:/etc
        export PATH ;;
esac

SAVE_LLP=$LD_LIBRARY_PATH

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
SQLPLUS=$ORACLE_HOME/bin/sqlplus
user=`/usr/bin/whoami`
group=`/usr/bin/groups $user | grep -i dba`
if test -z "$group"
then
	if [ -f /usr/bin/zenity ]
	then
		/usr/bin/zenity --error --text="$user must be in the DBA OS group to stop the database."
		exit 1
	elif [ -f /usr/bin/kdialog ]
	then
		/usr/bin/kdialog --error "$user must be in the DBA OS group to stop the database"
		exit 1
	elif [ -f /usr/bin/xterm ]
	then
		/usr/bin/xterm -T "Error" -n "Error" -hold -e "$user must be in the DBA OS group to stop the database."
		exit 1
	fi
else
# Stop Oracle Database 11g Express Edition instance
	$SQLPLUS -s /nolog @$ORACLE_HOME/config/scripts/stopdb.sql > /dev/null 2>&1
fi
	
xsetroot -cursor_name left_ptr

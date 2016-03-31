#!/bin/bash
#
#program: stopall.sh
#Shutdown the database and listener
#
#       svaggu 08/31/05 -  Creation
#

shell=`echo $SHELL`
SU=/bin/su
ORACLE_OWNER=oracle
if [ $shell = "^/bin/csh$" ];
then
        if [ `echo $ORACLE_HOME ` = "" ] || [ `echo $ORACLE_SID` = ""]
        then
        echo "Error:Either ORACLE_HOME or ORACLE_SID are not defined"
        echo " Define ORACLE_HOME as setenv ORACLE_HOME"
        echo " Define ORACLE_SID  as setenv ORACLE_SID"
        exit 1
        fi
elif [ $shell = "^/bin/bash$" ]
then
        if [ `echo $ORACLE_HOME ` = "" ] || [ `echo $ORACLE_SID` = "" ]
        then
        echo "Error:Either ORACLE_HOME or ORACLE_SID are not defined"
        echo "Define ORACLE_HOME as export ORACLE_HOME"
	exit 1
        fi
fi

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE

pmon=`ps -ef | egrep pmon_$ORACLE_SID'\>' | grep -v grep`

if [ "$pmon" != "" ];
then
	$SU -s /bin/bash $ORACLE_OWNER -c "$ORACLE_HOME/bin/sqlplus -s /nolog @$ORACLE_HOME/config/scripts/stopdb.sql" > /dev/null 2>&1
fi

status=`ps -ef | grep tns | grep oracle | awk '{print $1}'`

if [ "$status" != "" ]; 
then
	$SU -s /bin/bash $ORACLE_OWNER -c "$ORACLE_HOME/bin/lsnrctl stop" > /dev/null 2>&1
fi

exit 0

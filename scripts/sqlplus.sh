#!/bin/bash
#
#       svaggu 09/28/05 -  Creation
#

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
export NLS_LANG=`$ORACLE_HOME/bin/nls_lang.sh`
export PATH=$ORACLE_HOME/bin:$PATH
sqlplus /nolog @$ORACLE_HOME/config/scripts/conmsg.sql

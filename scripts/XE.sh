#!/bin/sh

OLD_UMASK=`umask`
umask 0027
mkdir -p /var/lib/oracle/admin/XE/adump
mkdir -p /var/lib/oracle/admin/XE/dpdump
mkdir -p /var/lib/oracle/admin/XE/pfile
mkdir -p /var/lib/oracle/admin/cfgtoollogs/dbca/XE
mkdir -p /var/lib/oracle/admin/XE/dbs
mkdir -p /var/lib/oracle/fast_recovery_area
mkdir -p /var/lib/oracle/fast_recovery_area/XE
umask ${OLD_UMASK}
mkdir -p /var/lib/oracle/oradata/XE
ORACLE_SID=XE; export ORACLE_SID
/u01/app/oracle/product/11.2.0/xe/bin/sqlplus -s /nolog @/u01/app/oracle/product/11.2.0/xe/config/scripts/XE.sql

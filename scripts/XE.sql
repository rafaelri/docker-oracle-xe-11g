set verify off
DEFINE sysPassword = "oracle"
DEFINE systemPassword = "oracle"
host /u01/app/oracle/product/11.2.0/xe/bin/orapwd file=/u01/app/oracle/product/11.2.0/xe/dbs/orapwXE password=&&sysPassword force=y
@/u01/app/oracle/product/11.2.0/xe/config/scripts/CloneRmanRestore.sql
@/u01/app/oracle/product/11.2.0/xe/config/scripts/cloneDBCreation.sql
@/u01/app/oracle/product/11.2.0/xe/config/scripts/postScripts.sql
@/u01/app/oracle/product/11.2.0/xe/config/scripts/postDBCreation.sql
exit

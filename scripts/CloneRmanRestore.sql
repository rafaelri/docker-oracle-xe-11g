connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /u01/app/oracle/product/11.2.0/xe/config/log/CloneRmanRestore.log
startup nomount pfile="/u01/app/oracle/product/11.2.0/xe/config/scripts/init.ora";
@/u01/app/oracle/product/11.2.0/xe/config/scripts/rmanRestoreDatafiles.sql;

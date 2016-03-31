connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /u01/app/oracle/product/11.2.0/xe/config/log/postScripts.log
@/u01/app/oracle/product/11.2.0/xe/rdbms/admin/dbmssml.sql;
execute dbms_datapump_utl.replace_default_dir;
commit;
create or replace directory XMLDIR as '/u01/app/oracle/product/11.2.0/xe/rdbms/xml';
connect "SYS"/"&&sysPassword" as SYSDBA
DROP DIRECTORY ORACLE_OCM_CONFIG_DIR;
DROP DIRECTORY ADMIN_DIR;
DROP DIRECTORY WORK_DIR;
execute dbms_swrf_internal.cleanup_database(cleanup_local => FALSE);
commit;
spool off

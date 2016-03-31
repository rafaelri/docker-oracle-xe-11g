exec dbms_lock.sleep(5);
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /u01/app/oracle/product/11.2.0/xe/config/log/postDBCreation.log
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on

begin
   dbms_xdb.sethttpport('%httpport%');
   dbms_xdb.setftpport('0');
end;
/

create spfile='/u01/app/oracle/product/11.2.0/xe/dbs/spfileXE.ora' FROM pfile='/u01/app/oracle/product/11.2.0/xe/config/scripts/init.ora';
shutdown immediate;
connect "SYS"/"&&sysPassword" as SYSDBA
startup ;
select 'utl_recomp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
execute utl_recomp.recomp_serial();
select 'utl_recomp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
spool off
alter user hr password expire account lock;
alter user ctxsys password expire account lock;
alter user outln password expire account lock;
alter user mdsys password expire;
alter user flows_files password expire;

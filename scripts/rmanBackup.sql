set echo off;
set serveroutput on;
select TO_CHAR(systimestamp,'YYYYMMDD HH:MI:SS') from dual;
  variable devicename varchar2(255);
  variable set_stamp number;
  variable set_count number;
  declare 
    done boolean;
    concur boolean;
    pieceno binary_integer;
    handle varchar2(256);
    comment varchar2(255);
    media varchar2(255);
    params varchar2(255);
    archlog_failover boolean;
    recid number;
    stamp number;
    tag varchar2(32);
  begin 
    dbms_output.put_line(' ');
    dbms_output.put_line(' BACKUP: Allocating device... ');
      :devicename := dbms_backup_restore.deviceAllocate;
    dbms_output.put_line(' BACKUP: Specifing datafiles... ');
    dbms_backup_restore.backupSetDataFile(:set_stamp, :set_count);
    dbms_backup_restore.backupDataFile(1);
    dbms_backup_restore.backupDataFile(2);
    dbms_backup_restore.backupDataFile(3);
    dbms_backup_restore.backupDataFile(4);
    dbms_output.put_line(' BACKUP: Create piece ');
    dbms_backup_restore.backupPieceCreate('$ORACLE_HOME/dbs/express.dfb', pieceno, done,handle,comment,media,concur,params,reuse=>true,archlog_failover=>archlog_failover,deffmt=>0,recid=>recid,stamp=>stamp,tag=>tag,docompress=>true);
    IF done then
        dbms_output.put_line(' BACKUP: Backup datafile done.');
    else
        dbms_output.put_line(' BACKUP: Backup datafile failed');
    end if;
dbms_backup_restore.deviceDeallocate;
  end;
/
select TO_CHAR(systimestamp,'YYYYMMDD HH:MI:SS') from dual;
ALTER DATABASE BACKUP CONTROLFILE TO '$ORACLE_HOME/dbs/express.ctl' REUSE;
exit;

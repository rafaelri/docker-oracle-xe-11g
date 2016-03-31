#!/bin/sh
#
# The script assumes that user can connect using "/ as sysdba" and Flash 
# Recovery Area is enabled.
#
# =================
# Backup procedure
# =================
#
#    For database in NoArchiveLog mode, database is shutdown and an offline 
#    backup is done;
#    For database in Archive log mode, online backup is done.
#
#    During the backup procedure, the script stores flash recovery area 
#    location by saving complete initialization parameter to 
#    ?/dbs/spfile2init.ora file. This will be used during restore operation 
#    to find Flash Recovery Area location. If this file is lost, then user must 
#    enter Flash Recovery Area location during restore operation.
#
#    Two backups are maintained in Flash Recovery Area and the corresponding 
#    log files for last two backup job are saved in
#    $HOME/oxe_backup_current.log and $HOME/oxe_backup_previous.log
#
user=`/usr/bin/whoami`
group=`/usr/bin/groups $user | grep dba`
if test -z "$group"; then
   if [ -f /usr/bin/zenity ]
   then
        /usr/bin/zenity --error --text="$user must be in the DBA OS group to backup the database."
   elif [ -f /usr/bin/kdialog ]
   then
        /usr/bin/kdialog --error "$user must be in the DBA OS group to backup the database."
   elif [ -f /usr/bin/xterm ]
   then
       echo "Operation failed. $user must be in the DBA OS group to backup the database."
       echo -n "Press any key to exit"
       read userinp
   fi
   exit 0
fi

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE

export PATH=$ORACLE_HOME/bin:$PATH

TMPDIR=/tmp
rman_normlog=${TMPDIR}/rman_normlog$$.log

#Fix a logfile for current, previous run and spfile2init.ora
sqlplus /nolog > $rman_normlog << EOF
   connect / as sysdba;
   set echo off;
   set head off;
   set serveroutput on;
   set linesize 515;
   declare
      l1 varchar2(512);
   begin
      l1 := dbms_backup_restore.normalizeFilename('spfile2init.ora');
      dbms_output.put_line('-----------------');
      dbms_output.put_line(l1);
      dbms_output.put_line('-----------------');
   end;
   /
EOF
rman_spfile2init=`grep "spfile2init.ora$" $rman_normlog`
rm -f $rman_normlog

rman_backup_current=$HOME/oxe_backup_current.log
rman_backup_prev=$HOME/oxe_backup_previous.log

#Choose a temporary log for this run
rman_backup=${TMPDIR}/rman_backup$$.log
echo XE Backup Log > $rman_backup

#Check if flash recovery area is enabled
rman_fra=${TMPDIR}/rman_fra$$.log
sqlplus /nolog > $rman_fra << EOF
   connect / as sysdba;
   set head off;
   set echo off;
   set trimspool on;
   set linesize 512;
   select '$' || count(*) || '$' from v\$parameter
    where upper(name)='DB_RECOVERY_FILE_DEST'
      and value is not null;
EOF
fra=`grep "^$.*$" $rman_fra`
rm -f $rman_fra

if [ X$fra = X\$1\$ ]; then
   failed=false;
else
   failed=true
   errstr="flash recovery area is not enabled"
fi;

if [ $failed = 'false' ] ; then
   #Check the mode of database
   rman_log_mode=${TMPDIR}/rman_log_mode$$.log
   sqlplus /nolog > $rman_log_mode << EOF
      connect / as sysdba;
      set head off;
      set echo off;
      set trimspool on;
      set linesize 512;
      select '$' || log_mode || '$' from v\$database;
EOF
   mode=`grep "^$.*$" $rman_log_mode`
   rm -f $rman_log_mode

   case $mode in
      \$ARCHIVELOG\$)
      echo "Doing online backup of the database."
      rman target / >> $rman_backup << EOF
         set echo on;
         configure retention policy to redundancy 2;
         configure controlfile autobackup format for device type disk clear;
         configure controlfile autobackup on;
         sql "create pfile=''$rman_spfile2init'' from spfile";
         backup as backupset device type disk database;
         configure controlfile autobackup off;
         delete noprompt obsolete;
EOF
      if [ $? = 0 ]; then
         failed=false;
      else
         failed=true
         errstr="RMAN error: See log for details"
      fi;
      rman target / >> $rman_backup << EOF
         sql 'alter system archive log current';
EOF
      ;;

      \$NOARCHIVELOG\$)
      echo "Warning: Log archiving (ARCHIVELOG mode) is currently disabled. If"
      echo "you restore the database from this backup, any transactions that take"
      echo "place between this backup and the next backup will be lost. It is"
      echo "recommended that you enable ARCHIVELOG mode before proceeding so "
      echo "that all transactions can be recovered upon restore. See the section"
      echo "'Enabling ARCHIVELOG Mode...' in the online help for instructions."

      echo "Backup with log archiving disabled will shut down and restart the"
      echo -n "database. Are you sure [Y/N]?"
      gotit=false
      while ! $gotit; do
        read userinp
        if [ "$userinp" = "Y" -o "$userinp" = "y" -o \
             "$userinp" = "n" -o "$userinp" = "N" ]; then
          gotit=true
        fi
      done
      
      if [ "$userinp" = "n" -o "$userinp" = "N" ]; then
         rm -f $rman_backup
         exit -1;
      fi

      echo "Backup in progress..."

      rman target / >> $rman_backup << EOF
         set echo on; 
         shutdown immediate;
         startup mount;
         configure retention policy to redundancy 2;
         configure controlfile autobackup format for device type disk clear;
         configure controlfile autobackup on;
         sql "create pfile=''$rman_spfile2init'' from spfile";
         backup as backupset device type disk database;
         configure controlfile autobackup off;
         alter database open;
         delete noprompt obsolete;
EOF
      if [ $? = 0 ]; then
         failed=false;
      else
         failed=true
         errstr="RMAN error: See log for details"
      fi;
      ;;
   
      *)
      errstr="Unknown database mode $mode"
      failed=true;
      ;;
   esac;
fi;

#Save the error string in the log
if [ $failed = 'true' ]; then
   echo ${errstr}. >> $rman_backup
fi;

#Save the last run as previous
if [ -f $rman_backup_current ]; then
   mv -f $rman_backup_current $rman_backup_prev
fi;

#Save the current run
mv -f $rman_backup $rman_backup_current

#Display the result to user
if [ $failed = 'true' ] ; then
   echo '==================== ERROR ========================='
   echo '             Backup of the database failed          '
   echo '==================== ERROR ========================='
   echo ${errstr}.
   echo Log file is at $rman_backup_current.
else
   echo Backup of the database succeeded.
   echo Log file is at $rman_backup_current.
fi

#Wait for user to press any key
echo -n "Press ENTER key to exit"
read userinp 


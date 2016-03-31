#!/bin/sh 
#
# The script assumes that user can connect using "/ as sysdba"
#
# =================
# Restore procedure
# =================
#
#    If Installed Oracle home is also lost and oracle binaries were 
#    re-installed or the Oracle is installed to new oracle home location 
#    compared to backup time, then user will be prompted to enter Flash
#    Recovery Area location.
#
#    For database in NoArchiveLog mode, database is restored to last offline 
#    backup time/scn;
#    For database in Archive log mode, database is restored from last backup 
#    and a complete recovery is attempted. If complete recovery fails, 
#    user can open the database with resetlogs option provided the files 
#    are not recovery fuzzy.
#
#    The restore log is saved in $HOME/oxe_restore.log
#
user=`/usr/bin/whoami`
group=`/usr/bin/groups $user | grep dba`
if test -z "$group"; then
   if [ -f /usr/bin/zenity ]
   then
        /usr/bin/zenity --error --text="$user must be in the DBA OS group to restore the database."
   elif [ -f /usr/bin/kdialog ]
   then
        /usr/bin/kdialog --error "$user must be in the DBA OS group to restore the database."
   elif [ -f /usr/bin/xterm ]
   then
       echo "Operation failed. $user must be in the DBA OS group to restore the database."
       echo -n "Press any key to exit"
       read userinp
   fi
   exit 0
fi

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
export PATH=$ORACLE_HOME/bin:$PATH

echo -n "This operation will shut down and restore the database." \
        "Are you sure [Y/N]?"
gotit=false
while ! $gotit; do
  read userinp 
  if [ "$userinp" = "Y" -o "$userinp" = "y" -o \
       "$userinp" = "n" -o "$userinp" = "N" ]; then
    gotit=true
  fi
done

if [ "$userinp" = "n" -o "$userinp" = "N" ]; then
   exit -1;
fi;

TMPDIR=/tmp

echo "Restore in progress..."

#Choose a temporary log for this run
rman_restore=${TMPDIR}/rman_restore$$.log

#Fix a logfile for current run by starting a dummy instance
echo db_name=XE > ${TMPDIR}/rman_dummy$$.ora
echo sga_target=270M >> ${TMPDIR}/rman_dummy$$.ora
rman target / >> $rman_restore << EOF
   startup force nomount pfile=${TMPDIR}/rman_dummy$$.ora
EOF
rm -f ${TMPDIR}/rman_dummy$$.ora

rman_normlog=${TMPDIR}/rman_normlog$$.log
sqlplus /nolog > $rman_normlog << EOF
   connect / as sysdba;
   set echo off;
   set head off;
   set linesize 515;
   set serveroutput on;
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

rman_restore_current=$HOME/oxe_restore.log

#Restore Database
if [ -f $rman_spfile2init ]; then
   rman target / >> $rman_restore << EOF
      set echo on;
      startup force nomount pfile='$rman_spfile2init';
      restore (spfile from autobackup)
              (controlfile from autobackup);
      startup force mount;
      configure controlfile autobackup off;
      restore database;
EOF
else
   echo -n "Enter the flash recovery area location:"
   read fra_loc
   rman target / >> $rman_restore << EOF
      set echo on;
      restore spfile from autobackup db_recovery_file_dest='$fra_loc';
      startup force nomount;
      restore controlfile from autobackup;
      alter database mount;
      configure controlfile autobackup off;
      restore database;
EOF
fi;

if [ $? = 0 ]; then
   failed=false;
else
   errstr="RMAN error: See log for details"
   failed=true;
fi;

if [ $failed = 'false' ]; then
   rman_log_mode=${TMPDIR}/rman_log_mode$$.log
   sqlplus /nolog > $rman_log_mode << EOF
      connect / as sysdba;
      declare cursor n1 is select name from v\$tempfile;
      begin 
          for a in n1
          loop
            begin
               sys.dbms_backup_restore.deletefile(a.name);
            exception
               when others then
                 null;
            end;
          end loop;
      end;
      /
     exit;
     /
EOF
   rm -f $rman_log_mode

   rman_log_mode=${TMPDIR}/rman_log_mode$$.log
   sqlplus /nolog > $rman_log_mode << EOF
      connect / as sysdba;
      set head off;
      set echo off;
      set trimspool on;
      set linesize 515;
      select '$' || log_mode || '$' from v\$database;
EOF

   mode=`grep "^$.*$" $rman_log_mode`
   rm -f $rman_log_mode

   case $mode in
      \$ARCHIVELOG\$)
      rman target / >> $rman_restore << EOF
         set echo on;
         recover database;
         alter database open resetlogs;
EOF
      if [ $? = 0 ]; then
         failed=false;
      else
         errstr="RMAN Error: See log for details"
         failed=true;
      fi;
      ;;
      \$NOARCHIVELOG\$)
      rman target / >> $rman_restore << EOF
         set echo on;
         alter database open resetlogs;
EOF
      if [ $? = 0 ]; then
         failed=false;
      else
         failed=true;
         errstr="RMAN Error: See log for details"
      fi;
      ;;
      *)
      errstr="Unknown database mode $mode"
      failed=true;
      ;;
   esac;
fi

#Save the error string in the log
if [ $failed = 'true' ]; then
   echo ${errstr}. >> $rman_restore
fi;

#Save the current run
mv -f $rman_restore $rman_restore_current

#Display the result to user
if [ $failed = 'true' ] ; then
   echo '==================== ERROR ========================='
   echo '             Restore of the database failed         '
   echo '==================== ERROR ========================='
   echo ${errstr}.
   echo Log file is at $rman_restore_current.
else
   echo Restore of the database succeeded.
   echo Log file is at $rman_restore_current.
fi

#Wait for user to press any key
echo -n "Press ENTER key to exit"
read userinp 

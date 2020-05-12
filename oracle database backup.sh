#!/bin/bash 
export LANG=en_US
BACKUP_DATE=`date +%d`
backupDIR=/oradata/backup
current_month=`date +%Y_%m`
current_day=`date +%Y_%m_%d`
export rman_back_dir=$backupDIR/$current_month/$current_day
mkdir -p $rman_back_dir
RMAN_LOG_FILE=${rman_back_dir}/rmanlog_${current_day}.log
TODAY=`date`
USER=`id|cut -d "(" -f2|cut -d ")" -f1`
source ~/.bash_profile
echo "-----------------$TODAY-------------------">$RMAN_LOG_FILE
echo "ORACLE_SID: $ORACLE_SID">>$RMAN_LOG_FILE
echo "ORACLE_HOME:$ORACLE_HOME">>$RMAN_LOG_FILE
echo "ORACLE_USER:$ORACLE_USER">>$RMAN_LOG_FILE
echo "==========================================">>$RMAN_LOG_FILE
echo "BACKUP DATABASE BEGIN......">>$RMAN_LOG_FILE
echo "                   ">>$RMAN_LOG_FILE
chmod 666 $RMAN_LOG_FILE
WEEK_DAILY=`date +%a`
case  "$WEEK_DAILY" in
       "Mon")
            BAK_LEVEL=2
            ;;
       "Tue")
            BAK_LEVEL=2
            ;;
       "Wed")
            BAK_LEVEL=2
            ;;
       "Thu")
            BAK_LEVEL=1
            ;;
       "Fri")
            BAK_LEVEL=2
            ;;
       "Sat")
            BAK_LEVEL=2
            ;;
       "Sun")
            BAK_LEVEL=0
            ;;
       "*")
            BAK_LEVEL=error
esac
export BAK_LEVEL=$BAK_LEVEL 
echo "Today is : $WEEK_DAILY  incremental level= $BAK_LEVEL">>$RMAN_LOG_FILE
BAK_LEVEL=$BAK_LEVEL
export BAK_LEVEL
rman target / log "$RMAN_LOG_FILE" append <<EOF
run
{
backup incremental level $BAK_LEVEL Database format='${rman_back_dir}/dbk_level${BAK_LEVEL}_%U_%T.bkp'  tag='orcl_lev"$BAK_LEVEL"';
sql 'alter system archive log current';
backup archivelog all tag='arc_bak' format='${rman_back_dir}/archlog_level${BAK_LEVEL}_%U_%T';
backup current controlfile tag='bak_ctlfile' format='${rman_back_dir}/ctl__level${BAK_LEVEL}_%U_%T';
backup spfile tag='spfile' format='${rman_back_dir}/orcl_spfile_level${BAK_LEVEL}_%U_%T';
}
report obsolete; 
delete noprompt obsolete; 
crosscheck backup; 
delete noprompt expired backup;
list backup summary; 
EOF
# Initiate the command string 
STAT=$?
    echo "User Command String: $RUN_STR" >> $RMAN_LOG_FILE     
# --------------------------------------------------------------------------- 
# Log the completion of this script. 
# --------------------------------------------------------------------------- 
if [ "$STAT" = "0" ] 
then 
    LOGMSG="ended successfully" 
else 
    LOGMSG="ended in error" 
fi 
echo >> $RMAN_LOG_FILE 
echo ==== $LOGMSG on `date` ==== >> $RMAN_LOG_FILE 
echo >> $RMAN_LOG_FILE 
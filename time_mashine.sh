#! /bin/bash
##
##  https://blog.interlinked.org/tutorials/rsync_time_machine.html
##
##
#

###
### BACKUPDIR=Backups.backup
###	BACKUPNAME=$1
###
###

SRC="demo/utils/project2/"
PREFBCK="Backups.backup/Alexander.bak"
BCK="$PREFBCK/backup-"$date"/"
LNKDST="../Latest"

date=`date +%F.%H%M%S`
#if [[ -e Backups.backup/project2.bak/current ]]
#	then
#		echo "path exist!"
#fi

#rsync -avP --link-dest="$LNKDST" "$SRC" "$BCK" --delete

rm -f "$PREFBCK/current"
ln -sf "backup-$date" "$PREFBCK/current"
echo "$BCK"
echo "$PREFBCK/current"



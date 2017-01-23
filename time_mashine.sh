#!/usr/bin/env bash

#TODO: добавить зпись в Backup.log
#TODO: backup.log <-- начало и окончание процесса; объём переданных данных
#TODO: добавить проверку свободного дискового пространства


function checkOption { 				#проверка на наличие входящего параметра
	if [ -z "${1-}" ]; then
	   #echo "Must provide var environment variable. Exiting...."
	   echo "$0: missing operand"
	   exit 1
	fi
}

function checkSouchPath {
	if [[ ! -e "$1" ]]
	then
		echo "$0: \"$1\" failed: No such file or directory"
		exit 1
	fi
}

function checkmountpoint {
	if mountpoint -q $1
	then
	   echo "mounted"
	else
	   echo "not mounted"
	   exit 1
	 fi
}

function mkNoSouchDir {
	if [[ ! -e "$1" ]]
	then
		mkdir -p "$1"
	fi
}

function rmlink {
	if [[ -e "$1" ]];	then
	 unlink "$PREFBCK/$LNKDST"
	fi
}

function updatelink {
	rmlink "$1"
	foo=`pwd`
	cd "$PREFBCK"
	ln -sf "$DATE" "$LNKDST"
	cd "$foo"
}

function backupLog {
	echo "$(date +%F-%H:%M:%S) - Starting backup" > $1

}

function checkSize {
	CHECK=$(du -sh $1 | cut -f1)
	echo "Space needed for this backup: $CHECK" >> $2
}

checkOption $1
checkSouchPath $1

# установка основных путей
#BACKUPDIR="/mnt/backup/Backups.backupdb"
BACKUPDIR="Backups.backupdb"
BACKUPNAME="$( basename $1 )"
BACKSUFF="bckp"

PREFBCK="$BACKUPDIR/$BACKUPNAME.$BACKSUFF"

DATE=`date +%F.%H%M%S`

BCK="$PREFBCK/$DATE/"
LNKDST="Latest"


#checkmountpoint "$BACKUPDIR"

mkNoSouchDir "$PREFBCK/$DATE"
BACKUPFILELOG="$PREFBCK/$DATE/.Backup.log"

backupLog "$BACKUPFILELOG"
checkSize "$1" "$BACKUPFILELOG"

rsync -av --link-dest="$PWD/$PREFBCK/$LNKDST/" "$1" "$BCK" --log-file="$BACKUPFILELOG" --delete
updatelink "$PREFBCK/$LNKDST"

#echo "LINKDST: $PREFBCK/$LNKDST"
#echo "DST: $PREFBCK/$DATE"


#echo "BCK: $BCK"

#echo "$( basename $1).bak"

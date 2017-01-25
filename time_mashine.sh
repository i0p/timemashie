#!/usr/bin/env bash

## Резервное архивирование (backup) всех файлов в заданом каталоге,
## которые были изменены с момента последнего саздания backup
## Файлы складываются в инкрементный архив

## Writen by: Danilov Paul - danilov.paul@gmail.com on 01-2017

#TODO: добавить зпись в Backup.log
#TODO: backup.log <-- начало и окончание процесса; объём переданных данных
#TODO: добавить проверку свободного дискового пространства

function checkOption { 				#проверка на наличие входящего параметра
	if [ -z "${1:-}" ]; then
	   #echo "Must provide var environment variable. Exiting...."
	   echo "$0: missing operand"
	   exit 1
	fi
}

function print_help {
	default_dest="${1:-/mnt/backup}"

	echo "$(basename $0) based RSYNC file transfer program"
	echo
	echo "$(basename $0) comes with ABSOLUTELY NO WARRANTY.  This is free software, and you"
	echo "are welcome to redistribute it under certain conditions.  See the GNU"
	echo "General Public Licence for details."
	echo
	echo "$(basename $0) transfer local dir to local storage on the mounted section section"
	echo "default backup destination:"
	echo "		${default_dest}"
	echo
	echo "Usage: $(basename $0) SRC_BACKUP_DIR [DEST_BACKUP_DIR]"
	echo
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
#	echo "BACKUP in: $1"
#	если есть символическая ссылка на каталог, то она !удаляется
	[ -L "$1/${LNKDST}" ] && rm -f "$1/${LNKDST}"
	foo=$(pwd)
#	echo -n "$(pwd) -> "
	cd "$1"
	#echo "make lnk from ${DATE} as ${LNKDST}"
	[ -d "${DATE}" ] && echo "set link new dest" && ln -sf "${DATE}" "$LNKDST"
	#ls -lha
	cd "${foo}"

}

function backupLog {
	echo "$(date +%F-%H:%M:%S) - Starting backup" > $1

}

function checkSize {
	CHECK=$(du -sh $1 | cut -f1)
	echo "Space needed for this backup: $CHECK" >> $2
}

die () {
	# убийство выполнения скрипта
	echo "FATAL ERROR: $* (status $?)"  1>&2
	exit 1
}


	# проверка входных аргументов
if [ -z "$1" ]
then
	print_help #"/mnt/backup/Backups.backupdb"
	# echo $? --  код завершения сценария
	exit 65
fi

# установка основных путей
SRC="$1"
[ -z "$2" ] && bckp_pref="Backups.backupdb"
#BACKUPDIR=${2:-"Backups.backupdb"} # так тоже можно

BACKUPNAME="$( basename $1 )"

BACKSUFF="bckp"

checkSouchPath $1


backup_dest="${bckp_pref}/${BACKUPNAME}.${BACKSUFF}" # установка MAIN каталога для размещения копии файлов

DATE=`date +%F.%H%M%S`

cur_backup_dest="${backup_dest}/${DATE}" 				#  каталог для размещения будующего backup

LNKDST="Latest"


#checkmountpoint "$BACKUPDIR"

#mkNoSouchDir "${PREFBCK}/${DATE}"
mkNoSouchDir "${cur_backup_dest}"
BACKUPFILELOG="${cur_backup_dest}/.Backup.log"

backupLog "$BACKUPFILELOG"
checkSize "$1" "$BACKUPFILELOG"

echo "root dir: ${backup_dest}"

# ------  синхронизация катлогов !!!
rsync -a --link-dest="$PWD/${backup_dest}/$LNKDST" "$1" "${cur_backup_dest}/" --log-file="$BACKUPFILELOG" --delete

# ------ финал: замена цели в simlink

updatelink "$PWD/${backup_dest}"

#echo "LINKDST: $PREFBCK/$LNKDST"
#echo "DST: $PREFBCK/$DATE"


#echo "BCK: $BCK"

#echo "$( basename $1).bak"

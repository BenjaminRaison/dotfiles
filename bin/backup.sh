#!/bin/bash -eu
# Loosely based on https://borgbackup.readthedocs.io/en/stable/deployment/automated-local.html

MOUNTPOINT=/media/backup
TARGET="$MOUNTPOINT"/borg/backup-"$(hostname)"
ARCHIVENAME="$(date --iso-8601)"-"$(hostname)"

if [ ! -d "$TARGET" ]; then echo "Backup not mounted, aborting."; exit; fi

export BORG_RELOCATED_REPO_ACCESS_IS_OK=no
export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=no

borg --version
echo "Starting backup for $ARCHIVENAME on $TARGET"

# Run as root to back up /etc
sudo borg create --progress --stats --one-file-system --compression lzma,5 --checkpoint-interval 86400 \
	--exclude '/home/*/.cache' \
	--exclude '/home/*/.android' \
	--exclude '/home/*/.AndroidStudio*' \
	--exclude '/home/*/.arduino*' \
	--exclude '/home/*/.m2' \
	--exclude '/home/*/.IntelliJ*' \
	--exclude '/home/*/.java' \
	--exclude '/home/*/.node-gyp' \
	--exclude '/home/*/.npm' \
	--exclude '/home/*/.oracle_jre_usage' \
	--exclude '/home/*/.config/chromium' \
	--exclude '/home/*/sdk' \
	--exclude '/home/*/.thumbnails' \
	--exclude '/home/*/.sbt' \
	--exclude '/home/*/snap' \
	--exclude '/home/*/.oracle_jre_usage' \
	--exclude '/home/*/.secrets' \
	--exclude '/home/*/go/bin' \
	--exclude '/home/*/go/pkg' \
	--exclude '/home/*/.config/google-chrome' \
	--exclude '*/.gradle' \
	--exclude '*/node_modules' \
	--exclude '*/build/' \
	--exclude '*/.maven' \
	--exclude '*/.cache' \
	--exclude '*/Trash' \
	--exclude '*/.Trash' \
	--exclude 'java_pid*.hprof' \
	--exclude '*/nerd-fonts/' \
	"$TARGET"::"$ARCHIVENAME" \
	/home /etc


echo "Completed backup for $ARCHIVENAME"

# Paranoia
sync

notify-send "Backup complete" "The backup for $ARCHIVENAME on $MOUNTPOINT has completed" -u critical
sudo umount $MOUNTPOINT

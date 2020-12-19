#!/bin/bash -eu

TARGET= #TODO
EXCLUDE_LIST= #TODO

ARCHIVE_FILES="files-$(date --iso-8601)"
ARCHIVE_DATABASE="database-$(date --iso-8601)"

export BORG_RSH='ssh -oBatchMode=yes'
export BORG_RELOCATED_REPO_ACCESS_IS_OK=no
export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=no
export BORG_REMOTE_PATH=borg1
export BORG_PASSPHRASE= #TODO

ARCHIVES=$(borg list --short "$TARGET")

if ! echo "$ARCHIVES" | grep -q "$ARCHIVE_FILES"
then
    [ -f /usr/bin/dpkg ] && dpkg --get-selections > /tmp/apt_installed
    [ -f /usr/bin/pip ] && pip list > /tmp/pip_installed
  
    borg create \
        --one-file-system \
        --compression auto,lzma,7 \
        --exclude-from "$EXCLUDE_LIST" \
        --show-rc \
        "$TARGET::$ARCHIVE_FILES" \
        /home /etc /root /tmp/apt_installed /tmp/pip_installed

    borg prune -v --list \
        --prefix='files-' \
        --keep-daily=7 \
        --keep-weekly=4 \
        --keep-monthly=12 \
        "$TARGET"

    rm /tmp/apt_installed /tmp/pip_installed
fi

if ! echo "$ARCHIVES" | grep -q "$ARCHIVE_DATABASE"
then
    mysqldump --all-databases --skip-comments | borg create \
        --compression auto,lzma,7 \
        --show-rc \
        --stdin-name mysqldump.sql \
        "$TARGET::$ARCHIVE_DATABASE" -
    
    borg prune -v --list \
        --prefix='database-' \
        --keep-daily=7 \
        --keep-weekly=4 \
        --keep-monthly=12 \
        "$TARGET"
fi


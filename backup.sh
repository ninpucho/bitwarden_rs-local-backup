#!/bin/sh

# rm any backups older than 30 days
find /backups/* -mtime +$(RETENTION_DAYS) -exec rm {} \;

# create backup filename
BACKUP_FILE="$(date "+%F-%H%M%S")"

# create backup folder
BACKUP_FOLDER="$(date "+%F-%H%M%S")"
mkdir '/tmp/$(BACKUP_FOLDER)'

# use sqlite3 to create backup (avoids corruption if db write in progress)
sqlite3 /vault/db.sqlite3 ".backup '/tmp/$(BACKUP_FOLDER)/db.sqlite3'"

# backup attachments folder
cp -ar '/vault/attachements' '/tmp/$(BACKUP_FOLDER)/'

# backup rsa_key
cp -a '/vault/rsa_key.*' '/tmp/$(BACKUP_FOLDER)/'

# backup icon cache folder
cp -ar '/vault/icon_cache' '/tmp/$(BACKUP_FOLDER)/'

# backup sends folder
cp -ar '/vault/sends' '/tmp/$(BACKUP_FOLDER)/'

# If config file exists backup.
if [[ -f "/vault/config.json" ]]; then
    cp -a '/vault/config.json' '/tmp/$(BACKUP_FOLDER)/'
fi

# tar up backup and encrypt with openssl and encryption key
tar -czf - /tmp/$(BACKUP_FOLDER) | openssl enc -e -aes256 -salt -pbkdf2 -pass pass:${BACKUP_ENCRYPTION_KEY} -out /backups/${BACKUP_FILE}.tar.gz

# cleanup tmp folder
rm -rf /tmp/*

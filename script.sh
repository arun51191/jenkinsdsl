#!/bin/bash -e
RED='\033[0;31m'
NOW=$(date +'%d-%m-%Y-%H:%M:%S')
if [[ $S_ENV != $D_ENV && ! -z $DATABASE && $DATABASE != " " ]]; then

  environments=("dev" "uat" "int")
  source_users=($devuser $uatuser $intuser)
  source_pass=($devpass $uatpass $intpass)
  target_users=($devuser $uatuser $intuser)
  target_pass=($devpass $uatpass $intpass)
  db_hosts=(dev.cyscy6raao4x.ap-south-1.rds.amazonaws.com uat.cyscy6raao4x.ap-south-1.rds.amazonaws.com myint.cyscy6raao4x.ap-south-1.rds.amazonaws.com)
  i=0
  len=${#environments[*]}

  while [ $i -lt $len ]
  do
    if [ environments[$i] == $S_ENV ]; then
      export SOURCE_USER = source_users[$i]
      export SOURCE_PW = source_pass[$i]
      export SOURCE_DB = db_hosts[$i]
    fi
    i=`expr $i+1` 
  done

  i=0
  while [ $i -lt $len ]
  do
    if [ environments[$i] == $D_ENV ]; then
      export TARGET_USER = target_users[$i]
      export TARGET_PW = target_pass[$i]
      export TARGET_DB = db_hosts[$i]
    fi
    i=`expr $i+1` 
  done

  echo "Attempting to dump from $SOURCE_DB ..."

  echo "running mysqldump --verbose --single-transaction --max-allowed-packet=1GB --extended-insert -h $SOURCE_DB -u $SOURCE_USER -pxxxx $DATABASE | gzip -7 > $DATABASE.sql.gz"
  mysqldump --verbose --single-transaction --max-allowed-packet=1GB --extended-insert -h $SOURCE_DB -u $SOURCE_USER -p$SOURCE_PW $DATABASE | gzip -7 > $DATABASE.sql.gz

  if [ $? -eq 0 ]; then

     echo -e "Database dump successfully completed for $DATABASE from $SOURCE_DB at $(date +'%d-%m-%Y %H:%M:%S')"

     echo -e "drop $DATABASE from $TARGET_DB"

     mysql -h $TARGET_DB -u $TARGET_USER -p$TARGET_PW -e "DROP DATABASE IF EXISTS $DATABASE"

     echo -e "create  $DATABASE into $TARGET_DB"

     mysql -h $TARGET_DB -u $TARGET_USER -p$TARGET_PW -e "CREATE DATABASE $DATABASE"

     echo -e "Refreshing data for $DATABASE on $TARGET_DB"

     zcat $DATABASE.sql.gz | perl -pe 's/\sDEFINER=`[^`]+`@`[^`]+`//' | mysql -h $TARGET_DB -u $TARGET_USER -f -p$TARGET_PW $DATABASE

     if [ $? -eq 0 ]; then

         echo -e "Restoration done successfully completed for $DATABASE on $TARGET_DB at $(date +'%d-%m-%Y %H:%M:%S')"

         rm -rf ./$DATABASE.sql.gz

         exit 0

     else

        echo -e "${RED} Restoration failed for $DATABASE on $TARGET_DB ${RED}"

        exit 1

     fi

  else

    echo -e "${RED} Database backup failed for $DATABASE from $SOURCE_DB ${RED}"

    exit 1

  fi

  exit 0

else 
    echo -e "${RED} Source and target hosts shouldn't be same AND  database parameter shouldn't be empty ${RED}"

    exit 1
fi

#!/bin/bash -e
NOW=$(date +'%d-%m-%Y-%H:%M:%S')
if [ $S_ENV != $D_ENV ]; then

  if [ $S_ENV == "dev" ]; then
    SOURCE_DB = "dev.cyscy6raao4x.ap-south-1.rds.amazonaws.com"
    SOURCE_USER = $devuser
    SOURCE_PW = $devpass
 
  elif [ $S_ENV == "uat" ]; then 
    SOURCE_DB = "uat.cyscy6raao4x.ap-south-1.rds.amazonaws.com"
    SOURCE_USER = $uatuser
    SOURCE_PW = $uatpass

  else
    SOURCE_DB = "myint.cyscy6raao4x.ap-south-1.rds.amazonaws.com"
    SOURCE_USER = $intuser
    SOURCE_PW = $intpass
  fi

  if [ $D_ENV == "dev" ]; then
    TARGET_DB = "dev.cyscy6raao4x.ap-south-1.rds.amazonaws.com"
    TARGET_USER = $devuser
    TARGET_PW = $devpass

  elif [ $D_ENV == "uat" ]; then 
    TARGET_DB= "uat.cyscy6raao4x.ap-south-1.rds.amazonaws.com"
    TARGET_USER = $uatuser
    TARGET_PW   = $uatpass

  else

    TARGET_DB= "myint.cyscy6raao4x.ap-south-1.rds.amazonaws.com"
    TARGET_USER = $intuser
    TARGET_PW = $intpass

  fi

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

        echo -e "Restoration failed for $DATABASE on $TARGET_DB"

        exit 1

     fi

  else

    echo -e "Database backup failed for $DATABASE from $SOURCE_DB"

    exit 1

  fi

  exit 0

else 
    echo -e "$SOURCE_DB should not be same as $TARGET_DB"

    exit 1
fi

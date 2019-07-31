#!/bin/bash -e
RED='\033[0;31m'
NOW=$(date +'%d-%m-%Y-%H:%M:%S')
if [ $S_ENV != $D_ENV || $DATABASE!=""]; then

  if [ $S_ENV == "RA_DEV" ]; then
    export SOURCE_DB="dev.cyscy6raao4x.ap-south-1.rds.amazonaws.com"
    export SOURCE_USER=$devuser
    export SOURCE_PW=$devpass
 
  elif [ $S_ENV == "RA_UAT" ]; then 
    export SOURCE_DB="uat.cyscy6raao4x.ap-south-1.rds.amazonaws.com"
    export SOURCE_USER=$uatuser
    export SOURCE_PW=$uatpass

  else
    export SOURCE_DB="myint.cyscy6raao4x.ap-south-1.rds.amazonaws.com"
    export SOURCE_USER=$intuser
    export SOURCE_PW=$intpass
  fi

  if [ $D_ENV == "RA_DEV" ]; then
    export TARGET_DB="dev.cyscy6raao4x.ap-south-1.rds.amazonaws.com"
    export TARGET_USER=$devuser
    export TARGET_PW=$devpass

  elif [ $D_ENV == "RA_UAT" ]; then 
    export TARGET_DB="uat.cyscy6raao4x.ap-south-1.rds.amazonaws.com"
    export TARGET_USER=$uatuser
    export TARGET_PW=$uatpass

  else

    export TARGET_DB="myint.cyscy6raao4x.ap-south-1.rds.amazonaws.com"
    export TARGET_USER=$intuser
    export TARGET_PW=$intpass

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

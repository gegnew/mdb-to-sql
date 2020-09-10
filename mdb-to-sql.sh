#!/usr/bin/bash

# Make sure you have mysql and mdbtools installed.
# mdbtools is at https://github.com/mdbtools/mdbtools
# (mdbtools has commits on github from 8 days ago and from ~20 years ago; amazing)
# If you're on arch you can install with `pacman -S mdbtools`. There's
# probably an apt package as well
# Replace the environment variables below or export them in your env.
#
# _Before_ running this script you need to create a database for the export!
#
# It would be einfach to generify this script for exporting any .mdb database.
# Do so if you feel like it.
#
# (c) me, 2020
# WTFPL

USER="g"
PASSWORD=""
EXPORT_DB=""
IMPORT_MDB=".mdb"
DB_FLAVOR="mysql"

mdb-schema  $DB_FLAVOR >> schema.sql
# make sure this works if you change the db flavor from mysql
$DB_FLAVOR -u"$USER" -p"$PASSWORD" -D "$EXPORT_DB" < schema.sql

# note that the date format might also change if you change db flavors
mdb-tables -1 $IMPORT_MDB | while read -r tablename; do
    fname=$(echo "$tablename" | tr -d '()' | tr ' ' '_').sql
    echo "Extracting $tablename to $fname"
    mdb-export -I $DB_FLAVOR -D "%Y-%m-%d %H:%m:%S" $IMPORT_MDB "$tablename" > "$fname"
    $DB_FLAVOR -u"$USER" -p"$PASSWORD" -D "$EXPORT_DB" < "$tablename".sql
done

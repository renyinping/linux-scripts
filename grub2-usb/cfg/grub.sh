#!/bin/sh

WORK_DIR=`dirname $(readlink -f $0)`;
export LD_LIBRARY_PATH=${WORK_DIR}:${LD_LIBRARY_PATH}
cd ${WORK_DIR}

CFG_FILE=grub.cfg
echo "# grub.cfg" > $CFG_FILE

echo "" >> $CFG_FILE
cat ubuntu-live-text.cfg >> $CFG_FILE

echo "" >> $CFG_FILE
cat ubuntu-live.cfg >> $CFG_FILE

echo "" >> $CFG_FILE
cat dos.cfg >> $CFG_FILE

echo "" >> $CFG_FILE
cat end.cfg >> $CFG_FILE

cp $CFG_FILE ../../../../grub2/grub.cfg
cp memdisk   ../../../../grub2/memdisk

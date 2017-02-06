# /bin/bash

WORK_DIR=`dirname $(readlink -f $0)`;
export LD_LIBRARY_PATH=${WORK_DIR}:${LD_LIBRARY_PATH}
cd ${WORK_DIR}

# /grub2/gr2ldr.i386-pc
GRUB2_DIR=../../../grub2
mkdir -p $GRUB2_DIR

echo '
search.file /grub2/grub.cfg root
set prefix=($root)/grub2
' > $GRUB2_DIR/embed.cfg

LDR_MOD='biosdisk part_msdos ext2 fat exfat ntfs search_fs_file'
grub-mkimage -o $GRUB2_DIR/i386-pc-core.img -c $GRUB2_DIR/embed.cfg -O i386-pc $LDR_MOD
cp -r /usr/lib/grub/i386-pc $GRUB2_DIR/
cp -r /boot/grub/locale     $GRUB2_DIR/
cp -r /boot/grub/fonts      $GRUB2_DIR/
cat $GRUB2_DIR/i386-pc/lnxboot.img > $GRUB2_DIR/gr2ldr.i386-pc
cat $GRUB2_DIR/i386-pc-core.img   >> $GRUB2_DIR/gr2ldr.i386-pc


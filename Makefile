CC      = gcc
CFLAGS  = -Wall -fno-builtin -nostdinc -nostdlib
LD      = ld
ASM     = nasm

OBJS = \
	loader.o \
	kernel.o \
	printf.o \
	screen.o \
	pci.o 
	
copy:
	cp kernel-1 /boot/

loader.o:
	$(ASM) -f elf32 loader.asm -o loader.o

kernel.o:
	$(CC) -m32 -Iinclude $(CFLAGS) -O0 -c -g kernel.c -o kernel.o

printf.o:
	$(CC) -m32 -Iinclude $(CFLAGS) -c -g include/printf.c -o printf.o

screen.o:
	$(CC) -m32 -Iinclude $(CFLAGS) -c -g include/screen.c -o screen.o

pci.o:
	$(CC) -m32 -Iinclude $(CFLAGS) -c -g include/pci.c -o pci.o

kernel-1: $(OBJS)
	$(LD) -m elf_i386 -T link.ld  -O0 -g -o $@ -Map System.map loader.o kernel.o printf.o screen.o pci.o
	cp $@ $@.dbg 
	strip $@

clean:
	rm -f $(OBJS) kernel-1 


copy-grub:
	cp /usr/lib/grub/i386-pc/stage1 ./grub/
	cp /usr/lib/grub/i386-pc/stage2 ./grub/
	cp /usr/lib/grub/i386-pc/fat_stage1_5 ./grub/

image:
	@echo "Creating hdd.img..."
	@dd if=/dev/zero of=./hdd.img bs=512 count=16065 1>/dev/null 2>&1

	@echo "Creating bootable first FAT32 partition..."
	@losetup /dev/loop1 ./hdd.img
	@(echo c; echo u; echo n; echo p; echo 1; echo ;  echo ; echo a; echo 1; echo t; echo c; echo w;) | fdisk /dev/loop1 1>/dev/null 2>&1 || true

	@echo "Mounting partition to /dev/loop2..."
	@losetup /dev/loop2 ./hdd.img \
	--offset=32256 \
	--sizelimit=8224768

	#--offset    `echo \`fdisk -lu /dev/loop1 | sed -n 10p | awk '{print $$3}'\`*512 | bc` \
	#--sizelimit `echo \`fdisk -lu /dev/loop1 | sed -n 10p | awk '{print $$4}'\`*512 | bc`
	@losetup -d /dev/loop1

	@echo "Format partition..."
	@mkdosfs /dev/loop2

	@echo "Copy kernel and grub files on partition..."
	@mkdir -p tempdir
	@mount /dev/loop2 tempdir
	@mkdir tempdir/boot
	#@cp -r /usr/lib/grub/i386-pc/grub tempdir/boot/
	@cp kernel-1 tempdir/
	@sleep 1
	@umount /dev/loop2
	@rm -r tempdir
	@losetup -d /dev/loop2

	@echo "Installing GRUB..."
	@echo "device (hd0) hdd.img \n \
	       root (hd0,0)         \n \
	       setup (hd0)          \n \
	       quit\n" | grub --batch 1>/dev/null
	@echo "Done!"

#!/bin/bash

KERNEL_VERSION=6.7.4
BUSYBOX_VERSION=1.34.1

mkdir -p src
cd src

	#kernel
	KERNEL_MAJOR=$(echo $KERNEL_VERSION | sed 's/\([0-9]*\)[^0-9].*/\1/')
	wget https://mirrors.edge.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR.x/linux-$KERNEL_VERSION.tar.xz
	if [ $? -ne 0 ]; then
    	echo "Kernel download failed! Check your network connection."
    	exit 1
    fi

	tar -xf linux-$KERNEL_VERSION.tar.xz
	cd linux-$KERNEL_VERSION
		make defconfig
		make -j8 || exit
	
	cd ..
	
	#busybox
	wget https://www.busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
	if [ $? -ne 0 ]; then
    	echo "Busybox download failed! Check your network connection."
    	exit 1
    fi
	tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
    cd busybox-$BUSYBOX_VERSION
		make defconfig
		sed 's/^.*CONFIG_STATIC[^_].*$/CONFIG_STATIC=y/g' -i .config
		make CC=musl-gcc -j8 busybox || exit

	cd ..
	
cd ..

cp src/linux-$KERNEL_VERSION/arch/x86_64/boot/bzImage ./

#initrd
mkdir initrd
cd initrd
	mkdir -p bin dev proc sys
	cd bin

		cp ../../src/busybox-$BUSYBOX_VERSION/busybox ./
		for prog in $(./busybox --list); do
			ln -s /bin/busybox ./$prog

		done

	cd ..

    echo '#!/bin/sh' > init
	echo 'mount -t sysfs sysfs /sys' >> init
	echo 'mount -t proc proc /proc' >> init
	echo 'mount -t devtmpfs udev /dev' >> init
	echo 'sysctl -w kernel.printk="2 4 1 7"' >> init
	echo '/bin/sh' >> init
    echo 'poweroff -f' >> init
	echo '# Simple Login Section' >> init
	echo '::askconsole -c /bin/sh # Launch /bin/sh on primary console' >> init
	echo '::respawn:-/bin/getty 38400 console # Continuously respawn getty on the console' >> init

	

	chmod -R 777 ./

	find . | cpio -o -H newc > ../initrd.img

cd .. 

#qemu-system-x86_64 -kernel bzImage -initrd initrd.img -nographic -append "console=ttyS0" 
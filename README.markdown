This is a patch used to create EL6 images which will boot with the root file
system in memory.

Building the image
------------------
Install livecd-tools
    $ sudo yum install livecd-tools

Download the kickstart file, or create your own

Create the iso file:
    $ sudo livecd-creator --config=centos64-pxe.ks --fslabel=centos64-pxe
    $ sudo livecd-iso-to-pxeboot centos64-pxe.iso

This will output the files vmlinuz0 and initrd0.img. Make these files available
on a web server.

Booting on the image
--------------------
This is an example iPXE script. Modify it to match your setup:
    #!ipxe
    initrd http://example.com/initrd0.img
    kernel http://example.com/vmlinuz0 initrd=/initrd0.img root=/centos64-pxe.iso rootfstype=auto rw liveimg toram size=4096
    boot


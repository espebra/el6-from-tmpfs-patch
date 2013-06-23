install
network --bootproto dhcp --device eth0 --onboot yes
lang en_US.UTF-8
keyboard no
skipx
text

# Change this!
rootpw foobar

url --url=http://ftp.uio.no/centos/6.4/os/x86_64/
repo --name=os --baseurl=http://ftp.uio.no/centos/6.4/os/x86_64/
repo --name=updates --baseurl=http://ftp.uio.no/centos/6.4/updates/x86_64/
firewall --disabled
selinux --disabled
firstboot --disabled
authconfig --enableshadow --enablemd5
timezone --utc Europe/Oslo
bootloader --location=mbr --append="toram"
zerombr
reboot
clearpart --all
part / --fstype=ext4 --size=4096

%packages --excludedocs
@base
@core
dracut
patch
ruby
redhat-lsb
device-mapper-multipath
%end

%post
#
# Everything below here is related to the ramdisk hosting the root filesystem
#

# For debugging: Show the changes during the build process.
diff -u /root/fstab.backup /etc/fstab

echo "Backup dmsquash-live-root"
cp /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root /root/dmsquash-live-root.backup

echo "md5sum for /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root"
md5sum /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root

echo " "
echo "Contents of /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root"
echo "-----------------------------------"
cat /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root
echo "-----------------------------------"

# Add support for the toram kernel parameter in dmsquash-live-root
echo "Patching dmsquash-live-root"

# Using base64 to avoid fuzz with variables being used in %post directly. It
# seems easier than manual escaping.
cat > /root/dmsquash-live-root.patch.base64 << EOF
LS0tIGRtc3F1YXNoLWxpdmUtcm9vdAkyMDEzLTA2LTIzIDE5OjM3OjQzLjAwMDAwMDAwMCArMDIw
MAorKysgZG1zcXVhc2gtbGl2ZS1yb290LnBhdGNoZWQJMjAxMy0wNi0yMyAxOTo0NToyOC4wMDAw
MDAwMDAgKzAyMDAKQEAgLTI0LDYgKzI0LDggQEAKIGdldGFyZyByZWFkb25seV9vdmVybGF5ICYm
IHJlYWRvbmx5X292ZXJsYXk9Ii0tcmVhZG9ubHkiIHx8IHJlYWRvbmx5X292ZXJsYXk9IiIKIG92
ZXJsYXk9JChnZXRhcmcgb3ZlcmxheSkKIAorZ2V0YXJnIHRvcmFtICYmIHRvcmFtPSJ5ZXMiCisK
ICMgRklYTUU6IHdlIG5lZWQgdG8gYmUgYWJsZSB0byBoaWRlIHRoZSBwbHltb3V0aCBzcGxhc2gg
Zm9yIHRoZSBjaGVjayByZWFsbHkKIFsgLWUgJGxpdmVkZXYgXSAmIGZzPSQoYmxraWQgLXMgVFlQ
RSAtbyB2YWx1ZSAkbGl2ZWRldikKIGlmIFsgIiRmcyIgPSAiaXNvOTY2MCIgLW8gIiRmcyIgPSAi
dWRmIiBdOyB0aGVuCkBAIC0xMzIsNyArMTM0LDEwIEBACiAgICAgQkFTRV9MT09QREVWPSQoIGxv
c2V0dXAgLWYgKQogICAgIGxvc2V0dXAgLXIgJEJBU0VfTE9PUERFViAkRVhUM0ZTCiAKLSAgICBk
b19saXZlX2Zyb21fYmFzZV9sb29wCisgICAgIyBDcmVhdGUgb3ZlcmxheSBvbmx5IGlmIHRvcmFt
IGlzIG5vdCBzZXQKKyAgICBpZiBbIC16ICIkdG9yYW0iIF0gOyB0aGVuCisgICAgICAgIGRvX2xp
dmVfZnJvbV9iYXNlX2xvb3AKKyAgICBmaQogZmkKIAogIyB3ZSBtaWdodCBoYXZlIGFuIGVtYmVk
ZGVkIGV4dDMgb24gc3F1YXNoZnMgdG8gdXNlIGFzIHJvb3RmcyAoY29tcHJlc3NlZCBsaXZlKQpA
QCAtMTYzLDEzICsxNjgsNzMgQEAKIAogICAgIHVtb3VudCAtbCAvc3F1YXNoZnMKIAotICAgIGRv
X2xpdmVfZnJvbV9iYXNlX2xvb3AKKyAgICAjIENyZWF0ZSBvdmVybGF5IG9ubHkgaWYgdG9yYW0g
aXMgbm90IHNldAorICAgIGlmIFsgLXogIiR0b3JhbSIgXSA7IHRoZW4KKyAgICAgICAgZG9fbGl2
ZV9mcm9tX2Jhc2VfbG9vcAorICAgIGZpCitmaQorCisjIElmIHRoZSBrZXJuZWwgcGFyYW1ldGVy
IHRvcmFtIGlzIHNldCwgY3JlYXRlIGEgdG1wZnMgZGV2aWNlIGFuZCBjb3B5IHRoZSAKKyMgZmls
ZXN5c3RlbSB0byBpdC4gQ29udGludWUgdGhlIGJvb3QgcHJvY2VzcyB3aXRoIHRoaXMgdG1wZnMg
ZGV2aWNlIGFzCisjIGEgd3JpdGFibGUgcm9vdCBkZXZpY2UuCitpZiBbIC1uICIkdG9yYW0iIF0g
OyB0aGVuCisgICAgUk9PVF9JTUFHRT0kKGdldGFyZyByb290KQorICAgIGlmIFsgLXogIiRST09U
X0lNQUdFIiBdOyB0aGVuCisgICAgICAgICBlY2hvICJFUlJPUjogVGhlIHJvb3QgcGFyYW1ldGVy
IHdhcyBub3Qgc2V0LiIKKyAgICAgICAgIGV4aXQKKyAgICBmaQorCisgICAgaWYgWyAhIC1mICIk
Uk9PVF9JTUFHRSIgXTsgdGhlbgorICAgICAgICAgZWNobyAiRVJST1I6IFRoZSByb290IGltYWdl
ICgkUk9PVF9JTUFHRSkgd2FzIG5vdCBmb3VuZC4iCisgICAgICAgICBleGl0CisgICAgZmkKKwor
ICAgIFRNUEZTX1NJWkU9JChnZXRhcmcgc2l6ZSkKKyAgICBpZiBbIC16ICIkVE1QRlNfU0laRSIg
XTsgdGhlbgorICAgICAgICAgZWNobyAiSU5GTzogVGhlIHNpemUgYm9vdCBwYXJhbWV0ZXIgd2Fz
IG5vdCBzZXQuIFVzaW5nIGRlZmF1bHQgWzIwNDhdLiIKKyAgICAgICAgIFRNUEZTX1NJWkU9MjA0
OAorICAgIGZpCisKKyAgICBlY2hvICJVc2Ugcm9vdDogJFJPT1RfSU1BR0UiCisgICAgZWNobyAi
Q3JlYXRlIHRtcGZzIG9mICR7VE1QRlNfU0laRX1tLiIKKyAgICBtb3VudCB0bXBmcyAvc3lzcm9v
dCAtbyBzaXplPSR7VE1QRlNfU0laRX1tLHJ3IC10IHRtcGZzCisgICAgZWNobyAiVGVtcG9yYXJp
bHkgbW91bnQgdGhlIHJvb3QgZGlzayBpbWFnZS4iCisgICAgbWtkaXIgeCB5IHoKKyAgICBtb3Vu
dCAkUk9PVF9JTUFHRSB4IC1vIGxvb3AKKyAgICBtb3VudCB4L0xpdmVPUy9zcXVhc2hmcy5pbWcg
eSAtbyBsb29wCisgICAgbW91bnQgeS9MaXZlT1MvZXh0M2ZzLmltZyB6IC1vIGxvb3AKKyAgICBl
Y2hvICJDb3B5IHJvb3QgZGlzayBpbWFnZSBjb250ZW50cyB0byB0bXBmcy4iCisgICAgY3AgLWZh
cFIgei8qIC9zeXNyb290CisgICAgZWNobyAiQ2xlYW4gdXAuIgorICAgIHVtb3VudCB6CisgICAg
dW1vdW50IHkKKyAgICB1bW91bnQgeAorICAgIHVtb3VudCAtbCAvZGV2Ly5pbml0cmFtZnMvbGl2
ZQorICAgIGVjaG8gIiA+IERldGFjaCAkT1NNSU5fTE9PUERFViIKKyAgICBsb3NldHVwIC1kICRP
U01JTl9MT09QREVWCisKKyAgICBlY2hvICIgPiBEZXRhY2ggJE9TTUlOX1NRVUFTSEVEX0xPT1BE
RVYiCisgICAgbG9zZXR1cCAtZCAkT1NNSU5fU1FVQVNIRURfTE9PUERFVgorICAgIAorICAgIGVj
aG8gIiA+IERldGFjaCAkQkFTRV9MT09QREVWIgorICAgIGxvc2V0dXAgLWQgJEJBU0VfTE9PUERF
VgorICAgIAorICAgIGVjaG8gIiA+IERldGFjaCAkU1FVQVNIRURfTE9PUERFViIKKyAgICBsb3Nl
dHVwIC1kICRTUVVBU0hFRF9MT09QREVWCisgICAgCisgICAgZWNobyAiID4gRGV0YWNoIC9kZXYv
bG9vcDAiCisgICAgbG9zZXR1cCAtZCAvZGV2L2xvb3AwCisKKyAgICA+IC9kZXYvcm9vdAorICAg
IGV4aXQgMAogZmkKIAogaWYgWyAtYiAiJE9TTUlOX0xPT1BERVYiIF07IHRoZW4KICAgICAjIHNl
dCB1cCB0aGUgZGV2aWNlbWFwcGVyIHNuYXBzaG90IGRldmljZSwgd2hpY2ggd2lsbCBtZXJnZQog
ICAgICMgdGhlIG5vcm1hbCBsaXZlIGZzIGltYWdlLCBhbmQgdGhlIGRlbHRhLCBpbnRvIGEgbWlu
aW16aWVkIGZzIGltYWdlCi0gICAgZWNobyAiMCAkKCBibG9ja2RldiAtLWdldHN6ICRCQVNFX0xP
T1BERVYgKSBzbmFwc2hvdCAkQkFTRV9MT09QREVWICRPU01JTl9MT09QREVWIHAgOCIgfCBkbXNl
dHVwIGNyZWF0ZSAtLXJlYWRvbmx5IGxpdmUtb3NpbWctbWluCisgICAgaWYgWyAteiAiJHRvcmFt
IiBdIDsgdGhlbgorICAgICAgICBlY2hvICIwICQoIGJsb2NrZGV2IC0tZ2V0c3ogJEJBU0VfTE9P
UERFViApIHNuYXBzaG90ICRCQVNFX0xPT1BERVYgJE9TTUlOX0xPT1BERVYgcCA4IiB8IGRtc2V0
dXAgY3JlYXRlIC0tcmVhZG9ubHkgbGl2ZS1vc2ltZy1taW4KKyAgICBmaQogZmkKIAogUk9PVEZM
QUdTPSIkKGdldGFyZyByb290ZmxhZ3MpIgo=
EOF

cat /root/dmsquash-live-root.patch.base64 | base64 -d > /root/dmsquash-live-root.patch 

patch /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root /root/dmsquash-live-root.patch 

echo "md5sum for /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root"
md5sum /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root

echo "Changes in /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root"
# For debugging: Show the changes during the build process.
diff -u /root/dmsquash-live-root.backup /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root

echo " "
echo "Contents of /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root"
echo "-----------------------------------"
cat /usr/share/dracut/modules.d/90dmsquash-live/dmsquash-live-root
echo "-----------------------------------"

# This initramfs will be in /boot/ in the filesystem image. Will need to move
# or copy it from the image and into the isolinux directory. See the nochroot
# section below.
echo "Generate new initramfs image(s):"
ls /lib/modules | while read kernel; do
  echo " > Update initramfs for kernel ${kernel}"
  initrdfile="/boot/initramfs-${kernel}.img"

  /sbin/dracut -f $initrdfile $kernel
done

# Here we can probably remove the kernel package and /boot to free some disk
# space. The kernel that is being used is served separately at boot anyway.
%end

# We need to replace the old initrd with our new and updated one that
# supports toram. To do this, we must run %post without chroot and then 
# use the variables $INSTALL_ROOT and $LIVE_ROOT, and then copy the initrd 
# to the isolinux directory.
%post --nochroot
echo "Copy initramfs outside the chroot:"
ls $INSTALL_ROOT/lib/modules | while read kernel; do
  src="$INSTALL_ROOT/boot/initramfs-${kernel}.img"
  dst="$LIVE_ROOT/isolinux/initrd0.img"
  echo " > $src -> $dst"
  cp -f $src $dst
done
%end


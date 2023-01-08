Preparing Boot Media
####################

..  include:: /references.inc

For reasons best left for a later discussion, to set up a D-Star Gateway
control server, you will need to install a 32-bit version of CentOS 5. The last
release of that software was version 5.11 created in 2014. 

Assuming you plan on installing a |DS| Gateway server on a fresh machine, we
need to create a media set suitable for booting the machine into the
installation process. If your machine has a DVD drive, that means creating a
bootable DVD. If not, you should be able to use a USB flash drive to boot the
system, or connect a USB DVD drive. 

Download ISO
************

I downloaded the files needed from this link:

    * http://centos-mirror.jchost.net/5.11/isos/i386/

Although the full release takes two files, we really only need the first of
these. Here is a command that will fetch this file on a Mac/Linux system, or
download the file using your web browser:

..  code-block:: bash

    $ wget http://centos-mirror.jchost.net/5.11/isos/i386/CentOS-5.11-i386-bin-DVD-1of2.iso


Build DVD Boot Disk
*******************

It used to be common for folks to use a DVD drive to load a new OS.
Unfortunately, these are not so common on systems today. I do have a portable USB
DVD drive I use as a backup when I really need to use a DVD. 

I usually try to set up a USB flash drive for installing new operating systems,
but occasionally this does not work. On the server I am building now, the USB
flash drive I created on my MacBook would not boot. Rather than worry about why,
I decided to create a bootable DVD using my portable USB DVD drive.

On the Mac this was super easy. 

    * Plug in the DVD drive
    * Right-click on the ISO filename
    * Select `Burn ISO to DVD Drive`.

The process took several minutes to burn and verify the DVD. Once that was
completed, booting the server went smoothly!

Build USB Boot Drive
********************

In case your system behaves better, here are the steps to build a bootable
(maybe) USB drive on a Mac:

1. Prepare the ISO
==================

We downloaded the ISO earlier. I copy this file into a working directory so I
do not risk losing it.

..  code-block:: bash

    $ cd Downloads
    $ cp CentOS-5.11-i386-bin-DVD-1of2.iso ~/_projects/D-Star/files
    $ cd ~/_projects/D-Star/files
    $ ls
    CentOS-5.11-i386-bin-DVD-1of2.iso

Next, we convert the ISO file into a form the OS can copy to the USB drive:

..  code-block:: bash

    $ hdiutil convert -format UDRW -o ~/_projects/D-Star/files/CentOS5.11-32 ~/_projects/D-Star/files/CentOS-5.11-i386-bin-DVD-1of2.iso 
    Reading CentOS_5.11_Final                (Apple_ISO : 0)…
    ...............................................................................
    Elapsed Time: 24.878s
    Speed: 157.7Mbytes/sec
    Savings: 0.0%
    created: /Users/rblack/_projects/D-Star/files/CentOS5.11-32.dmg

2. Copy to USB
==============

For the next step, we need to mount the USB drive and figure out what device it
ends up using. Plug in the flash drive and make sure you see the drive icon on
the desktop. Then do this:

..  code-block:: bash

    $ diskutil list
    /dev/disk0 (internal, physical):
       #:                       TYPE NAME                    SIZE       IDENTIFIER
       0:      GUID_partition_scheme                        *500.3 GB   disk0
       1:                        EFI EFI                     209.7 MB   disk0s1
       2:          Apple_CoreStorage MacPro2                 499.4 GB   disk0s2
       3:                 Apple_Boot Recovery HD             650.0 MB   disk0s3
    /dev/disk1 (internal, virtual):
       #:                       TYPE NAME                    SIZE       IDENTIFIER
       0:                  Apple_HFS MacPro2                +499.0 GB   disk1
                                     Logical Volume on disk0s2
                                     8A995A0D-E7F4-4659-A116-EDDB369312AA
                                     Unencrypted
    /dev/disk2 (external, physical):
       #:                       TYPE NAME                    SIZE       IDENTIFIER
       0:     FDisk_partition_scheme                        *16.0 GB    disk2
       1:             Windows_FAT_32 Lexar                   16.0 GB    disk2s1

From this output, we see that the flash drive is mounted on ``/dev/disk2``. It
is important to get this right, since we will be wiping out all storage on this
device. You do not want to zap your primary hard disk!

..  code-block:: bash

    $ diskutil unmountDisk /dev/disk2
    Unmount of all volumes on disk2 was successful

The next step does the actual copy:

    $ sudo dd if=~/_projects/D-Star/files/CentOS-5.11-32.dmg of=/dev/disk2 bs=1m
    Password:

This step takes a few minutes to complete, and there is no indication of
progress. Eventually, it will complete.

Booting the Server
******************

Plug the USB flash drive or DVD drive into an available USB port, and power up
the server. Almost all machines have a way to get to the BIOS on power-up, but
exactly how is different for each machine.

On the server I am building I pressed F12 to get to the boot menu. One of the
choices of boot device should be your particular device. Select that device and
start the boot process.

..  vim:filetype=rst spell:

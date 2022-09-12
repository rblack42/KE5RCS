D-Star Notes: Introduction
##########################

..  include:: /references.inc

This website hosts notes I created while rebuilding the gateway servers for two
|DS| repeaters in central Texas. I am new to |DS|, but have a lot of
experience in software design, and I teach Computer Science at the college
level. I thought my experience with Linux systems would let me contribute to
the |DS| community in the area, and they could help me get my equipment
running as well. So, I volunteered to help rebuild two servers that were falling
into disrepair. 

At both sites, we elected to replace aging systems with new systems and
reinstall all of the software from scratch.

..  note::

    These notes are being produced on a MacBook Pro, the system I use for my
    teaching work. I will add material covering the procedures to follow if using
    a Windows machine later.

Why Are You Here?
*****************

If you are reading these notes, you are probably in one of two situations:

    * You need to build up a new |DS| Gateway server from scratch

    * You are rebuilding a |DS| Gateway server than has been in use for a
      while.

Hopefully, these notes will help in both situations. The real difference in the
two situations involves capturing existing data on a running server and
reinstalling those data on the rebuilt server.

Unlike other references you might find on the Internet, I am going to do
something different here. Instead of just telling you to "run this script", I
am going to show you exactly what the script does. Then I will attempt to
devise a test that you can run to make sure that script (or portion of a script)
did what it was supposed to do on your new server.

..  warning::

    Remember that this is a work in progress, and much of the material
    currently posted is incomplete. Check back often to see updates
    
Required Hardware
*****************

The gateway systems at the two repeater sites I am working on had very old
machines that really needed to be replaced. So, we set up new Mini-ITX systems
with SSD hard disk drives and the required two network adapters as
replacements. Neither of these systems has a DVD drive, but they have several
USB ports making software installation easy. 

Here are the basic specifications for the server hardware we used:

    * Processor: Intel I5 G3258 @ 3.2GHz

    * Ram: 8GB (ram is cheap, don't skimp!)

    * 100GB SSD disk

    * Dual Ethernet Adapters

We used a mini-ITX case for these servers, as there is no need for anything bigger.


Required Software
*****************

Setting up a D-Star gateway requires access to the official Icom_ Gateway
Software, which is distributed with the repeater hardware. Icom_ has chosen to
make this software closed source, and the setup requires very specific versions
of operating system and other components. I am not happy about this, since many
of these requirements are very old, and may soon be unsupported. In order to
keep |DS| a viable system for Amateur Radio users, this has to change. 

That topic is best left to other forums. For this site, I will keep my opinions
to myself, and show how our repeaters were set up.

..  vim:filetype=rst spell:


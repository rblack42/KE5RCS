Summary of Build Process
########################

..  include::   /references.inc

Setting up a |DS| gateway server is not difficult, but there are many steps to be worked through, and confirming things are properly in place it not well documented. Testing of components is just not discussed in the references I have seen.

I am attempting to document the process in sufficient detail that a novice administrtor can get a system working in a reasonable way, and be confident that the system is working properly. Accordingly, I will show the steps that need to be followed, and include system check commands that confirm that each step suceeded in setting up a single component of the system. 

..  warning::

    The site is visible now, but the testing steps are a work in progress. I will update these notes as I wor through the installation process in detail.

The Basic Steps
***************

Here is alist of the steps we need to complete to get the gateway server running. This list links to pages that detail the procedures to follow for each step.

The starting point for this process is a clean system with no operating system installed. Tools are available to reformat the hard drive of a system, and that is a good way t make sure your hard disk is free of old "junk"

    * `Create Boot Media for the OS <BootMedia.html>`_

    * `Configure your Network <../Network/RouterSetup.html>`_

    * `Install CentOS 5.11 <../CentOS_install.html>`_

        * `Install CentOS 5.11 in a VM <../Appendix/CentOS_VM.html>`_

    * `Configure DNS <DNSInstall.html>`_

    * `Install Icom Gateway Software <../GatewayInstall>`_

        * 

    * Restore Backup Data

    * `Install G2 Updates <../G2Updates>`_

    * Restore Postgres Database

    * Configure ``DstarMonitor``

    * `Configure dplus <../DplusInstall>`_

    * `Managing the Gateway <../ControlScripts>`_




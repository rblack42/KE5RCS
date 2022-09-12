Gateway Network Setup
#####################

..  include::   /references.inc

Once the CentOS operating system is installed, you will need to configure the
network adapters as required for |DS| operation. 

Two adapters are needed on the gateway server. One, ``eth0`` connects the
gateway to the router and through thta to the Internet. The second, ``eth1`` is
connected to the repeater ID-RP2C Repeater Controller.  This device controls
the repeater voice and data radio systems.

You can configure the adapters using the server GUI interface, or you can use
the command line. I choose the command line as much as possible, since most of
my work on servers is fone remotely.

..  warning::

    Configuring network adapters remotely is risky business. Mess things up and
    you will not have access to the server!

Primary Adapter: eth0
*********************

This adapter is configured with a static IP address:

    * IP: 10.0.0.2

    * NetMask: 255.255.255.0

    * Acivate on Boot


Secondary Adapter: eth1
***********************

This adapter is also set with a static IP address:

    * IP: 176.16.0.20

    * NetMask: 255.0.0.0

    * Gateway: 10.0.0.1

    * Primary DNS: 127.0.0.1

    * Activate on Boot

Configuring from the Command Line
*********************************

The adapter settings can be configured by editing two scripts from the command
line:

:/etc/sysconfig/network-scripts/ifcfg-eth0:

..  code-block:: text

    # VIA Technologies, Inc. VT6105/VT6106S [Rhine-III]
    DEVICE=eth0
    BOOTPROTO=none
    HWADDR=2C:27:D7:32:6A:C3
    ONBOOT=yes
    DHCP_HOSTNAME=ke5rcs
    IPADDR=10.0.0.2
    NETMASK=255.255.255.0
    GATEWAY=10.0.0.1
    TYPE=Ethernet
    USERCTL=no
    IPV6INIT=no
    PEERDNS=yes

:/etc/sysconfig/network-scripts/ifcfg-eth0:

..  code-block:: text

    # Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller
    DEVICE=eth1
    BOOTPROTO=none
    HWADDR=00:21:2F:50:77:4A
    ONBOOT=yes
    DHCP_HOSTNAME=ke5rcs
    TYPE=Ethernet
    IPADDR=172.16.0.20
    NETMASK=255.0.0.0
    USERCTL=no
    IPV6INIT=no
    PEERDNS=yes


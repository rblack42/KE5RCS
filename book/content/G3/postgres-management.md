# Postgres Management

Postgress is a database system used by D-Star gateway machines to track user
data. Each gateway synchronizes that user data with the U.S. Trust system so
D-Star users can use callsigns to route data moved over the Internet during calls.

In thi note, we will set up an administrator system so Postgres databases on the gatwway machine cna be managed ueasily using a free tool named *pg Admin 4*.

Ref: https://medium.com/@malexmad/how-to-use-pgadmin-a9addc7ff46c


## SSH Tunneling

Most gateway administrators set up a secure SSH access scheme allowing the to log in to the gateway server from a remote location. This gives them access to a shell running on the gateway machine where commands cna be run to manage the machine. The interface is called the command line, something that has been a part of computing forever, but also something that many administrators are not familiar with!. Managing a database using command line is certainly possible, but is is painful. *pg Admin 4* is a more common graphical tool run as an application on the administrator's local machine that access the remote database by sending commands to the managed machine and fetching the results for display in a nice visual interface.

To make that happen we will use an *SSH Tunnel* as the communication channel between the two machines. To make this happen, we have some setup work to do.


## D-Star Database Tables

- sync_gip
- sync_mng
- sync_rip
- unsync_mng
- unsync_multicast_mng
- unsync_user_mng: basic user info and hashed password

## Install Webmin

- Ref: https://doxfer.webmin.com/Webmin/Installation#yum_.28CentOS.2FRedHat.2FFedora.29

(echo "[Webmin]
name=Webmin Distribution Neutral
baseurl=http://download.webmin.com/download/yum
enabled=1
gpgcheck=1
gpgkey=http://www.webmin.com/jcameron-key.asc" >/etc/yum.repos.d/webmin.repo;
yum -y install webmin)




Webmin Setup on Centos 7
------------------------

yum -y update

yum -y install perl perl-Net-SSLeay openssl perl-IO-Tty perl-Encode-Detect

nano /etc/yum.repos.d/webmin.repo

Add these lines
-----
[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1
-----

wget http://www.webmin.com/jcameron-key.asc

rpm --import jcameron-key.asc

yum -y install webmin

firewall-cmd --zone=public --add-port=10000/tcp --permanent

firewall-cmd --reload

You can now access Webmin on https://Your_Server_IP:10000

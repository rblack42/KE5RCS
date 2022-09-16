#!/bin/sh

# CD-drectory
CDROM=`pwd`

###### install() #######
install(){
## check installed files
#0 find /opt/products -> uninstall
if [ -d /opt/products ];then
	echo "*** find 'installed-files(/opt/products)' *** (0)" | tee -a ~/dstar_gw-install.log
	echo "Do you want to backup(/opt/products) and uninstall? (Y/n)"
	echo "(and ReInstall)"
	read ans
	case ${ans} in
		[yY])	DATE=`date +"%y%m%d_%H%M%S"`
				mv -f /opt/products /opt/products.$DATE
				uninstall
				if [ -d /opt/products ];then
					echo "*** backup failed. ***(0-1)"
					return 1
				fi
				echo "*** start reinstall. ***"
				;;
		*)		echo "*** backup failed. ***(0-2)"
				return 1
				;;
	esac
else
	true
fi

#0.1 installer exists in current-directory
if [ ! -f ./dstar_gw-install ];then
	echo "** You must do this operation in same directory as 'dstar_gw-install' (0.1)" | tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

###### step1 ###### (prepare)
#1 make group-dstar
groupadd dstar 2>/dev/null
case $? in 
	0)	;;
	9)	echo "*** Already groupadd dstar *** (1)"| tee -a ~/dstar_gw-install.log
		;;
	*)	echo "error:groupadd dstar failed. (1)"| tee -a ~/dstar_gw-install.log
		return 1
		;;
esac

#2,3 make user-dstar and password
#    failed: 'option -p' -> 'passwd'
#    find user-dstar -> delete user, make group-dstar -> back to useradd
#    another-error -> exit
useradd -d /home/dstar -m -g dstar -p '{{ default-dstar-password }}' dstar 2>/dev/null
ExVal=$?
while [ ${ExVal} != 0 ];
do
	case ${ExVal} in
		9)	echo "delete user 'dstar'? (Y/n) "
			read ans
			case ${ans} in
				[yY])	mktemp -q /tmp/ds_inst 1>/dev/null
						/tmp/dsinst/disp.sh &
						DATE=`date +"%y%m%d_%H%M%S"`
						cd /home
						tar cfvz dstar.$DATE.tar.gz dstar
						cd -
						userdel -r dstar
						rm -f /tmp/ds_inst
						case $? in
							0)	;;
							12)	echo "can't remove home directory(2.3-1)"| tee -a ~/dstar_gw-install.log
								rm -rf /home/dstar
								;;
							*)	echo "error:userdel dstar failed. (2,3-2)"| tee -a ~/dstar_gw-install.log
								return 1
								;;
						esac
						groupadd dstar
						if [ $? != 0 ];then
							echo "error:groupadd dstar failed. (2,3-3)"| tee -a ~/dstar_gw-install.log
							return 1
						else
							true
						fi
						;;
				*)		echo "error:useradd dstar failed. (2,3-4)"| tee -a ~/dstar_gw-install.log
						return 1
						;;
			esac
			ans=""
			;;
		3)	useradd -d /home/dstar -m -g dstar dstar
			if [ $? != 0 ];then
				echo "error:useradd dstar failed. (2,3-5)"| tee -a ~/dstar_gw-install.log
				return 1
			else
				echo "type 'dstar123'"
				passwd dstar
				if [ $? != 0 ];then
					echo "error:passwd dstar failed. (2,3-6)"| tee -a ~/dstar_gw-install.log
					return 1
				else
					true
				fi
				break
			fi
			;;
		*)	echo "error:useradd dstar failed. (2,3-7)"| tee -a ~/dstar_gw-install.log
			return 1
			;;
	esac
useradd -d /home/dstar -m -g dstar -p '{{ default-dstar-password }}' dstar
ExVal=$?
done

#4 make group-postgres
groupadd postgres
case $? in
	0)	;;
	9)	echo "*** Already groupadd postgres. *** (4)"| tee -a ~/dstar_gw-install.log
		;;
	*)	echo "error:groupadd postgres failed. (4)"| tee -a ~/dstar_gw-install.log
		return 1
		;;
esac

#5,6 make user-dstar and password
#    failed: 'option -p' -> 'passwd'
#    find user-dstar -> delete user, make group-dstar -> back to useradd
#    another-error -> exit
useradd -d /home/postgres -m -g postgres -p '{{ default-postgres-password }}' postgres
ExVal=$?
while [ ${ExVal} != 0 ];
do
	case ${ExVal} in
		9)	echo "delete user 'postgres'? (Y/n) "
			read ans
			case ${ans} in
				[yY])	mktemp -q /tmp/ds_inst 1>/dev/null
						/tmp/dsinst/disp.sh &
						DATE=`date +"%y%m%d_%H%M%S"`
						cd /home
						tar cfvz postgres.$DATE.tar.gz postgres
						cd -
						userdel -r postgres
						rm -f /tmp/ds_inst
						case $? in
							0)	;;
							12)	echo "can't remove home directory(5,6-1)"| tee -a ~/dstar_gw-install.log
								rm -rf /home/postgres
								;;
							*)	echo "error:userdel dstar failed. (5,6-2)"| tee -a ~/dstar_gw-install.log
								return 1
								;;
						esac
						groupadd postgres
						if [ $? != 0 ];then
							echo "error:groupadd postgres failed. (5,6-3)"| tee -a ~/dstar_gw-install.log
							return 1
						else
							true
						fi
						;;
				*)		echo "error:useradd postgres failed. (5,6-4)"| tee -a ~/dstar_gw-install.log
						return 1
						;;
			esac
			ans=""
			;;
		3)	useradd -d /home/postgres -m -g postgres postgres
			if [ $? != 0 ];then
				echo "error:useradd postgres failed. (5,6-5)"| tee -a ~/dstar_gw-install.log
				return 1
			else
				passwd postgres
				if [ $? != 0 ];then
					echo "error:passwd postgres failed. (5,6-6)"| tee -a ~/dstar_gw-install.log
					return 1
				else
					true
				fi
				break
			fi
			;;
		*)	echo "error:useradd postgres failed. (5,6-7)"| tee -a ~/dstar_gw-install.log
			return 1
			;;
	esac
useradd -d /home/postgres -m -g postgres -p '{{ default-postgres-password }}' postgres
ExVal=$?
done

mktemp -q /tmp/ds_inst 1>/dev/null
/tmp/dsinst/disp.sh &

#6.1 backup /root/.bashrc
if [ -f ~/.bashrc ]
then 
	cp ~/.bashrc ~/.bashrc.old
	if [ $? != 0 ];then
		echo "error: Make '~/.bashrc backup' failed. (6.1)"| tee -a ~/dstar_gw-install.log
		return 1
	else
		true
	fi
else
	true #no backup
fi

#6.2 backup /home/dstar/.bashrc
if [ -f /home/dstar/.bashrc ]
then
	cp /home/dstar/.bashrc /home/dstar/.bashrc.old
	if [ $? != 0 ];then
		echo "error:Make '/home/dstar/.bashrc' backup failed. (6.2)"| tee -a ~/dstar_gw-install.log
		return 1
	else
		true
	fi
else
	true #no backup
fi

#6.3 backup /home/postgres/.bashrc
if [ -f /home/postgres/.bashrc ]
then
	cp /home/postgres/.bashrc /home/postgres/.bashrc.old
	if [ $? != 0 ];then
		echo "error:Make '/home/postgres/.bashrc' backup failed. (6.3)"| tee -a ~/dstar_gw-install.log
		return 1
	else
		true
	fi
else
	true #no backup
fi

#7 add PATH to root-environment
cat /tmp/dsinst/root.bashrc | tee -a ~/.bashrc
if [ $? != 0 ];then
	echo "error:Concatenate PATH to '~/.bashrc' failed. (7)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#7.1 reload root-environment
source ~/.bashrc
if [ $? != 0 ];then
	echo "error:Failed to 'source ~/.bashrc'. (7.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#8 add PATH to dstar-environment
cat /tmp/dsinst/dstar.bashrc | tee -a /home/dstar/.bashrc
if [ $? != 0 ];then
	echo "error:Concatenate PATH to '/home/dstar/.bashrc' failed. (8)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#9 add PATH to postgres-environment
cat /tmp/dsinst/postgres.bashrc | tee -a /home/postgres/.bashrc
if [ $? != 0 ];then
	echo "error:Concatenate PATH to '/home/postgres/.bashrc' failed. (9)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#10 copy CD-ROM/apl to /home/dstar/
cp -R ${CDROM}/apl /home/dstar/
if [ $? != 0 ];then
	echo "error:Copy '"${CDROM}"/apl' to '/home/dstar/' failed. (10)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#11 copy CD-ROM/DDL to /home/dstar/
cp -R ${CDROM}/DDL /home/dstar/
if [ $? != 0 ];then
	echo "error:Copy '"${CDROM}"/DDL' to '/home/dstar/' failed. (11)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#12 copy CD-ROM/middle to /home/dstar/
cp -R ${CDROM}/middle /home/dstar/
if [ $? != 0 ];then
	echo "error:Copy '"${CDROM}"/middle' to '/home/dstar/' failed. (12)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#13 copy CD-ROM/rpm to /home/dstar/
#cp -R ${CDROM}/rpm /home/dstar/
#if [ $? != 0 ];then
#	echo "error:Copy '"${CDROM}"/rpm' to '/home/dstar/' failed. (13)"| tee -a ~/dstar_gw-install.log
#	return 1
#else
#	true
#fi

#14 change /home/dstar/* owner and group
chown -R dstar:dstar /home/dstar/*
if [ $? != 0 ];then
	echo "error:Change '/home/dstar/*' owner and group failed. (14)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#15 make directories: /opt/products
mkdir /opt/products
if [ $? != 0 ];then
	echo "error:Make '/opt/products' failed. (15)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#16 make directories: /opt/products/dstar/openssl-0.9.8d
mkdir /opt/products/dstar
if [ $? != 0 ];then
	echo "error:Make '/opt/products/dstar' failed. (16)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#17 make directories: /opt/products/dstar/openssl-0.9.8d
mkdir /opt/products/dstar/openssl-0.9.8d
if [ $? != 0 ];then
	echo "error:Make '/opt/products/dstar/openssl-0.9.8d' failed. (17)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#18 make directories: /opt/products/dstar/httpd-2.0.59
mkdir /opt/products/dstar/httpd-2.0.59
if [ $? != 0 ];then
	echo "error:Make '/opt/products/dstar/httpd-2.0.59' failed. (18)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#19 change /opt/products/dstar owner and group
chown -R dstar.dstar /opt/products/dstar
if [ $? != 0 ];then
	echo "error:Change '/opt/products/dstar' owner and group failed. (19)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#19.1 change permission /home/dstar/middle/jdk-1_5_0_09-linux-i586.bin
chmod 755 /home/dstar/middle/jdk-1_5_0_09-linux-i586.bin
if [ $? != 0 ];then
	echo "error:Change '/home/dstar/middle/jdk-1_5_0_09-linux-i586.bin' access permissions failed. (19.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#20 copy home/dstar/middle/jdk-1_5_0_09-linux-i586.bin to /opt/products/dstar/
cp /home/dstar/middle/jdk-1_5_0_09-linux-i586.bin /opt/products/dstar/
if [ $? != 0 ];then
	echo "error:Copy '/home/dstar/middle/jdk-1_5_0_09-linux-i586.bin' to '/opt/products/dstar/' failed. (20)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#21 copy /home/dstar/DDL to /home/postgres/
cp -pr /home/dstar/DDL /home/postgres/
if [ $? != 0 ];then
	echo "error:Copy '/home/dstar/DDL' to '/home/postgres/' failed. (21)"| tee -a ~/dstar_gw-install.log
	return 1;
else
	true
fi

#22 change /home/postgres/DDL owner and group
chown -R postgres:postgres /home/postgres/DDL
if [ $? != 0 ];then
	echo "error:Change '/home/postgres/DDL' owner and group failed. (22)"| tee -a ~/dstar_gw-install.log
	return 1;
else
	true
fi

#23 copy /home/dstar/apl/dstar_gw.tar.gz to /opt/products/dstar/
cp -pr /home/dstar/apl/dstar_gw.tar.gz /opt/products/dstar/
if [ $? != 0 ];then
	echo "error:Copy '/home/dstar/apl/dstar_gw.tar.gz' to '/opt/products/dstar/' failed. (23)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

rm -f /tmp/ds_inst
echo

#24 Expand files from /home/dstar/middle/openssl-0.9.8d.tar.gz
gunzip /home/dstar/middle/openssl-0.9.8d.tar.gz
if [ $? != 0 ];then
	echo "error:Expand files from 'home/dstar/middle/openssl-0.9.8d.tar.gz' failed. (24)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#24.1 Expand files from /home/dstar/middle/openssl-0.9.8d.tar to /home/dstar/middle/
tar -C /home/dstar/middle/ -xvf /home/dstar/middle/openssl-0.9.8d.tar
if [ $? != 0 ];then
	echo "error:Extract files from 'home/dstar/middle/openssl-0.9.8d.tar' to '/home/dstar/middle/' failed. (24.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#25 change /home/dstar/middle/openssl-0.9.8d owner and group
chown -R dstar.dstar /home/dstar/middle/openssl-0.9.8d
if [ $? != 0 ];then
	echo "error:Change '/home/dstar/middle/openssl-0.9.8d' owner and group failed. (25)"| tee -a ~/dstar_gw-install.log
	return 1;
else
	true
fi

#26 Expand files from /home/dstar/middle/apache-tomcat-5.5.20.tar.gz
gunzip /home/dstar/middle/apache-tomcat-5.5.20.tar.gz
if [ $? != 0 ];then
	echo "error:Expand files from '/home/dstar/middle/apache-tomcat-5.5.20.tar.gz' failed. (26)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#26.1 Expand files from /home/dstar/middle/apache-tomcat-5.5.20.tar to /home/dstar/middle/
tar -C /home/dstar/middle/ -xvf /home/dstar/middle/apache-tomcat-5.5.20.tar
if [ $? != 0 ];then
	echo "error:Extract files from 'home/dstar/middle/apache-tomcat-5.5.20.tar' to '/home/dstar/middle/' failed. (26.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#27 Movw /home/dstar/middle/apache-tomcat-5.5.20 to /opt/products/dstar/
mv /home/dstar/middle/apache-tomcat-5.5.20 /opt/products/dstar/
if [ $? != 0 ];then
	echo "error:Move '/home/dstar/middle/apache-tomcat-5.5.20' to '/opt/products/dstar/' failed. (27)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#28 change /opt/products/dstar/apache-tomcat-5.5.20 owner and group
chown -R dstar.dstar /opt/products/dstar/apache-tomcat-5.5.20
if [ $? != 0 ];then
	echo "error:Change '/opt/products/dstar/apache-tomcat-5.5.20' owner and group failed. (28)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#29 Change the current directory to '/opt/products/dstar/'
cd /opt/products/dstar/
if [ $? != 0 ];then
	echo "error:Change the current directory to '/opt/products/dstar/' failed. (29)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#29.1 Make symbolic link 'apache-tomcat-5.5.20' to 'tomcat'
ln -s apache-tomcat-5.5.20 tomcat
if [ $? != 0 ];then
	echo "error:Make symbolic link 'apache-tomcat-5.5.20' to 'tomcat'"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#30 change /opt/products/dstar/tomcat owner and grouop
chown -R dstar.dstar /opt/products/dstar/tomcat
if [ $? != 0 ];then
	echo "error:Change /opt/products/dstar/tomcat owner and group failed. (30)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#31 Expand files from /home/dstar/middle/httpd-2.0.59.tar.gz
gunzip /home/dstar/middle/httpd-2.0.59.tar.gz
if [ $? != 0 ];then
	echo "error:Expand files from '/home/dstar/middle/httpd-2.0.59.tar.gz' failed. (31)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#31.1 Extract files from '/home/dstar/middle/httpd-2.0.59.tar' to '/home/dstar/middle/'
tar -C /home/dstar/middle/ -xvf /home/dstar/middle/httpd-2.0.59.tar
if [ $? != 0 ];then
	echo "error:Extract files from '/home/dstar/middle/httpd-2.0.59.tar' to '/home/dstar/middle/' failed. (31.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#32 change '/home/dstar/middle/httpd-2.0.59' owner and group
chown -R dstar.dstar /home/dstar/middle/httpd-2.0.59
if [ $? != 0 ];then
	echo "error:Failed to change '/home/dstar/middle/httpd-2.0.59' owner and group. (32)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#33 expand files from /home/dstar/middle/jakarta-tomcat-connectors-jk2-src-current.tar.gz
gunzip /home/dstar/middle/jakarta-tomcat-connectors-jk2-src-current.tar.gz
if [ $? != 0 ];then
	echo "error:Failed to expand files from '/home/dstar/middle/jakarta-tomcat-connectors-jk2-src-current.tar.gz'. (33)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#33.1 extract files from '/home/dstar/middle/jakarta-tomcat-connectors-jk2-src-current.tar' to '/home/dstar/middle/'
tar -C /home/dstar/middle/ -xvf /home/dstar/middle/jakarta-tomcat-connectors-jk2-src-current.tar
if [ $? != 0 ];then
	echo "error:Failed to extract files from '/home/dstar/middle/jakarta-tomcat-connectors-jk2-src-current.tar' to '/home/dstar/middle/'. (33.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#34 change '/home/dstar/middle/jakarta-tomcat-connectors-jk2-2.0.4-src/' owner and group
chown -R dstar.dstar /home/dstar/middle/jakarta-tomcat-connectors-jk2-2.0.4-src/
if [ $? != 0 ];then
	echo "error:Failed to change '/home/dstar/middle/jakarta-tomcat-connectors-jk2-2.0.4-src/' owner and group. (34)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#35 extract files from '/home/dstar/middle/postgresql-8.2.3.tar' to '/home/dstar/middle/'
tar -C /home/dstar/middle/ -xvf  /home/dstar/middle/postgresql-8.2.3.tar
if [ $? != 0 ];then
	echo "error:Failed to extract files from '/home/dstar/middle/postgresql-8.2.3.tar' to '/home/dstar/middle/'. (35)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#36 change '/home/dstar/middle/postgresql-8.2.3' owner and group
chown -R dstar.dstar /home/dstar/middle/postgresql-8.2.3
if [ $? != 0 ];then
	echo "error:Failed to change '/home/dstar/middle/postgresql-8.2.3' owner and group. (36)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#37 Expand files from /opt/products/dstar/dstar_gw.tar.gz
gunzip /opt/products/dstar/dstar_gw.tar.gz
if [ $? != 0 ];then
	echo "error:Failed to Expand files from '/opt/products/dstar/dstar_gw.tar.gz'. (37)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#37.1 extract files from '/opt/products/dstar/dstar_gw.tar' to '/opt/products/dstar'
tar -C /opt/products/dstar -xvf /opt/products/dstar/dstar_gw.tar
if [ $? != 0 ];then
	echo "error:Failed to extract files from '/opt/products/dstar/dstar_gw.tar' to '/opt/products/dstar'. (37.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#38 change '/opt/products/dstar/dstar_gw' owner and group
chown -R dstar.dstar /opt/products/dstar/dstar_gw
if [ $? != 0 ];then
	echo "error:Failed to change '/opt/products/dstar/dstar_gw' owner and group. (38)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#39 copy '/home/dstar/middle/postgresql-8.2-504.jdbc3.jar' to '/opt/products/dstar/apache-tomcat-5.5.20/common/lib/'
cp -pr /home/dstar/middle/postgresql-8.2-504.jdbc3.jar /opt/products/dstar/apache-tomcat-5.5.20/common/lib/
if [ $? != 0 ];then
	echo "error:Failed to copy '/home/dstar/middle/postgresql-8.2-504.jdbc3.jar' to '/opt/products/dstar/apache-tomcat-5.5.20/common/lib/'"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#40 copy '/home/dstar/apl/dstar_cgi.tar.gz' to '/opt/products/dstar/apache-tomcat-5.5.20/webapps/'
cp -pr /home/dstar/apl/dstar_cgi.tar.gz /opt/products/dstar/apache-tomcat-5.5.20/webapps/
if [ $? != 0 ];then
	echo "error:Failed to copy '/home/dstar/apl/dstar_cgi.tar.gz' to '/opt/products/dstar/apache-tomcat-5.5.20/webapps/'"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#41 Expand files from '/opt/products/dstar/tomcat/webapps/dstar_cgi.tar.gz'
gunzip /opt/products/dstar/tomcat/webapps/dstar_cgi.tar.gz
if [ $? != 0 ];then
	echo "error:Failed to Expand files from '/opt/products/dstar/tomcat/webapps/dstar_cgi.tar.gz'. (41)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#41.1 extract files from '/opt/products/dstar/tomcat/webapps/dstar_cgi.tar' to '/opt/products/dstar/tomcat/webapps/'
tar -C /opt/products/dstar/tomcat/webapps/ -xvf /opt/products/dstar/tomcat/webapps/dstar_cgi.tar
if [ $? != 0 ];then
	echo "error:error:Failed to extract files from '/opt/products/dstar/tomcat/webapps/dstar_cgi.tar' to '/opt/products/dstar/tomcat/webapps/'. (41.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#42 change '/opt/products/dstar/tomcat/webapps/*' owner and group
chown -R dstar.dstar /opt/products/dstar/tomcat/webapps/*
if [ $? != 0 ];then
	echo "error:Failed to change '/opt/products/dstar/tomcat/webapps/*' owner and group. (42)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

###### step2 ###### user-dstar install
#43 execute jdk-1_5_0_09-linux-i586.bin
su - dstar -c'
cd /opt/products/dstar/
./jdk-1_5_0_09-linux-i586.bin
'
if [ $? != 0 ];then
	echo "error:Failed to jdk-1_5_0_09-linux-i586.bin. (43)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#44 delete '/opt/products/dstar/jdk-1_5_0_09-linux-i586.bin'
su - dstar -c 'rm -rf /opt/products/dstar/jdk-1_5_0_09-linux-i586.bin'
if [ $? != 0 ];then
	echo "error:Failed to remove '/opt/products/dstar/jdk-1_5_0_09-linux-i586.bin'. (44)"| tee -a ~/dstar_gw-install.log
	return 1
fi

#45 make symbolic link '/opt/products/dstar/jdk1.5.0_09' to '/opt/products/dstar/j2se'
su - dstar -c '
cd /opt/products/dstar/
ln -s jdk1.5.0_09 j2se
'
if [ $? != 0 ];then
	echo "error:Failed to make symbolic link '/opt/products/dstar/jdk1.5.0_09' to '/opt/products/dstar/j2se'. (45)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#46 configuration openssl-install
su - dstar -c '
cd /home/dstar/middle/openssl-0.9.8d/
./config --prefix=/opt/products/dstar/openssl-0.9.8d
'
if [ $? != 0 ];then
	echo "error:Failed to 'config --prefix=/opt/products/dstar/openssl-0.9.8d'. (46)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#47 make-openssl
su - dstar -c '
cd /home/dstar/middle/openssl-0.9.8d/
make
'
if [ $? != 0 ];then
	echo "error:Failed to make for openssl. (47)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#48 make install - openssl
su - dstar -c '
cd /home/dstar/middle/openssl-0.9.8d/
make install
'
if [ $? != 0 ];then
	echo "error:Failed to 'make install' for openssl. (48)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#49 make symbolic link '/opt/products/dstar/openssl-0.9.8d' to '/opt/products/dstar/open-ssl'
su - dstar -c '
cd /opt/products/dstar/
ln -s openssl-0.9.8d open-ssl
'
if [ $? != 0 ];then
	echo "error:Failed to make symbolic link '/opt/products/dstar/openssl-0.9.8d' to '/opt/products/dstar/open-ssl'. (49)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#50 configuration httpd-install
su - dstar -c '
cd /home/dstar/middle/httpd-2.0.59/
./configure --prefix=/opt/products/dstar/httpd-2.0.59 --enable-module=so --enable-ssl
'
if [ $? != 0 ];then
	echo "error:Failed to './configure --prefix=/opt/products/dstar/httpd-2.0.59 --enable-module=so --enable-ssl'. (50)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#51 make-httpd
su - dstar -c '
cd /home/dstar/middle/httpd-2.0.59/
make
'
if [ $? != 0 ];then
	echo "error:Failed to make for httpd. (51)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#52 make install - httpd
su - dstar -c '
cd /home/dstar/middle/httpd-2.0.59/
make install
'
if [ $? != 0 ];then
	echo "error:Failed to 'make install' for httpd. (52)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#53 make symbolic link '/opt/products/dstar/httpd-2.0.59' to '/opt/products/dstar/apache'
su - dstar -c '
cd /opt/products/dstar/
ln -s httpd-2.0.59 apache
'
if [ $? != 0 ];then
	echo "error:Failed to make symbolic link '/opt/products/dstar/httpd-2.0.59' to '/opt/products/dstar/apache'. (53)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#54 copy '/home/dstar/middle/sslkey/*' to '/opt/products/dstar/apache/conf/'
su - dstar -c 'cp -pr /home/dstar/middle/sslkey/* /opt/products/dstar/apache/conf/'
if [ $? != 0 ];then
	echo "error:Failed to copy '/home/dstar/middle/sslkey/*' to '/opt/products/dstar/apache/conf/'. (54)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#55 copy '/home/dstar/middle/dstarssl.conf' to '/opt/products/dstar/apache/conf/'
su - dstar -c 'cp -p /home/dstar/middle/dstarssl.conf /opt/products/dstar/apache/conf/'
if [ $? != 0 ];then
	echo "error:Failed to copy '/home/dstar/middle/dstarssl.conf' to '/opt/products/dstar/apache/conf/'. (55)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#56 copy '/opt/products/dstar/httpd-2.0.59/conf/httpd.conf' to '/opt/products/dstar/httpd-2.0.59/conf/httpd.conf.org'
su - dstar -c 'cp /opt/products/dstar/httpd-2.0.59/conf/httpd.conf /opt/products/dstar/httpd-2.0.59/conf/httpd.conf.org'
if [ $? != 0 ];then
	echo "error:Faile to copy '/opt/products/dstar/httpd-2.0.59/conf/httpd.conf' to '/opt/products/dstar/httpd-2.0.59/conf/httpd.conf.org'. (56)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#57 configuration tomcat
su - dstar -c '
cd /home/dstar/middle/jakarta-tomcat-connectors-jk2-2.0.4-src/jk/native2/
./configure --with-apxs2=/opt/products/dstar/apache/bin/apxs
'
if [ $? != 0 ];then
	echo "error:Failed to './configure --with-apxs2=/opt/products/dstar/apache/bin/apxs' for tomacat. (57)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#58 make tomcat
su - dstar -c '
cd /home/dstar/middle/jakarta-tomcat-connectors-jk2-2.0.4-src/jk/native2/
make
'
if [ $? != 0 ];then
	echo "error:Failed to make for tomacat. (58)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#59 copy '/home/dstar/middle/jakarta-tomcat-connectors-jk2-2.0.4-src/jk/build/jk2/apache2/mod_jk2.so' to '/opt/products/dstar/httpd-2.0.59/modules/'
su - dstar -c 'cp /home/dstar/middle/jakarta-tomcat-connectors-jk2-2.0.4-src/jk/build/jk2/apache2/mod_jk2.so /opt/products/dstar/httpd-2.0.59/modules/'
if [ $? != 0 ];then
	echo "error:Failed to copy '/home/dstar/middle/jakarta-tomcat-connectors-jk2-2.0.4-src/jk/build/jk2/apache2/mod_jk2.so' to '/opt/products/dstar/httpd-2.0.59/modules/'. (59)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#60 copy '/home/dstar/middle/workers2.properties' to '/opt/products/dstar/httpd-2.0.59/conf/
su - dstar -c 'cp /home/dstar/middle/workers2.properties /opt/products/dstar/httpd-2.0.59/conf/'
if [ $? != 0 ];then
	echo "error:Faled to copy '/home/dstar/middle/workers2.properties' to '/opt/products/dstar/httpd-2.0.59/conf/'. (60)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#61 configuration postgresql-install
su - dstar -c '
cd /home/dstar/middle/postgresql-8.2.3/
./configure --prefix=/opt/products/dstar/pgsql-8.2.3 --enable-thread-safety --without-readline --without-zlib
'
if [ $? != 0 ];then
	echo "error:Failed to './configure --prefix=/opt/products/dstar/pgsql-8.2.3 --enable-thread-safety --without-readline --without-zlib' for pgsql. (61)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#62 gmake postgresql 
su - dstar -c '
cd /home/dstar/middle/postgresql-8.2.3/
gmake
'
if [ $? != 0 ];then
	echo "error:Failed to gmake for postgresql. (62)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

###### step3 ###### configuration
#62.1 edit '/var/spool/cron/root'
cat /opt/products/dstar/dstar_gw/cron/root.cron >> /var/spool/cron/root
if [ $? != 0 ];then
	echo "error:Failed to edit '/var/spool/cron/root'. (62.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#62.2 edit '/var/spool/cron/postgres'
cat /opt/products/dstar/dstar_gw/cron/postgres.cron >> /var/spool/cron/postgres
if [ $? != 0 ];then
	echo "error:Failed to edit '/var/spool/cron/postgres'. (62.2)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#62.3 copy '/etc/syslog.conf' to '/etc/syslog.conf.old'
cp /etc/syslog.conf /etc/syslog.conf.old
if [ $? != 0 ];then
	echo "error:Failed to copy '/etc/syslog.conf' to '/etc/syslog.conf.old'. (62.3)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#62.4 edit '/etc/syslog.conf'
cat /tmp/dsinst/syslog.conf.set | tee -a /etc/syslog.conf
if [ $? != 0 ];then
	echo "error:Failed to edit '/etc/syslog.conf'. (62.4)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#62.5 move '/etc/sysconfig/syslog' to '/etc/sysconfig/syslog.old'
mv /etc/sysconfig/syslog /etc/sysconfig/syslog.old
if [ $? != 0 ];then
	echo "error:Failed to move '/etc/sysconfig/syslog' to '/etc/sysconfig/syslog.old'. (62.5)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#62.6 edit '/etc/sysconfig/syslog'
sed -e s/'SYSLOGD_OPTIONS="'/'SYSLOGD_OPTIONS="-r '/ /etc/sysconfig/syslog.old >> /etc/sysconfig/syslog
if [ $? != 0 ];then
	echo "error:Failed to edit '/etc/sysconfig/syslog'. (62.6)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#62.7 restart 'service syslog'
	service syslog restart
	if [ $? != 0 ]
	then
		echo "error:Failed to restart 'service syslog'. (62.7)"| tee -a ~/dstar_gw-install.log
	else
		true
	fi

#62.7 make directories '/opt/products/dstar/apache/securesite'
mkdir /opt/products/dstar/apache/securesite
if [ $? != 0 ];then
	echo "error:Failed to make directories '/opt/products/dstar/apache/securesite'. (62.7)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#62.8 change '/opt/products/dstar/apache/securesite' ouner and group
chown -R dstar.dstar /opt/products/dstar/apache/securesite
if [ $? != 0 ];then
	echo "error:Failed to change '/opt/products/dstar/apache/securesite' ouner and group. (62.8)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#63 change the current directory to '/home/dstar/middle/postgresql-8.2.3/'
cd /home/dstar/middle/postgresql-8.2.3/
if [ $? != 0 ];then
	echo "error:Failed to change the current directory to '/home/dstar/middle/postgresql-8.2.3/'. (63)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#64 gmake install
gmake install
if [ $? != 0 ];then
	echo "error:Failed to 'gmake install'"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#65 make directories '/opt/products/dstar/pgsql-8.2.3/data'
mkdir /opt/products/dstar/pgsql-8.2.3/data
if [ $? != 0 ];then
	echo "error:Failed to make directories '/opt/products/dstar/pgsql-8.2.3/data'. (65)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#65.1 change the current directory to '/opt/products/dstar/'
cd /opt/products/dstar/
if [ $? != 0 ];then
	echo "error:Failed to change the current directory to '/opt/products/dstar/'. (65.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#66 make symbolic link 'pgsql-8.2.3' to 'pgsql'
ln -s pgsql-8.2.3 pgsql
if [ $? != 0 ];then
	echo "error:Failed to make symbolic link 'pgsql-8.2.3' to 'pgsql'"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#67 change '/opt/products/dstar/pgsql-8.2.3' owner and group
chown -R postgres:postgres /opt/products/dstar/pgsql-8.2.3
if [ $? != 0 ];then
	echo "error:Failed to change '/opt/products/dstar/pgsql-8.2.3' owner and group. (67)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#67.1 copy '/opt/products/dstar/tomcat/conf/server.xml' to '/opt/products/dstar/tomcat/conf/server.xml.old'
cp /opt/products/dstar/tomcat/conf/server.xml /opt/products/dstar/tomcat/conf/server.xml.old
if [ $? != 0 ];then
	echo "error:Failed to copy '/opt/products/dstar/tomcat/conf/server.xml' to '/opt/products/dstar/tomcat/conf/server.xml.old'. (67.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#68 copy '/tmp/dsinst/server.xml' to '/opt/products/dstar/tomcat/conf/
cp /tmp/dsinst/server.xml /opt/products/dstar/tomcat/conf/
if [ $? != 0 ];then
	echo "error:Failed to copy '/tmp/dsinst/server.xml' to '/opt/products/dstar/tomcat/conf/' (68)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#68.1 Change '/opt/products/dstar/tomcat/conf/server.xml' access permissions
chmod 600 /opt/products/dstar/tomcat/conf/server.xml
if [ $? != 0 ];then
	echo "error:Failed to Change '/opt/products/dstar/tomcat/conf/server.xml' access permissions failed. (68.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi


#69 copy'/tmp/dsinst/httpd.conf' to '/opt/products/dstar/apache/conf/'
cp /tmp/dsinst/httpd.conf /opt/products/dstar/apache/conf/
if [ $? != 0 ];then
	echo "error:Failed ot copy'/tmp/dsinst/httpd.conf' to '/opt/products/dstar/apache/conf/'. (69)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#69.1 Change '/opt/products/dstar/apache/conf/httpd.conf' access permissions
chmod 644 /opt/products/dstar/apache/conf/httpd.conf
if [ $? != 0 ];then
	echo "error:Failed to Change '/opt/products/dstar/apache/conf/httpd.conf' access permissions failed. (69.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#69.5 copy 'dstar_gw' to '/etc/init.d'
cp /tmp/dsinst/dstar_gw /etc/init.d
if [ $? != 0 ];then
	echo "error:Failed to copy 'dstar_gw' to '/etc/init.d' (69.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#69.6 change '/etc/init.d/dstar_gw' access permissions
chmod 755 /etc/init.d/dstar_gw
if [ $? != 0 ];then
	echo "error:Failed to change '/etc/init.d/dstar_gw' access permissions failed. (69.6)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#69.7 add new service 'dstar_gw'
chkconfig --add dstar_gw
if [ $? != 0 ];then
	echo "error:Failed to 'chkconfig --add dstar_gw' (69.2)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#69.8 specifies the run levels dstar_gw
chkconfig --level 2345 dstar_gw on
if [ $? != 0 ];then
	echo "error:Failed to 'chkconfig --level 2345 dstar_gw on' (69.3)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

###### step4 ###### user-postgres install
#70 create a new PostgreSQL database cluster
su - postgres -c '/opt/products/dstar/pgsql/bin/initdb -D /opt/products/dstar/pgsql/data'
if [ $? != 0 ];then
	echo "error:Failed to '/opt/products/dstar/pgsql/bin/initdb -D /opt/products/dstar/pgsql/data'. (70)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi
sleep 2

#70.1 Backup postgresql.conf
su - postgres -c 'mv /opt/products/dstar/pgsql/data/postgresql.conf /opt/products/dstar/pgsql/data/postgresql.conf.old'
if [ $? != 0 ];then
	echo "error:Failed to backup postgresql.conf. (75.1)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#70.2 Edit postgresql.crof
sed 's/#timezone = unknown/timezone = UTC/g' /opt/products/dstar/pgsql/data/postgresql.conf.old > /opt/products/dstar/pgsql/data/postgresql.conf
if [ $? != 0 ];then
	echo "error:Failed to backup postgresql.conf. (75.2)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#71 start PostgreSQL
su - postgres -c '/opt/products/dstar/pgsql/bin/postgres -D /opt/products/dstar/pgsql/data >logfile 2>&1 & true'
if [ $? != 0 ];then
	echo "error:Failed to '/opt/products/dstar/pgsql/bin/postgres -D /opt/products/dstar/pgsql/data >logfile 2>&1 &'. (71)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

mktemp -q /tmp/ds_inst 1>/dev/null
/tmp/dsinst/disp.sh &

sleep 2

#72 create a new PostgreSQL database 'dstar_global'
su - postgres -c '/opt/products/dstar/pgsql/bin/createdb dstar_global'
ExVal=$?
i=0
while [ ${ExVal} != 0 ];
do
	echo "retry "$i" (<10)"
	$(( $i + 1 ))
	if [ $i -ge 10 ];then
		echo "error:Failed to create databese 'dstar_global'. (72)"| tee -a ~/dstar_gw-install.log
		return 1
	fi
	sleep 2
	su - postgres -c '/opt/products/dstar/pgsql/bin/createdb dstar_global'
	ExVal=$?
done

rm -f /tmp/ds_inst
echo

#73 define a new PostgreSQL user account
su - postgres -c '/opt/products/dstar/pgsql/bin/createuser dstar'
if [ $? != 0 ];then
	echo "error:Failed to create a new PostgreSQL role. (73)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#74 create password
su - postgres -c 'cat /tmp/dsinst/pgsql.sql | psql -U dstar dstar_global'
if [ $? != 0 ];then
	echo "error:Failed to 'cat /tmp/dsinst/pgsql.sql | psql -U dstar dstar_global'. (74)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#75 create database tables
su - postgres -c '
cd /home/postgres/DDL
cat *.sql | psql -U dstar dstar_global
'
if [ $? != 0 ];then
	echo "error:Failed to create database tables. (75)"| tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

}

###### uninstall ######

uninstall(){
#76 delete user 'dstar'
	if [ `id dstar 2>/dev/null | wc -l` != 0 ];then
		echo "delete user 'dstar'? (Y/n) "
		read ans
		case ${ans} in
			[yY])	mktemp -q /tmp/ds_inst 1>/dev/null
					/tmp/dsinst/disp.sh &
					DATE=`date +"%y%m%d_%H%M%S"`
					cd /home
					tar cfvz dstar.$DATE.tar.gz dstar
					cd -
					userdel -r dstar
					rm -f /tmp/ds_inst
					echo
					if [ $? != 0 ];then
						echo "error:Failed to userdel dstar failed. (76)"| tee -a ~/dstar_gw-install.log
					else
						true
					fi
					;;
			*)		;;
		esac
		ans=""
	else
		true
	fi

#77 delete user 'postgres'
	if [ `id postgres 2>/dev/null | wc -l` != 0 ];then
		echo "delete user 'postgres'? (Y/n) "
		read ans
		case ${ans} in
			[yY])	mktemp -q /tmp/ds_inst 1>/dev/null
					/tmp/dsinst/disp.sh &
					DATE=`date +"%y%m%d_%H%M%S"`
					cd /home
					tar cfvz postgres.$DATE.tar.gz postgres
					cd -
					userdel -r postgres
					rm -f /tmp/ds_inst
					echo
					if [ $? != 0 ];then
						echo "error:Failed to userdel postgres failed. (77)"| tee -a ~/dstar_gw-install.log
					else
						true
					fi
					;;
			*)		;;
		esac
		ans=""
	else
		true
	fi

#78 roll back '~/.bashrc'
#   use backup-file(made at install)
	if [ -f ~/.bashrc.old ];then
		echo "roll back '.bashrc'? (Y/n) "
		read ans
		case ${ans} in
			[yY])	cp ~/.bashrc.old ~/.bashrc
					if [ $? != 0 ];then
						echo "error:Failed to roll back '~/.bashrc'. (78)"| tee -a ~/dstar_gw-install.log
					else
						true
					fi
					;;
			*)		;;
		esac
		ans=""
	else
		true
	fi

#79 roll back 'syslog.conf'
#   use backup-file(made at install)
	if [ -f /etc/syslog.conf.old ];then
		echo "roll back 'syslog.conf'? (Y/n) "
		read ans
		case ${ans} in
			[yY])	cp /etc/syslog.conf.old /etc/syslog.conf
					if [ $? != 0 ];then
						echo "error:Failed to roll back '/etc/syslog.conf'. (79)"| tee -a ~/dstar_gw-install.log
					else
						true
					fi
					;;
			*)		;;
		esac
		ans=""
	else
		true
	fi

#80 roll back 'syslog'
#   use backup-file(made at install)
	if [ -f /etc/sysconfig/syslog.old ];then
		echo "roll back 'syslog'? (Y/n) "
		read ans
		case ${ans} in
			[yY])	cp /etc/sysconfig/syslog.old /etc/sysconfig/syslog
					if [ $? != 0 ];then
						echo "error:roll back '/etc/sysconfig/syslog'. (80)"| tee -a ~/dstar_gw-install.log
					else
						true
					fi
					;;
			*)		;;
		esac
		ans=""
	else
		true
	fi

#81 removed service 'dstar_gw'
	if [ -f /etc/init.d/dstar_gw ];then
		chkconfig --del dstar_gw
		if [ $? != 0 ];then
			echo "error:failed to 'chkconfig --del dstar_gw'. (81)"| tee -a ~/dstar_gw-install.log
		else
			true
		fi
	else
		true
	fi

#82 remove '/etc/init.d/dstar_gw'
	if [ -f /etc/init.d/dstar_gw ];then
		rm -f /etc/init.d/dstar_gw
		if [ $? != 0 ];then
			echo "error:failed to remove '/etc/init.d/dstar_gw'. (82)"| tee -a ~/dstar_gw-install.log
		else
			true
		fi
	else
		true
	fi

#83 remove '/opt/products'
	if [ -d /opt/products ];then
		echo "delete 'install_directory(/opt/products)'? (Y/n) "
		read ans
		case ${ans} in
			[yY])	mktemp -q /tmp/ds_inst 1>/dev/null
					/tmp/dsinst/disp.sh &
					rm -r /opt/products
					rm -f /tmp/ds_inst
					echo
					if [ $? != 0 ];then
						echo "error:Failed to remove '/opt/products'. (83)"| tee -a ~/dstar_gw-install.log
					else
						true
					fi
					;;
			*)		;;
		esac
		ans=""
	else
		true
	fi
}


###### check() ######
check()
{
### 環境チェック ###

#84 whoami
if [ `whoami` != 'root' ];then
	echo "error: not root (84)" | tee -a ~/dstar_gw-install.log
	return 1
else
	true	
fi

#84.1 remove /tmp/ds_inst
if [ -f /tmp/ds_inst ];then
	rm -f /tmp/ds_inst
else
	true
fi

#84.2 emove temporary files'/tmp/dsinst'
if [ -d /tmp/dsinst ];
then
	rm -rf /tmp/dsinst
	if [ $? != 0 ];then
		echo "error:Failed to remove temporary files (84.2)"| tee -a ~/dstar_gw-install.log
	else
		true
	fi
else
	true
fi

#84.3 copy './dsinst.tar.gz' to '/tmp'
cp dsinst.tar.gz /tmp
if [ $? != 0 ];then
	echo "error:Failed to copy './dsinst.tar.gz' to '/tmp' (84.3)"| tee -a ~/dstar_gw-install.log
else
	true
fi

#84.4 expand files from /tmp/dsinst.tar.gz
gunzip /tmp/dsinst.tar.gz
if [ $? != 0 ];then
	echo "error:Failed to expand files from /tmp/dsinst.tar.gz (84.4)"| tee -a ~/dstar_gw-install.log
else
	true
fi

#84.5 xpand files from /tmp/dsinst.tar
tar -C /tmp -xvf /tmp/dsinst.tar 1>/dev/null
if [ $? != 0 ];then
	echo "error:Failed to expand files from /tmp/dsinst.tar (84.5)"| tee -a ~/dstar_gw-install.log
else
	true
fi

#84.6 remove /tmp/dsinst.tar
rm -f /tmp/dsinst.tar
if [ $? != 0 ];then
	echo "error:Failed to remove /tmp/dsinst.tar (84.6)"| tee -a ~/dstar_gw-install.log
else
	true
fi

## file-check
#85 root.bashrc
if [ ! -f /tmp/dsinst/root.bashrc ];then
	echo "error: not found /tmp/dsinst/root.bashrc (85)" | tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#86 dstar.bashrc
if [ ! -f /tmp/dsinst/dstar.bashrc ];then
	echo "error: not found /tmp/dsinst/dstar.bashrc (86)" | tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#87 postgres.bashrc
if [ ! -f /tmp/dsinst/postgres.bashrc ];then
	echo "error: not found /tmp/dsinst/postgres.bashrc (87)" | tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#88 httpd.conf
if [ ! -f /tmp/dsinst/httpd.conf ];then
	echo "error: not found /tmp/dsinst/httpd.conf (88)" | tee -a ~/dstar_gw-install.log
	return 1
else
	true
fi

#89 pgsql.sql
if [ ! -f /tmp/dsinst/pgsql.sql ];then
	echo "error: not found /tmp/dsinst/pgsql.sql (89)" | tee -a ~/dstar_gw-install.log
	return 1
fi

#90 dstar_gw
if [ ! -f /tmp/dsinst/dstar_gw ];then
	echo "eerror: not found /tmp/dsinst/dstar_gw (90)" | tee -a ~/dstar_gw-install.log
	return 1
fi

#91 server.xml
if [ ! -f /tmp/dsinst/server.xml ];then
	echo "eerror: not found /tmp/dsinst/server.xml (91)" | tee -a ~/dstar_gw-install.log
	return 1
fi

#92 syslog.conf.set
if [ ! -f /tmp/dsinst/syslog.conf.set ];then
	echo "eerror: not found /tmp/dsinst/syslog.conf.set (92)" | tee -a ~/dstar_gw-install.log
	return 1
fi

## check gcc
#93 gcc is not installed -> exit
if [ `rpm -q gcc | grep gcc-[34] | wc -l` = 0 ];then
	echo "*** gcc is not installed *** (93)"  | tee -a ~/dstar_gw-install.log
	return 1
fi

#94 gcc-c++ is not installed -> exit
if [ `rpm -q gcc-c++ | grep gcc-c++-[34] | wc -l` = 0 ];then
	echo "*** gcc is not installed *** (94)"  | tee -a ~/dstar_gw-install.log
	return 1
fi

#94.1 check DNS-server
if [ ! -d /var/named ];then
	echo "Please install 'DNS server' (94.1)"
	return 1
else
	true
fi

## chekck process
#95 chekck process 'dsipsvd'
#   is running -> stop process
if [ `ps -aef | grep dsipsvd | grep -v ipchk.sh | grep -v grep | wc -l` != 0 ];then
	echo "*** dsispd is running. *** (95-1)" | tee -a ~/dstar_gw-install.log
	echo "Do you want to stop? (Y/n)"
	read ans
	case ${ans} in
		[yY])	/tmp/dsinst/dstar_gw stop 1>/dev/null
				;;
		*)		;;
	esac
	if [ `ps -aef | grep dsipsvd | grep -v ipchk.sh | grep -v grep | wc -l` != 0 ];then
		echo "*** Failed to stop dsispd. *** (95-2)" | tee -a ~/dstar_gw-install.log
		return 1
	fi
fi

#96 chekck process 'dsgwd'
#   is running -> stop process
if [ `pgrep dsgwd | wc -l` != 0 ];then
	echo "*** GW server(dsgwd) is running *** (96-1)" | tee -a ~/dstar_gw-install.log
	echo "Do you want to stop? (Y/n)"
	read ans
	case ${ans} in
		[yY])	/tmp/dsinst/dstar_gw stop 1>/dev/null
				;;
		*)		;;
	esac
	if [ `pgrep dsgwd | wc -l` != 0 ];then
		echo "*** Failed to stop 'GW server'(dsgwd). *** (96-2)" | tee -a ~/dstar_gw-install.log
		return 1
	fi
fi

#97 chekck process 'httpd'
#   is running -> stop process
if [ `ps -aef | grep /opt/products/dstar/httpd-2.0.59/bin/httpd | grep -v grep | wc -l` != 0 ];then
	echo "*** Apache(httpd) is running. *** (97-1)" | tee -a ~/dstar_gw-install.log
	echo "Do you want to stop? (Y/n)"
	read ans
	case ${ans} in
		[yY])	/tmp/dsinst/dstar_gw stop 1>/dev/null
				;;
		*)		;;
	esac
	if [ `pgrep -U dstar httpd | wc -l` != 0 ];then
		echo "*** Failed to stop Apache(httpd). *** (97-2)" | tee -a ~/dstar_gw-install.log
		return 1
	fi
fi


#98 chekck process 'tomcat'
#   is running -> stop process
if [ `ps -aef | grep tomcat | grep -v grep | wc -l` != 0 ];then
	echo "*** tomcat is running. *** (98-1)" | tee -a ~/dstar_gw-install.log
	echo "Do you want to stop? (Y/n)"
	read ans
	case ${ans} in
		[yY])	/tmp/dsinst/dstar_gw stop 1>/dev/null
				;;
		*)		;;
	esac
	if [ `ps -aef | grep tomcat | grep -v grep | wc -l` != 0 ];then
		echo "*** Failed to stop tomcat. *** (98-2)" | tee -a ~/dstar_gw-install.log
		return 1
	fi
fi

#99 find postgres-user
if [ `id postgres 2>/dev/null | wc -l` != 0 ];then
#   chekck process 'PostgreSQL'
#   is running -> stop process
	if [ `ps -U postgres | grep postgres | wc -l` != 0 ];then
		echo "*** PostgreSQL is running. *** (99-1)" | tee -a ~/dstar_gw-install.log
		echo "Do you want to stop? (Y/n)"
		read ans
		case ${ans} in
			[yY])	/tmp/dsinst/dstar_gw stop 1>/dev/null
					;;
			*)		;;
		esac
		if [ `ps -U postgres | grep postgres | wc -l` != 0 ];then
			echo "*** Failed to stop PostgreSQL. *** (99-2)" | tee -a ~/dstar_gw-install.log
			return 1
		fi
	fi
fi

}

###### main() ######

##start check
check
if [ $? != 0 ];then
	echo "*** install failed. *** (100.1)" | tee -a ~/dstar_gw-install.log
	exit
else
	true
fi


###101-105 Option ###

case $1 in
	uninstall)	echo "Do you really want to uninstall? (Y/n)"
				read ans
				case ${ans} in
					[yY])	uninstall
							echo "*** uninstall successfully finished. ***";;
					*)	;;	
				esac
				;;
	install)	install
				if [ $? != 0 ];then
					echo "*** install failed. *** (101)" | tee -a ~/dstar_gw-install.log
					pkill postgres
					echo "Do you want to uninstall? (Y/n)"
					read ans
					case ${ans} in
						[yY])	uninstall;;
						*)	;;	
					esac
				else
					echo "*** install successfully finished. *** (102)" | tee -a ~/dstar_gw-install.log
					echo "Do you want to append an administrator? (Y/n)"
					read ans
					case ${ans} in
						[yY])	add_user_mng.sh;;
						*)	;;	
					esac
					pkill postgres
					echo "Please edit 'GW server' conf"
				fi
				;;
	"")			install
				if [ $? != 0 ];then
					echo "*** install failed. *** (103)" | tee -a ~/dstar_gw-install.log
					pkill postgres
					echo "Do you want to uninstall? (Y/n)"
					read ans
					case ${ans} in
						[yY])	uninstall;;
						*)	;;	
					esac
				else
					echo "*** install successfully finished. *** (104)" | tee -a ~/dstar_gw-install.log
					pkill postgres
					echo
					echo
					echo "*******************************************"
					echo "*******Please edit 'GW server' conf.*******"
					echo "*******************************************"
					echo
					echo
				fi
				;;
	*)			echo "invalid argument to option (105)" | tee -a ~/dstar_gw-install.log
				;;
esac


#106 delete temporary files
if [ -d /tmp/dsinst ];
then
	rm -rf /tmp/dsinst
	if [ $? != 0 ];then
		echo "error:Failed to remove temporary files (106)"| tee -a ~/dstar_gw-install.log
	else
		true
	fi
else
	true
fi

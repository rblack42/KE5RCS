#!/bin/bash
#
cd /tmp
echo "[system clock]" 
date
echo -e "\n[last database sync]"
grep SYNC_DB_SYNC /var/log/dsipsvd.log | tail -1
echo -e "\n[users pending licensing]"
PSQL='/opt/products/dstar/pgsql-8.2.3/bin/psql'
$PSQL dstar_global dstar -c "select user_cs from unsync_user_mng where regist_flg = false;"
echo -e "[gateway status]"
/sbin/service dstar_gw status
echo -e "\n[named status]"
/sbin/service named status
echo -e "\n[dstarmon beta status]"
/bin/ps aux | pgrep -lf DStarMonitor3.jar
echo -e "\n[dplus status]"
/sbin/service dplus status
cat /dstar/tmp/status

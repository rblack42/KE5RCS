# G3 Postfix Setup

- Reference: https://devops.ionos.com/tutorials/configure-a-postfix-relay-through-gmail-on-centos-7/

- Host domain: ke5rcs.dstargateway.org

- Gmail app password: xoiozvrrqyslxnvo

- Admin IP: 136.34.226.168

I set up ssh authentication using my public key, and was geting connection
refused errors. The **/var/log/secure** log was showing multiple "breakin
attempts: from my IP address. Setting **UseDNS no** fixed this problem 

TODO: Add Brads IP address and limit ssh to just our addresses. 

- https://nj6n.com/dplusmon/?mycall=&gateway=KE5RCS

- https://dstardb.ae7q.com/index.php?CALL=KE5RCS&TYPE=rpt1Call


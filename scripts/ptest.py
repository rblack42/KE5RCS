import logging
import paramiko
paramiko.util.log_to_file("ptest.log", level = "DEBUG")
logging.basicConfig()
logging.getLogger("paramiko").setLevel(logging.DEBUG) # for example

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(
        '65.111.55.5', 
        5224, 
        username='n5ujh', 
        connect_kwargs={'disabled_algorithms': {'pubkeys': ['rsa-sha2-256', 'rsa-sha2-512']}}
        )
t = ssh.get_transport()
so  = t.get_security_options()
print(so.kex)

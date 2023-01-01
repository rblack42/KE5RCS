import logging
import paramiko


cfg = {
    'hostname': '65.111.55.5',
    'username': 'n5ujh',
    'port': 5224,
    'disabled_algorithms': dict(pubkeys=['rsa-sha2-256', 'rsa-sha2-512']),
}

paramiko.util.log_to_file("ptest.log", level="DEBUG")

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
paramiko.Transport.disabled_algorithms = { "kex": ["rsa-sha2-512"], "kex": ['rsa-sha2-256'] }
ssh.connect(**cfg)

t = ssh.get_transport()
so  = t.get_security_options()
print(so.kex)

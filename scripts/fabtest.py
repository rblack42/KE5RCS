import os
from fabric import Connection, Config

sudopw = os.environ.get('SUDOPW')
print(sudopw)

config = Config(overrides={'sudo': {'password': sudopw}})

c = Connection(
	host='ke5rcs',
    user='n5ujh',
    port=5224,
	connect_kwargs={
      'disabled_algorithms': dict(pubkeys=['rsa-sha2-256', 'rsa-sha2-512']), 
    },
    config=config
)

c.run('uname -s')
c.run('whoami')
c.run('uptime')
c.sudo('cat /etc/ssh/sshd_config')



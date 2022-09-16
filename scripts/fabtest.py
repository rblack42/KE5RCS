from fabric import Connection
#c = Connection(
#	host='ke5rcs',
#	connect_kwargs={
#       "disabled_algorithms": {'pubkey': ['rsa-sha2-512', 'rsa-sha2-256']}
#    },
#    user='n5ujh',
#    port=5224,
#)
c = Connection(host='ke5rcs')

c.run('uname -s')


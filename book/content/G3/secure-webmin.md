# Secure Webmin Access

Since we have set up the gateway computer with SSH access for administration work, we can use an *SSH Tunnel* to access *Webmin*. As part of this setup, we will disallow any other connections to *Webmin* which will lower the possibilty of an attack on that service.

## Admin Password

- /usr/libexec/webmin/changepass.pl /etc/webmin admin newpassword

Note that the default use on the new *Webmin* installation is **root**.

## Restrict IP Access to localhost

We begin by configuring *Webmin8 to only accept connections from the *localhost*

Navigate to the *Webmin* configurationpage, then select *IP Access Control*

Check the *Only allow access  from these addresses* and set **127.0.0.1** as the allowed address.

Establishing the Ttunnel:

- ssh -p 22 vagrant@10.0.2.15 -L 10005:127.0.0.1 -N &

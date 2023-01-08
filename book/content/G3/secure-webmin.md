# Secure Webmin Access

Since we have set up the gateway computer with SSH access for administration work, we can use an *SSH Tunnel* to access *Webmin*. As part of this setup, we will disallow any other connections to *Webmin* which will lower the possibilty of an attack on that service.

## Restrict IP Access to localhost

We begin by configuring *Webmin8 to only accept connections from the *localhost*

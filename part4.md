
Part IV - Enabling Java to use the Hardware
Opencryptoki
OpenCryptoki defaults to be usable by anyone who is in the group pkcs11. Add the pkcs11 group before installing it, by issuing as root the following command:
```
groupadd pkcs11
```

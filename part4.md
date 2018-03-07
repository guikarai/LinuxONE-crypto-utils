## Part IV - Enabling Java to use the Hardware
### Java encryption requires OpenCryptoki
#### OpenCryptoki
OpenCryptoki comes with a set of tokens; some are platform-independent and some are specific to Linux on IBM Z:
- **Soft token** is a platform-independent token providing clear key cryptographic functions using a pure software implementation from openssl.
- **ICA token** is a Linux on System z-specific token for clear key cryptography exploiting symmetric crypto algorithms and hashes provided by CPACF and possibly RSA algorithms provided by either CryptoExpress accelerators or CCA coprocessors.
- **CCA token** is a Linux on System z-specific token for secure key cryptography calling the CCA library, which exploits CCA coprocessors.
- **ICFS token** is a platform-independent token that calls services from a remote cryptography server hosted on z/OS.
- **TPM token** is a token for platforms that support a Trusted Platform Module (TPM).
For the following, we will make it easy with opencryptoki. We will use ica token.

#### OpenCryptoki Installation
To install the basic openCryptoki packages on your system, including a software implementation of a token for testing purposes, enter the following command as root:
```
[root@ghrhel74crypt ~]# yum install opencryptoki
```
To enable the openCryptoki service, you need to run the pkcsslotd daemon. Start the daemon for the current session by executing the following command as root:
```
[root@ghrhel74crypt ~]# systemctl start pkcsslotd
```
To ensure that the service is automatically started at boot time, enter the following command:
```
[root@ghrhel74crypt ~]# systemctl enable pkcsslotd
```
See the Managing Services with systemd chapter of the Red Hat Enterprise Linux 7 System Administrator's Guide for more information on how to use systemd targets to manage services.
OpenCryptoki defaults to be usable by anyone who is in the group pkcs11. Add the pkcs11 group before installing it, by issuing as root the following command:
```
[root@ghrhel74crypt ~]# groupadd pkcs11
```
In addition, add the necessary user to the pkcs11 group (root doesn't need to be in pkcs11 group):
```
[root@ghrhel74crypt ~]# usermod -G pkcs11 <user>
```
When started, the pkcsslotd daemon reads the /etc/opencryptoki/opencryptoki.conf configuration file, which it uses to collect information about the tokens configured to work with the system and about their slots.
#### OpenCryptoki Configuration
```
[root@ghrhel74crypt ~]# pkcsconf -t
```

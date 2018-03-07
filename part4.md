## Part IV - Enabling Java to use the Hardware
### Installation
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
### Configuration

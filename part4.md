## Part IV : Optimization - Enabling PKCS#11 APIs to allow application to exploit the Crypto Hardware
At this step, you can know how many applications are connected to the z90crypt device driver.
Please issue the following command:
```
[root@ghrhel74crypt ~]# cat /proc/driver/z90crypt

zcrypt version: 2.1.1
Cryptographic domain: 1
Total device count: 1
PCICA count: 0
PCICC count: 0
PCIXCC MCL2 count: 0
PCIXCC MCL3 count: 0
CEX2C count: 0
CEX2A count: 0
CEX3C count: 0
CEX3A count: 1
requestq count: 0
pendingq count: 0
Total open handles: 2

Online devices: 1=PCICA 2=PCICC 3=PCIXCC(MCL2) 4=PCIXCC(MCL3) 5=CEX2C 6=CEX2A 7=CEX3C 8=CEX3A
  0800000000000000 0000000000000000 0000000000000000 0000000000000000 

Waiting work element counts
  0000000000000000 0000000000000000 0000000000000000 0000000000000000  
Per-device successfully completed request counts
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
```
As you can see, "Total open handles equals" to 1. So one application only is plugged to z90crypt for crypto offload. This because openssl is already connected to z90crypt thanks to the part III of the lab.

### OpenCryptoki
OpenCryptoki comes with a set of tokens; some are platform-independent and some are specific to Linux on IBM Z:
- **Soft token** is a platform-independent token providing clear key cryptographic functions using a pure software implementation from openssl.
- **ICA token** is a Linux on System z-specific token for clear key cryptography exploiting symmetric crypto algorithms and hashes provided by CPACF and possibly RSA algorithms provided by either CryptoExpress accelerators or CCA coprocessors.
- **CCA token** is a Linux on System z-specific token for secure key cryptography calling the CCA library, which exploits CCA coprocessors.
- **ICFS token** is a platform-independent token that calls services from a remote cryptography server hosted on z/OS.
- **TPM token** is a token for platforms that support a Trusted Platform Module (TPM).
For the following, we will make it easy with opencryptoki. We will use ica token.

### OpenCryptoki Installation
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

#### Initial check
```
Token #3 Info:
Label: IBM OS PKCS#11                  
Manufacturer: IBM Corp.                       
Model: IBM SoftTok     
Serial Number: 123             
Flags: 0x880045 (RNG|LOGIN_REQUIRED|CLOCK_ON_TOKEN|USER_PIN_TO_BE_CHANGED|SO_PIN_TO_BE_CHANGED)
Sessions: 0/18446744073709551614
R/W Sessions: 18446744073709551615/18446744073709551614
PIN Length: 4-8
Public Memory: 0xFFFFFFFFFFFFFFFF/0xFFFFFFFFFFFFFFFF
Private Memory: 0xFFFFFFFFFFFFFFFF/0xFFFFFFFFFFFFFFFF
Hardware Version: 1.0
Firmware Version: 1.0
Time: 18:13:52
```

#### Initialize slot #3
```
[root@ghrhel74crypt opencryptoki]# pkcsconf -I -c 3
Enter the SO PIN: 87654321
Enter a unique token label: ghrhel74
```

#### Change the SO PIN
```
root@ghrhel74crypt opencryptoki]# pkcsconf -c 3 -P
Enter the SO PIN: 87654321
Enter the new SO PIN: 12345678
Re-enter the new SO PIN: 12345678
```

#### Intermediate check
```
[root@ghrhel74crypt opencryptoki]# pkcsconf -t
Token #3 Info:
Label: ghrhel74                        
Manufacturer: IBM Corp.                       
Model: IBM SoftTok     
Serial Number: 123             
Flags: 0x80445 (RNG|LOGIN_REQUIRED|CLOCK_ON_TOKEN|TOKEN_INITIALIZED|USER_PIN_TO_BE_CHANGED)
Sessions: 0/18446744073709551614
R/W Sessions: 18446744073709551615/18446744073709551614
PIN Length: 4-8
Public Memory: 0xFFFFFFFFFFFFFFFF/0xFFFFFFFFFFFFFFFF
Private Memory: 0xFFFFFFFFFFFFFFFF/0xFFFFFFFFFFFFFFFF
Hardware Version: 1.0
Firmware Version: 1.0
Time: 18:20:18
```

#### Set the user PIN
```
root@ghrhel74crypt opencryptoki]# pkcsconf -c 3 -u
Enter the SO PIN: 12345678
Enter the new user PIN: 12341234
Re-enter the new user PIN: 12341234
```

#### Change the user PIN
```
[root@ghrhel74crypt opencryptoki]# pkcsconf -c 3 -p
Enter user PIN: 12341234
Enter the new user PIN: 43214321
Re-enter the new user PIN: 43214321
```

#### Final check
```
[root@ghrhel74crypt opencryptoki]# pkcsconf -t
Token #3 Info:
Label: ghrhel74                        
Manufacturer: IBM Corp.                       
Model: IBM SoftTok     
Serial Number: 123             
Flags: 0x44D (RNG|LOGIN_REQUIRED|USER_PIN_INITIALIZED|CLOCK_ON_TOKEN|TOKEN_INITIALIZED)
Sessions: 0/18446744073709551614
R/W Sessions: 18446744073709551615/18446744073709551614
PIN Length: 4-8
Public Memory: 0xFFFFFFFFFFFFFFFF/0xFFFFFFFFFFFFFFFF
Private Memory: 0xFFFFFFFFFFFFFFFF/0xFFFFFFFFFFFFFFFF
Hardware Version: 1.0
Firmware Version: 1.0
Time: 18:25:46
```
Flag 0x44D means you are all good.

You can rapidly check that your implementation works issuing the following command:
```
[root@ghrhel74crypt ~]# cat /proc/driver/z90crypt

zcrypt version: 2.1.1
Cryptographic domain: 1
Total device count: 1
PCICA count: 0
PCICC count: 0
PCIXCC MCL2 count: 0
PCIXCC MCL3 count: 0
CEX2C count: 0
CEX2A count: 0
CEX3C count: 0
CEX3A count: 1
requestq count: 0
pendingq count: 0
Total open handles: 2

Online devices: 1=PCICA 2=PCICC 3=PCIXCC(MCL2) 4=PCIXCC(MCL3) 5=CEX2C 6=CEX2A 7=CEX3C 8=CEX3A
  0800000000000000 0000000000000000 0000000000000000 0000000000000000 

Waiting work element counts
  0000000000000000 0000000000000000 0000000000000000 0000000000000000  
Per-device successfully completed request counts
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
```
As you can see, "Total open handles equals" now to 2. Opencryptoki application is now correctly plugged to z90crypt to benefit of the crypto offload.

### OpenSSL with PKCS#11 engine

## Part V : Optimization - Enabling JAVA to use the Crypto Hardware
In IBM Java 8 some significant enhancements have been implemented. Besides a lot of general performance enhancements, IBM Java 8 SR1 offers significant improvements to IBMJCE. The IBMJCE provider now automatically detects and exploits an on-core hardware cryptographic accelerator (CPACF) as well as the Single Instruction, Multiple Data (SIMD) vector engine available with IBM z13 or later. 
These enhancements allow the default IBMJCE provider to automatically use CPACF support for AES, DES, tripple DES and SHA algorithms without the need to use the special IBMPKCS11Impl provider for hardware acceleration. However, it still makes sense to configure the IBMPKCS11Impl provider to also use hardware acceleration for other algorithms like RSA.

### Initial check
Assess how many application is accessing your hardware implementation. Please issue the following command:
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
Total open handles: 5


Online devices: 1=PCICA 2=PCICC 3=PCIXCC(MCL2) 4=PCIXCC(MCL3) 5=CEX2C 6=CEX2A 7=CEX3C 8=CEX3A
	   0800000000000000 0000000000000000 0000000000000000 0000000000000000 


Waiting work element counts
	   0000000000000000 0000000000000000 0000000000000000 0000000000000000 


Per-device successfully completed request counts
    00000000 00151949 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
    00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
```
As you can see there are 4 application accessing the crypto card implementation. Let's add a new one with JAVA!

### Java installation
Let's install Java in its version 1.8.0 from IBM.
```
[root@ghrhel74crypt ~]# yum install java-1.8.0-ibm*
```
Let's initialize the variables PATH and JAVA HOME. Please issue the following command:
```
export PATH=$PATH: /opt/ibm/java−s390x −80/jre/bin
export JAVA HOME=/opt/ibm/java−s390x −80/jre
```

### Hardware configuration creation
We need to create a hwcrypto.cfg file.
Suggested location is /opt/IBM/java/
We have to reuse previously done work regarding PKCS11 and opencryptoki.

Let's create the file in our suggested location. Please issue the following command:
```
[root@ghrhel74crypt ~]# mkdir /opt/IBM/java/
[root@ghrhel74crypt ~]# vi /opt/IBM/java/hwcrypto.cfg
```
Please fill the open hwcrypto.cfg file with the folowing:
```
name = ghrhel74
library=/usr/lib/pkcs11/PKCS11_API.s
o64
description=custom slotListIndex = 0 disabledMechanisms = { CKM_MD5
CKM_SHA_1
CKM_MD5_HMAC CKM_SHA_1_HMAC CKM_SSL3_MASTER_KEY_DERIVE CKM_SSL3_KEY_AND_MAC_DERIVE CKM_SSL3_PRE_MASTER_KEY_GEN }
```


### Java security configuration file

Let's start by modifying the Java.security file. It may reside in different place according configuration. Let's check where this file is. Please issue the following command:
```
[root@ghrhel74crypt ~]# find / -name java.security
/usr/lib/jvm/java-1.8.0-ibm-1.8.0.4.5-1jpp.1.el7_3.s390x/jre/lib/security/java.security
```

Let's move in the folder of java.security. Please issue the folowing command:
```
[root@ghrhel74crypt ~]# cd /usr/lib/jvm/java-1.8.0-ibm-1.8.0.4.5-1jpp.1.el7_3.s390x/jre/lib/security/
```

Let's edit the java.seurity file:

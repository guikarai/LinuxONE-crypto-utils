# Enabling Linux to use the Hardware
#### CPACF Enablement verification
A Linux on IBM Z user can easily check whether the Crypto Enablement feature is installed
and which algorithms are supported in hardware. Hardware-acceleration for DES, TDES,
AES, and GHASH requires CPACF.
Issue the following command /proc/cpuinfo to discover whether the CPACF feature is enabled
on your hardware.
```
[root@ghrhel74crypt ~]# cat /proc/cpuinfo
vendor_id       : IBM/S390
# processors    : 2
bogomips per cpu: 21881.00
max thread id   : 0
features	: esan3 zarch stfle msa ldisp eimm dfp edat etf3eh highgprs te vx sie 
cache0          : level=1 type=Data scope=Private size=128K line_size=256 associativity=8
cache1          : level=1 type=Instruction scope=Private size=128K line_size=256 associativity=8
cache2          : level=2 type=Data scope=Private size=4096K line_size=256 associativity=8
cache3          : level=2 type=Instruction scope=Private size=2048K line_size=256 associativity=8
cache4          : level=3 type=Unified scope=Shared size=131072K line_size=256 associativity=32
cache5          : level=4 type=Unified scope=Shared size=688128K line_size=256 associativity=42
processor 0: version = FF,  identification = 243EF7,  machine = 3906
processor 1: version = FF,  identification = 243EF7,  machine = 3906
```
From the cpuinfo output, you can find the features that are enabled in the central processors.
If the features list has msa listed, it means that CPACF is enabled.

For the Linux virtual machine to gain access to the crypto card, you must load a specialized
crypto device driver. By default, the device drivers that are required for Crypto processing are
not loaded. Issue the following command lszcrypt to assess if the crypto device driver is loaded in your environment.
```
[root@ghrhel74crypt ~]# lszcrypt
lszcrypt: error - cryptographic device driver zcrypt is not loaded!
```
Most of the distributions include a generic kernel image for the specific platform. These
device drivers for the generic kernel image are included as loadable kernel modules because
statically compiling many drivers into one kernel causes the kernel image to be much larger.
This kernel might be too large to boot on computers with limited memory.

The libica package has built-in FIPS support. Libica initialization fails because it cannot access the approved entropy sources i.e., /dev/prandom or /dev/hwrng.

The former needs the prng kernel module to be loaded, the latter needs online CEX C adapters and the ap kernel module to be loaded. To assess the strange behavior, issue the following command:
```
[root@ghrhel74crypt ~]# icainfo
      Cryptographic algorithm support      
-------------------------------------------
 function      |  hardware  |  software  
---------------+------------+------------
         SHA-1 |  blocked   |   blocked
       SHA-224 |  blocked   |   blocked
       SHA-256 |  blocked   |   blocked
       SHA-384 |  blocked   |   blocked
       SHA-512 |  blocked   |   blocked
         GHASH |  blocked   |   blocked
         P_RNG |  blocked   |   blocked
  DRBG-SHA-512 |  blocked   |   blocked
        RSA ME |  blocked   |   blocked
       RSA CRT |  blocked   |   blocked
       DES ECB |  blocked   |   blocked
       DES CBC |  blocked   |   blocked
       DES OFB |  blocked   |   blocked
       DES CFB |  blocked   |   blocked
       DES CTR |  blocked   |   blocked
      DES CMAC |  blocked   |   blocked
      3DES ECB |  blocked   |   blocked
      3DES CBC |  blocked   |   blocked
      3DES OFB |  blocked   |   blocked
      3DES CFB |  blocked   |   blocked
      3DES CTR |  blocked   |   blocked
     3DES CMAC |  blocked   |   blocked
       AES ECB |  blocked   |   blocked
       AES CBC |  blocked   |   blocked
       AES OFB |  blocked   |   blocked
       AES CFB |  blocked   |   blocked
       AES CTR |  blocked   |   blocked
      AES CMAC |  blocked   |   blocked
       AES XTS |  blocked   |   blocked
-------------------------------------------
Built-in FIPS support: FIPS mode inactive.
FIPS SELF-TEST FAILURE. CHECK THE SYSLOG.
``` 

As you can see, acceleration is all blocked, and the FIPS self-test failled. This generate an error we can find in the journalctl. To confirm it, issue the following command:
```
[root@ghrhel74crypt ~]# journalctl | grep Libica
Mar 01 15:05:02 ghrhel74crypt.mop.fr.ibm.com icainfo[1254]: Libica DRBG-SHA-512 entropy source failed.
 ```

To overcome this issue, issue the following command in order to load rng module.
```
[root@ghrhel74crypt ~]# modprobe prng
```
To confirm it fixed the problem, issue the following command:
```
[root@ghrhel74crypt ~]# icainfo
      Cryptographic algorithm support      
-------------------------------------------
 function      |  hardware  |  software  
---------------+------------+------------
         SHA-1 |    yes     |     yes
       SHA-224 |    yes     |     yes
       SHA-256 |    yes     |     yes
       SHA-384 |    yes     |     yes
       SHA-512 |    yes     |     yes
         GHASH |    yes     |      no
         P_RNG |    yes     |     yes
  DRBG-SHA-512 |    yes     |     yes
        RSA ME |     no     |     yes
       RSA CRT |     no     |     yes
       DES ECB |    yes     |     yes
       DES CBC |    yes     |     yes
       DES OFB |    yes     |      no
       DES CFB |    yes     |      no
       DES CTR |    yes     |      no
      DES CMAC |    yes     |      no
      3DES ECB |    yes     |     yes
      3DES CBC |    yes     |     yes
      3DES OFB |    yes     |      no
      3DES CFB |    yes     |      no
      3DES CTR |    yes     |      no
     3DES CMAC |    yes     |      no
       AES ECB |    yes     |     yes
       AES CBC |    yes     |     yes
       AES OFB |    yes     |      no
       AES CFB |    yes     |      no
       AES CTR |    yes     |      no
      AES CMAC |    yes     |      no
       AES XTS |    yes     |      no
-------------------------------------------
Built-in FIPS support: FIPS mode inactive.
Icainfo displays now the correct IBM Z cryptographic capabilities.
```

Use the lsmod command to check whether the crypto device driver module is already loaded.
If the module is not loaded, use the modprobe command to load the device driver module.
If it shows that the Linux system is not yet loaded with the crypto device driver
modules, so you must load it manually. The cryptographic device driver consists of multiple,
separate modules.
```
[root@ghrhel74crypt ~]# modprobe aes_s390
[root@ghrhel74crypt ~]# modprobe des_s390
[root@ghrhel74crypt ~]# modprobe sha1_s390
[root@ghrhel74crypt ~]# modprobe sha256_s390
[root@ghrhel74crypt ~]# modprobe sha512_s390
[root@ghrhel74crypt ~]# modprobe rng
[root@ghrhel74crypt ~]# modprobe hmac
```

You can configure the cryptographic device driver through module
parameters when you load the AP bus module. It is possible to manually request the loading of a module with the modprobe or insmod command after the bootup process and make to permanently part of the system. The device driver is now loaded as separate modules, where the main module is called ap. However, there is an alias name z90crypt that links to the ap main module.
```
[root@ghrhel74crypt ~]# modprobe ap
```

Check whether you have plugged in and enabled your IBM cryptographic adapter and validate your model and type configuration (accelerator or coprocessor). Issue again the lzcrypt command.
```
[root@ghrhel74crypt ~]# lszcrypt
card01: CEX5A
```

#### Installing libica 3.0
To make use of the libica hardware support for cryptographic functions, you must install the libica version 3.0 package. Obtain the current libica version 3.0 as an RPM package from your distribution provider for automated installation.
```
[root@ghrhel74crypt ~]# yum install libica-utils
```

After the libica utility is installed, use the icaiinfo command to check on the CPACF feature code enablement. If the Crypto Enablement feature 3863 is installed, you will see that besides SHA, other algorithms are available with hardware support. The icainfo command displays which CPACF functions are supported by the implementation inside the libica library. Issue the following command to show that the device driver loaded how which cryptographic algorithms will be accelerated and hardware or software way.
```
[root@ghrhel74crypt ~]# icainfo
      Cryptographic algorithm support      
-------------------------------------------
 function      |  hardware  |  software  
---------------+------------+------------
         SHA-1 |    yes     |     yes
       SHA-224 |    yes     |     yes
       SHA-256 |    yes     |     yes
       SHA-384 |    yes     |     yes
       SHA-512 |    yes     |     yes
      SHA3-224 |    yes     |      no
      SHA3-256 |    yes     |      no
      SHA3-384 |    yes     |      no
      SHA3-512 |    yes     |      no
     SHAKE-128 |    yes     |      no
     SHAKE-256 |    yes     |      no
         GHASH |    yes     |      no
         P_RNG |    yes     |     yes
  DRBG-SHA-512 |    yes     |     yes
        RSA ME |    yes     |     yes
       RSA CRT |    yes     |     yes
       DES ECB |    yes     |     yes
       DES CBC |    yes     |     yes
       DES OFB |    yes     |      no
       DES CFB |    yes     |      no
       DES CTR |    yes     |      no
      DES CMAC |    yes     |      no
      3DES ECB |    yes     |     yes
      3DES CBC |    yes     |     yes
      3DES OFB |    yes     |      no
      3DES CFB |    yes     |      no
      3DES CTR |    yes     |      no
     3DES CMAC |    yes     |      no
       AES ECB |    yes     |     yes
       AES CBC |    yes     |     yes
       AES OFB |    yes     |      no
       AES CFB |    yes     |      no
       AES CTR |    yes     |      no
      AES CMAC |    yes     |      no
       AES XTS |    yes     |      no
       AES GCM |    yes     |      no
-------------------------------------------
No built-in FIPS support.
```

This ends, the basic configuration of your Linux Environment.

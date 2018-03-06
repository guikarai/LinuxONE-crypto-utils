# Hands-on LAB : Exploiting Crypto Express & CPACF Hardware with LinuxONE
As of March 2018, the LinuxONE has two categories of crypto hardware.
- CPACF – Provides support for symmetric ciphers and secure hash algorithms (SHA) on every central processor. The potential encryption/decryption throughput scales with the number of CPs.
- CEX6S – The Crypto Express feature traditionally could be configured in two ways: Either as cryptographic Coprocessor (CEXC) for secure key encrypted transactions, or as cryptographic Accelerator (CEXA) for Secure Sockets Layer (SSL) acceleration. A CEXA works in clear key mode. The Crypto Express 6S allows for a third mode as a Secure IBM CCA Coprocessor.

## LinuxONE Crypto Background
OpenSSL needs the engine ibmca to communicate with the interface library (libICA). The libICA library then communicates with CPACF or via the Linux generic device driver z90crypt with a CEX (if available). The device driver z90crypt must be loaded in order to use CEX features.

We know many potential exploiters, and not limited to the following list:
- WebSphere Application Server/Portal
- Java Applications
- IBM HTTP Server
- Apache
- WebSphere Plugin
- Linux SSH, SFTP , SCP
- In Kernel Crypto Exploiters
- DM-Crypt
- IPSec
...

## LinuxONE Crypto Stack
<crypto stack picture here>
  
## Hands-on LAB Agenda
- Part I : Enabling Linux to use the Hardware
- Part II : Pervasive Encryption - Enabling OpenSSL and openSSH to use the Hardware
- Part III : Pervasive Encryption - Enabling dm-crypt to use the Hardware
- Part IV : Optimization - Enabling Java and WebSphere to Exploit the Crypto Hardware
- Part V : Optimization - Configuring the IBM HTTP Server to use the Crypto Hardware
- Part VI : Optimization - Enabling the WAS Plugin to Use the Crypto Hardware

## Part I - Enabling Linux to use the Hardware
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
separate modules. You can configure the cryptographic device driver through module
parameters when you load the AP bus module.
```
[root@ghrhel74crypt ~]# modprobe aes_s390
[root@ghrhel74crypt ~]# modprobe des_s390
[root@ghrhel74crypt ~]# modprobe sha1_s390
[root@ghrhel74crypt ~]# modprobe sha256_s390
[root@ghrhel74crypt ~]# modprobe sha512_s390
[root@ghrhel74crypt ~]# modprobe rng
[root@ghrhel74crypt ~]# modprobe hmac
```

It is possible to manually request the loading of a module with the modprobe or insmod
command after the bootup process and make to permanently part of the system. The device
driver is now loaded as separate modules, where the main module is called ap. However,
there is an alias name z90crypt that links to the ap main module.
```
[root@ghrhel74crypt ~]# modprobe ap
```

Check whether you have plugged in and enabled your IBM cryptographic adapter and
validate your model and type configuration (accelerator or coprocessor). Issue again the lzcrypt command.
```
[root@ghrhel74crypt ~]# lszcrypt
card01: CEX5A
```

#### Installing libica 3.0
To make use of the libica hardware support for cryptographic functions, you must install the
libica version 3.0 package. Obtain the current libica version 3.0 as an RPM package from your
distribution provider for automated installation.
```
[root@ghrhel74crypt ~]# yum install libica-utils
Loaded plugins: langpacks, product-id, search-disabled-repos, subscription-manager
This system is not registered with an entitlement server. You can use subscription-manager to register.
rhel74                                                                                                                                                                           | 4.1 kB  00:00:00     
rhel74Suppl                                                                                                                                                                      | 4.1 kB  00:00:00     
Package libica-3.0.2-2.el7.s390x already installed and latest version
Nothing to do
```

After the libica utility is installed, use the icaiinfo command to check on the CPACF feature
code enablement. If the Crypto Enablement feature 3863 is installed, you will see that
besides SHA, other algorithms are available with hardware support.
The icainfo command displays which CPACF functions are supported by the implementation
inside the libica library.
Issue the following command to show that the device driver loaded how which cryptographic algorithms will be accelerated and hardware or software way.
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

## Part II - Pervasive Encryption - Enabling OpenSSL and openSSH to use the Hardware
This chapter describes how to use the cryptographic functions of the LinuxONE to encrypt data in flight. This technique means that the data is encrypted and decrypted before and after it is transmitted. We will use OpenSSL, SCP and SFTP to demonstrate the encryption of data in flight.
This chapter also shows how to customize the product to use the LinuxONE hardware encryption features. This chapter includes the following sections:
- Preparing to use OpenSSL
- Configuring OpenSSL
- Testing Hardware Crypto functions with OpenSSL
- Testing Hardware Crypto functions with SCP
- Testing Hardware Crypto functions with SFTP

#### Preparing to use OpenSSL
In the Linux system you use, OpenSSL is already instlaled, and the system is already enabled to use the
cryptographic hardware of the LinuxONE. We also loaded the cryptographic device driver and the
libica 3.0 package to use the crypto hardware.
For the following, the following packages are required for encryption:
- openssl
- openssl098e
- openssl-libs
- openssl-ibmca

During the installation of RHEL 7.4, the package openssl-ibmca was not automatically
installed and needs to be installed manually. Please issue the following command:
```
[root@ghrhel74crypt ~]# yum install openssl-ibmca.s390

[...truncated...]

Installed:
  openssl-ibmca.s390 0:1.3.0-2.el7                                                                                                                                                                      
Dependency Installed:
  libica.s390 0:3.0.2-2.el7                                                                                                                                                                             
Complete!
```
Now all needed packages are successfully installed. At this moment only the default engine of
OpenSSL is available. To check it, please issue the following command:
```
[root@ghrhel74crypt ~]# openssl engine -c
(dynamic) Dynamic engine loading support
```
#### Configuring OpenSSL
To use the ibmca engine and to benefit from the Cryptographic hardware support, the
configuration file of OpenSSL needs to be modified. To customize the OpenSSL configuration
to enable dynamic engine loading for ibmca, complete the following steps:
##### 1/ Locate the OpenSSL configuration file, which in our Red Hat Enterprise Linux 7.4 distribution is in this subdirectory: 
```
```

##### 2/ Make a backup copy of the configuration file
```
[root@ghrhel74crypt ~]# ls -la /etc/pki/tls/openssl.cnf
-rw-r--r--. 1 root root 12376 Sep 25 14:25 /etc/pki/tls/openssl.cnf
[root@itsolnx2 /]# cp -p /etc/pki/tls/openssl.cnf
/etc/pki/tls/openssl.cnf.backup
```

```
[root@ghrhel74crypt ~]# ls -al /etc/pki/tls/openssl.cnf*
-rw-r--r--. 1 root root 10923 Sep 25 14:25 /etc/pki/tls/openssl.cnf
-rw-r--r--. 1 root root 10923 Sep 25 14:26 /etc/pki/tls/openssl.cnf.backup
```

##### 3/ Append content form ibmca configuration file to openssl configuration file
```
[root@ghrhel74crypt ~]# find / -name openssl.cnf.sample.s390x -type f
/usr/share/doc/openssl-ibmca-1.3.0/openssl.cnf.sample.s390x
[root@ghrhel74crypt ~]# ls -al
/usr/share/doc/openssl-ibmca-1.3.0/openssl.cnf.sample.s390x
-rw-r--r--. 1 root root 1396 Mar 31 04:35
/usr/share/doc/openssl-ibmca-1.3.0/openssl.cnf.sample.s390x
```

##### 4 / Append the ibmca-related configuration lines to the OpenSSL configuration file
```
[root@ghrhel74crypt ~]#tee -a /etc/pki/tls/openssl.cnf < /usr/share/doc/openssl-ibmca-1.3.0/openssl.cnf.sample.s390x
```
Make sure that the ibmca section was appended at the end of the OpenSSL configuration file.

##### 5 / Append the ibmca-related configuration lines to the OpenSSL configuration file
The reference to the ibmca section in the OpenSSL configuration file needs to be inserted. Therefore, insert the following line as show below:
openssl_conf = openssl_def
```
[root@ghrhel74crypt ~]# cat /etc/pki/tls/openssl.cnf
#
# OpenSSL example configuration file.
# This is mostly being used for generation of certificate requests.
#
# This definition stops the following lines choking if HOME isn't
# defined.
HOME = .
RANDFILE = $ENV::HOME/.rnd
openssl_conf = openssl_def #<== line inserted
# Extra OBJECT IDENTIFIER info:
#oid_file = $ENV::HOME/.oid
oid_section = new_oids
# To use this configuration file with the "-extfile" option of the
# "openssl x509" utility, name here the section containing the
# X.509v3 extensions to use:
```

#### Testing Hardware Crypto functions
Now that the customization of OpenSSL in done, test whether you can use the LinuxONE hardware cryptographic functions. First, let's check whether the dynamic engine loading support is enabled by default and the engine ibmca is available and used in the installation.
```
[root@ghrhel74crypt ~]# openssl engine -c
(dynamic) Dynamic engine loading support
(ibmca) Ibmca hardware engine support
 [RSA, DSA, DH, RAND, DES-ECB, DES-CBC, DES-OFB, DES-CFB, DES-EDE3, DES-EDE3-CBC,
DES-EDE3-OFB, DES-EDE3-CFB, AES-128-ECB, AES-192-ECB, AES-256-ECB, AES-128-CBC,
AES-192-CBC, AES-256-CBC, AES-128-OFB, AES-192-OFB, AES-256-OFB, AES-128-CFB,
AES-192-CFB, AES-256-CFB, SHA1, SHA256, SHA512]
```

#### Crypto Express6S card support for OpenSSL

### Part III - Pervasive Encryption - Enabling dm-crypt to use the Hardware
The cryptsetup feature provides an interface for configuring encryption on block devices (such as /home or swap partitions), using the Linux kernel device mapper target dm-crypt. It features integrated LUKS support. LUKS standardizes the format of the encrypted disk, which allows different implementations, even from other operating systems, to access and decrypt the disk. LUKS adds metadata to the underlying block device, which contains information about the ciphers used and a default of eight key slots that hold an encrypted version of the master key used to decrypt the device. 
You can unlock the key slots by either providing a password on the command line or using a key file, which could, for example, be encrypted with gpg and stored on an NFS share.

```
[root@ghrhel74crypt ~]# yum install cryptsetup
Loaded plugins: product-id, search-disabled-repos, subscription-manager
This system is not registered with an entitlement server. You can use
subscription-manager to register.
repository
| 4.1 kB 00:00:00
Resolving Dependencies
:
:
Installed:
 cryptsetup.s390x 0:1.7.4-3.el7
Complete!
[root@itsoln1 iso]# rpm -qa | grep crypt*
cryptsetup-libs-1.7.4-3.el7.s390x

cryptsetup-1.7.4-3.el7.s390x
libgcrypt-1.5.3-14.el7.s390x
m2crypto-0.21.1-17.el7.s390x

```

The dm-crypt feature supports various cipher and hashing algorithms that you can select
from the ones that are available in the Kernel and listed in the /proc/crypto procfs file. This
also means that dm-crypt takes advantage of the unique hardware acceleration features of
IBM Z that increase encryption and decryption speed.
Using the cryptsetup command, create a LUKS partition on the respective disk devices. For full disk encryption, use the AES-xts hardware feature. We choose the AES-xts to achieve a security level of reasonable quality with the best encryption mode.
To confirm that is the best choise, you can issue the following command:
```
[root@ghrhel74crypt ~]# cryptsetup benchmark
# Tests are approximate using memory only (no storage IO).
PBKDF2-sha1       265059 iterations per second for 256-bit key
PBKDF2-sha256     278876 iterations per second for 256-bit key
PBKDF2-sha512     187245 iterations per second for 256-bit key
PBKDF2-ripemd160  182551 iterations per second for 256-bit key
PBKDF2-whirlpool  208381 iterations per second for 256-bit key
#  Algorithm | Key |  Encryption |  Decryption
     aes-cbc   128b  2458.2 MiB/s  3794.6 MiB/s
 serpent-cbc   128b    81.4 MiB/s    95.0 MiB/s
 twofish-cbc   128b   154.2 MiB/s   181.8 MiB/s
     aes-cbc   256b  2189.7 MiB/s  3821.0 MiB/s
 serpent-cbc   256b    83.2 MiB/s    94.8 MiB/s
 twofish-cbc   256b   161.3 MiB/s   181.7 MiB/s
     aes-xts   256b  3550.3 MiB/s  3802.4 MiB/s
 serpent-xts   256b    83.4 MiB/s    94.3 MiB/s
 twofish-xts   256b   181.5 MiB/s   177.6 MiB/s
     aes-xts   512b  3766.1 MiB/s  3747.9 MiB/s
 serpent-xts   512b    83.3 MiB/s    94.6 MiB/s
 twofish-xts   512b   181.9 MiB/s   177.0 MiB/s

```

#### A

#### B

#### C


### Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

## Part II - Pervasive Encryption - Enabling OpenSSL and openSSH to use the Hardware
This chapter describes how to use the cryptographic functions of the LinuxONE to encrypt data in flight. This technique means that the data is encrypted and decrypted before and after it is transmitted. We will use OpenSSL, SCP and SFTP to demonstrate the encryption of data in flight.
This chapter also shows how to customize the product to use the LinuxONE hardware encryption features. This chapter includes the following sections:
- Preparing to use OpenSSL
- Configuring OpenSSL
- Testing Hardware Crypto functions with OpenSSL
- Testing Hardware Crypto functions with SCP
- Testing Hardware Crypto functions with SFTP

#### Preparing to use OpenSSL
In the Linux system you use, OpenSSL is already instlaled, and the system is already enabled to use the cryptographic hardware of the LinuxONE. We also loaded the cryptographic device driver and the libica 3.0 package to use the crypto hardware. For the following, the following packages are required for encryption:
- openssl
- openssl098e
- openssl-libs
- openssl-ibmca

During the installation of RHEL 7.4, the package openssl-ibmca was not automatically
installed and needs to be installed manually. Please issue the following command:
```
[root@ghrhel74crypt ~]# yum install openssl-ibmca
```
Now all needed packages are successfully installed. At this moment only the default engine of OpenSSL is available. To check it, please issue the following command:
```
[root@ghrhel74crypt ~]# openssl engine -c
(dynamic) Dynamic engine loading support
```
#### Configuring OpenSSL
To use the ibmca engine and to benefit from the Cryptographic hardware support, the configuration file of OpenSSL needs to be modified. To customize the OpenSSL configuration to enable dynamic engine loading for ibmca, complete the following steps:
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
The cryptsetup feature provides an interface for configuring encryption on block devices (such as /home or swap partitions), using the Linux kernel device mapper target dm-crypt. It features integrated LUKS support. LUKS standardizes the format of the encrypted disk, which allows different implementations, even from other operating systems, to access and decrypt the disk. LUKS adds metadata to the underlying block device, which contains information about the ciphers used and a default of eight key slots that hold an encrypted version of the master key used to decrypt the device. You can unlock the key slots by either providing a password on the command line or using a key file, which could, for example, be encrypted with gpg and stored on an NFS share.

```
[root@ghrhel74crypt ~]# yum install cryptsetup
```

The dm-crypt feature supports various cipher and hashing algorithms that you can select from the ones that are available in the Kernel and listed in the /proc/crypto procfs file. This also means that dm-crypt takes advantage of the unique hardware acceleration features of IBM Z that increase encryption and decryption speed.
Using the cryptsetup command, create a LUKS partition on the respective disk devices. For full disk encryption, use the AES xts hardware feature. We choose the AES-xts to achieve a security level of reasonable quality with the best encryption mode.

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

#### PVS
```
[root@probtp-ihs dev]# pvs
  PV         VG    Fmt  Attr PSize   PFree
  /dev/vdb1  ihsvg lvm2 a--  <25.00g    0 
```
#### VGS
```
[root@probtp-ihs dev]# vgs
  VG    #PV #LV #SN Attr   VSize   VFree
  ihsvg   1   1   0 wz--n- <25.00g    0 
```

#### LVS
```
[root@probtp-ihs dev]# lvs
  LV    VG    Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  ihslv ihsvg -wi-ao---- <25.00g
```

```
[root@probtp-ihs dev]# cryptsetup luksFormat --hash=sha512 --key-size=512 --cipher=aes-xts-plain64 --verify-passphrase /dev/vdc1

WARNING!
========
This will overwrite data on /dev/vdc1 irrevocably.

Are you sure? (Type uppercase yes): YES
Enter passphrase: 
Verify passphrase: 
```

```
[root@probtp-ihs dev]# cryptsetup luksOpen /dev/vdc1 ihscrypt
Enter passphrase for /dev/vdc1: 
```

```
[root@probtp-ihs dev]# ls /dev/m
mapper/ mem     mqueue/ 
```
```
[root@probtp-ihs dev]# ls /dev/mapper/
control  ihscrypt  ihsvg-ihslv
```

```
[root@probtp-ihs dev]# pvcreate /dev/mapper/ihscrypt 
  Physical volume "/dev/mapper/ihscrypt" successfully created.
```

```
[root@probtp-ihs dev]# vgextend ihsvg /dev/mapper/ihscrypt 
  Volume group "ihsvg" successfully extended
```
```
[root@probtp-ihs dev]# vgs
  VG    #PV #LV #SN Attr   VSize  VFree  
  ihsvg   2   1   0 wz--n- 49.99g <25.00g
```

```
[root@probtp-ihs dev]# pvs
  PV                   VG    Fmt  Attr PSize   PFree  
  /dev/mapper/ihscrypt ihsvg lvm2 a--  <25.00g <25.00g
  /dev/vdb1            ihsvg lvm2 a--  <25.00g      0 
```

```
[root@probtp-ihs dev]# pvmove /dev/vdb1 /dev/mapper/ihscrypt 
  /dev/vdb1: Moved: 0.00%
  /dev/vdb1: Moved: 4.83%
  /dev/vdb1: Moved: 9.24%
  /dev/vdb1: Moved: 13.13%
  /dev/vdb1: Moved: 17.16%
  /dev/vdb1: Moved: 22.02%
  /dev/vdb1: Moved: 27.55%
  /dev/vdb1: Moved: 33.08%
  /dev/vdb1: Moved: 36.91%
  /dev/vdb1: Moved: 40.98%
  /dev/vdb1: Moved: 45.46%
  /dev/vdb1: Moved: 48.55%
  /dev/vdb1: Moved: 50.91%
  /dev/vdb1: Moved: 53.52%
  /dev/vdb1: Moved: 57.02%
  /dev/vdb1: Moved: 59.99%
  /dev/vdb1: Moved: 63.03%
  /dev/vdb1: Moved: 66.34%
  /dev/vdb1: Moved: 69.78%
  /dev/vdb1: Moved: 73.37%
  /dev/vdb1: Moved: 76.53%
  /dev/vdb1: Moved: 79.93%
  /dev/vdb1: Moved: 83.43%
  /dev/vdb1: Moved: 86.83%
  /dev/vdb1: Moved: 90.47%
  /dev/vdb1: Moved: 95.17%
  /dev/vdb1: Moved: 98.56%
  /dev/vdb1: Moved: 100.00%
```

```
[root@probtp-ihs dev]# vgreduce ihsvg /dev/vdb1
  Removed "/dev/vdb1" from volume group "ihsvg"
```

```
[root@probtp-ihs dev]# lvs
  LV    VG    Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  ihslv ihsvg -wi-ao---- <25.00g                                                    
```



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

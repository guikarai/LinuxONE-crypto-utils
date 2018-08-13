## Enabling OpenSSL and openSSH to use the Hardware
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

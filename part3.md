
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
#### Using dm-crypt Volumes as LVM Physical Volumes
For the following, we will use LVM method to protect data at rest with dm-crypt at volume level. Objective will be to migrate data from unencrypted volume to dm-crypt volume. This is a 4 steps approach that doesn't required to reboot or to stop running application.3 steps includes the following:
– Step 1: add dm-crypt based physical volume to volume group: vgextend VG PV2
– Step 2: migrate data from V1 to DMV: pvmove V1 DMV
– Step 3: remove unencrypted volume from the volume group: vgreduce VG PV1
Let's do this for real now.

##### PVS
```
[root@ghrhel74crypt ~]# pvs
  PV         VG    Fmt  Attr PSize   PFree
  /dev/vdb1  ihsvg lvm2 a--  <25.00g    0 
```
##### VGS
```
[root@ghrhel74crypt ~]# vgs
  VG    #PV #LV #SN Attr   VSize   VFree
  ihsvg   1   1   0 wz--n- <25.00g    0 
```

##### LVS
```
[root@ghrhel74crypt ~]# lvs
  LV    VG    Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  ihslv ihsvg -wi-ao---- <25.00g
```

```
[root@ghrhel74crypt ~]# cryptsetup luksFormat --hash=sha512 --key-size=512 --cipher=aes-xts-plain64 --verify-passphrase /dev/vdc1

WARNING!
========
This will overwrite data on /dev/vdc1 irrevocably.

Are you sure? (Type uppercase yes): YES
Enter passphrase: 
Verify passphrase: 
```

```
[root@ghrhel74crypt ~]# cryptsetup luksOpen /dev/vdc1 ihscrypt
Enter passphrase for /dev/vdc1: 
```

```
[root@ghrhel74crypt ~]# ls /dev/m
mapper/ mem     mqueue/ 
```
```
[root@ghrhel74crypt ~]# ls /dev/mapper/
control  ihscrypt  ihsvg-ihslv
```

```
[root@ghrhel74crypt ~]# pvcreate /dev/mapper/ihscrypt 
  Physical volume "/dev/mapper/ihscrypt" successfully created.
```

```
[root@ghrhel74crypt ~]# vgextend ihsvg /dev/mapper/ihscrypt 
  Volume group "ihsvg" successfully extended
```
```
[root@probtp-ihs dev]# vgs
  VG    #PV #LV #SN Attr   VSize  VFree  
  ihsvg   2   1   0 wz--n- 49.99g <25.00g
```

```
[root@ghrhel74crypt ~]# pvs
  PV                   VG    Fmt  Attr PSize   PFree  
  /dev/mapper/ihscrypt ihsvg lvm2 a--  <25.00g <25.00g
  /dev/vdb1            ihsvg lvm2 a--  <25.00g      0 
```

```
[root@ghrhel74crypt ~]# pvmove /dev/vdb1 /dev/mapper/ihscrypt 
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
[root@ghrhel74crypt ~]# vgreduce ihsvg /dev/vdb1
  Removed "/dev/vdb1" from volume group "ihsvg"
```

```
[root@ghrhel74crypt ~]# lvs
  LV    VG    Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  ihslv ihsvg -wi-ao---- <25.00g                                                    
```

To be sure that there is a prompt after after a reboot, please create /etc/crypttab with the following content:
```
ihscrypt /dev/vdc1 none
```

You just finished the lab PART III. You are now ready for the part IV.

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

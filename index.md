# Hands-on LAB : Exploiting Crypto Express & CPACF Hardware with LinuxONE

As of March 2018, the LinuxONE has two categories of crypto hardware.
- CPACF – Provides support for symmetric ciphers and secure hash algorithms (SHA) on every central processor. The potential encryption/decryption throughput scales with the number of CPs.
- CEX6S – The Crypto Express feature traditionally could be configured in two ways: Either as cryptographic Coprocessor (CEXC) for secure key encrypted transactions, or as cryptographic Accelerator (CEXA) for Secure Sockets Layer (SSL) acceleration. A CEXA works in clear key mode. The Crypto Express 6S allows for a third mode as a Secure IBM CCA Coprocessor

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
- Enabling Linux to use the Hardware
- Pervasive Encryption - Enabling OpenSSL and openSSH to use the Hardware
- Pervasive Encryption - Enabling dm-crypt to use the Hardware
- Optimization - Enabling Java and WebSphere to Exploit the Crypto Hardware
- Optimization - Configuring the IBM HTTP Server to use the Crypto Hardware
- Optimization - Enabling the WAS Plugin to Use the Crypto Hardware

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
features	: esan3 zarch stfle **msa ldisp eimm dfp edat etf3eh highgprs te vx sie 
cache0          : level=1 type=Data scope=Private size=128K line_size=256 associativity=8
cache1          : level=1 type=Instruction scope=Private size=128K line_size=256 associativity=8
cache2          : level=2 type=Data scope=Private size=4096K line_size=256 associativity=8
cache3          : level=2 type=Instruction scope=Private size=2048K line_size=256 associativity=8
cache4          : level=3 type=Unified scope=Shared size=131072K line_size=256 associativity=32
cache5          : level=4 type=Unified scope=Shared size=688128K line_size=256 associativity=42
processor 0: version = FF,  identification = 243EF7,  machine = 3906
processor 1: version = FF,  identification = 243EF7,  machine = 3906
```
#### Required package

#### ICAINFO
“icainfo” will show the cryptographic operations supported by libica on your system.
Influenced by processor model and microcode enablement feature.

#### ICAINFO

## Part II - Pervasive Encryption - Enabling OpenSSL and openSSH to use the Hardware
## Part III - Pervasive Encryption - Enabling dm-crypt to use the Hardware
## Part IV - Optimization - Enabling Java and WebSphere to Exploit the Crypto Hardware
## Part V - Optimization - Configuring the IBM HTTP Server to use the Crypto Hardware
## Part VI - Optimization - Enabling the WAS Plugin to Use the Crypto Hardware

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

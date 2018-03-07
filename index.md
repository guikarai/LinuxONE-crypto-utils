# Hands-on LAB - Exploiting crypto express & CPACF hardware with LinuxONE
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
[- Part I : Enabling Linux to use the Hardware](https://github.com/guikarai/LinuxONE-crypto-utils/blob/master/part1.md)
[- Part II : Pervasive Encryption - Enabling OpenSSL and openSSH to use the Hardware](https://www.google.com)
[- Part III : Pervasive Encryption - Enabling dm-crypt to use the Hardware](https://www.google.com)
[- Part IV : Optimization - Enabling Java and WebSphere to Exploit the Crypto Hardware](https://www.google.com)
[- Part V : Optimization - Configuring the IBM HTTP Server to use the Crypto Hardware](https://www.google.com)
[- Part VI : Optimization - Enabling the WAS Plugin to Use the Crypto Hardware](https://www.google.com)


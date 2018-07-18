## Configuring Apache to use the hardware crypto
This section provides information about how to configure an Apache web server under RHEL to exploit cryptographic hardware functions available with IBM Z.
The Apache interface to OpenSSL is the mod ssl module. OpenSSL provides built-in CPACF-support for AES in ECB, CBC, CTR, CCM and GCM mode, SHA-1, SHA-256 and SHA-512 as well as for the latter two in their truncated versions, SHA-224 respectively SHA-384. The ibmca engine is the OpenSSL interface to the libica library which provides CPACF-support for various ciphers, MACs and hashes, for NIST SP 800-90 compliant pseudo-random number generation as well as support for Crypto Express (CEX5S) adapters in Accelerator (CEX5A/CEX6A) or CCA Coprocessor (CEX5C/CEX6C) mode. These crypto-adapters accelerate the modular exponentiation operation that is used in the RSA, DH and DSA public-key crypto systems. If a CEX5C adapter is available, its hardware random number generator is used to seed libica’s pseudo random number generation.

### Installing Apache and the pre-requisite packages
To instal the required packages, please issue the following command:
```
yum install httpd
```

### Configuring Apache
The Apache configuration files reside in /etc/httpd/conf/httpd.conf
The mod ssl_module configuration file is /etc/httpd/conf.d/ssl.conf

Add the following line to your configuration:
SSLCryptoDevice ibmca

## Configuring Apache to use the hardware crypto
This section provides information about how to configure an Apache web server under RHEL to exploit cryptographic hardware functions available with IBM Z.

The Apache interface to OpenSSL is the mod ssl module. OpenSSL provides built-in CPACF-support for AES in ECB, CBC, CTR, CCM and GCM mode, SHA-1, SHA-256 and SHA-512 as well as for the latter two in their truncated versions, SHA-224 respectively SHA-384. 

The ibmca engine is the OpenSSL interface to the libica library which provides CPACF-support for various ciphers, MACs and hashes, for NIST SP 800-90 compliant pseudo-random number generation as well as support for Crypto Express (CEX5S) adapters in Accelerator (CEX5A/CEX6A) or CCA Coprocessor (CEX5C/CEX6C) mode. 

These crypto-adapters accelerate the modular exponentiation operation that is used in the RSA, DH and DSA public-key crypto systems.

If a CEX5C adapter is available, its hardware random number generator is used to seed libica’s pseudo random number generation.

### Installing Apache and the pre-requisite packages
To enable the secure server, you must have the following packages installed at a minimum:

* httpd - The httpd package contains the httpd daemon and related utilities, configuration files, icons, Apache HTTP Server modules, man pages, and other files used by the Apache HTTP Server.

* mod_ssl - The mod_ssl package includes the mod_ssl module, which provides strong cryptography for the Apache HTTP Server via the Secure Sockets Layer (SSL) and Transport Layer Security (TLS) protocols.

* openssl - The openssl package contains the OpenSSL toolkit. The OpenSSL toolkit implements the SSL and TLS protocols, and also includes a general purpose cryptography library.

To instal the required packages, please issue the following command:
```
[root@ghrhel74crypt conf]# yum install httpd openssl openssl-ibmca mod_ssl
```
To start apache, please issue the following command:
```
[root@ghrhel74crypt conf]# service httpd start
```
### Creating TLS crypto materials

Step 1: Generate a Private Key

The openssl toolkit is used to generate an RSA Private Key and CSR (Certificate Signing Request). It can also be used to generate self-signed certificates which can be used for testing purposes or internal usage.

The first step is to create your RSA Private Key. This key is a 1024 bit RSA key which is encrypted using Triple-DES and stored in a PEM format so that it is readable as ASCII text.

openssl genrsa -des3 -out server.key 1024

Generating RSA private key, 1024 bit long modulus
.........................................................++++++
........++++++
e is 65537 (0x10001)
Enter PEM pass phrase:
Verifying password - Enter PEM pass phrase:

Step 2: Generate a CSR (Certificate Signing Request)

Once the private key is generated a Certificate Signing Request can be generated. The CSR is then used in one of two ways. Ideally, the CSR will be sent to a Certificate Authority, such as Thawte or Verisign who will verify the identity of the requestor and issue a signed certificate. The second option is to self-sign the CSR, which will be demonstrated in the next section.

During the generation of the CSR, you will be prompted for several pieces of information. These are the X.509 attributes of the certificate. One of the prompts will be for "Common Name (e.g., YOUR name)". It is important that this field be filled in with the fully qualified domain name of the server to be protected by SSL. If the website to be protected will be https://public.akadia.com, then enter public.akadia.com at this prompt. The command to generate the CSR is as follows:

openssl req -new -key server.key -out server.csr

Country Name (2 letter code) [GB]:CH
State or Province Name (full name) [Berkshire]:Bern
Locality Name (eg, city) [Newbury]:Oberdiessbach
Organization Name (eg, company) [My Company Ltd]:Akadia AG
Organizational Unit Name (eg, section) []:Information Technology
Common Name (eg, your name or your server's hostname) []:public.akadia.com
Email Address []:martin dot zahn at akadia dot ch
Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

Step 3: Remove Passphrase from Key

One unfortunate side-effect of the pass-phrased private key is that Apache will ask for the pass-phrase each time the web server is started. Obviously this is not necessarily convenient as someone will not always be around to type in the pass-phrase, such as after a reboot or crash. mod_ssl includes the ability to use an external program in place of the built-in pass-phrase dialog, however, this is not necessarily the most secure option either. It is possible to remove the Triple-DES encryption from the key, thereby no longer needing to type in a pass-phrase. If the private key is no longer encrypted, it is critical that this file only be readable by the root user! If your system is ever compromised and a third party obtains your unencrypted private key, the corresponding certificate will need to be revoked. With that being said, use the following command to remove the pass-phrase from the key:

cp server.key server.key.org
openssl rsa -in server.key.org -out server.key

The newly created server.key file has no more passphrase in it.

-rw-r--r-- 1 root root 745 Jun 29 12:19 server.csr
-rw-r--r-- 1 root root 891 Jun 29 13:22 server.key
-rw-r--r-- 1 root root 963 Jun 29 13:22 server.key.org

Step 4: Generating a Self-Signed Certificate

At this point you will need to generate a self-signed certificate because you either don't plan on having your certificate signed by a CA, or you wish to test your new SSL implementation while the CA is signing your certificate. This temporary certificate will generate an error in the client browser to the effect that the signing certificate authority is unknown and not trusted.

To generate a temporary certificate which is good for 365 days, issue the following command:

openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
Signature ok
subject=/C=CH/ST=Bern/L=Oberdiessbach/O=Akadia AG/OU=Information
Technology/CN=public.akadia.com/Email=martin dot zahn at akadia dot ch
Getting Private key

Step 5: Installing the Private Key and Certificate

When Apache with mod_ssl is installed, it creates several directories in the Apache config directory. The location of this directory will differ depending on how Apache was compiled.

cp server.crt /usr/local/apache/conf/ssl.crt
cp server.key /usr/local/apache/conf/ssl.key

Step 6: Configuring SSL Enabled Virtual Hosts

SSLEngine on
SSLCertificateFile /usr/local/apache/conf/ssl.crt/server.crt
SSLCertificateKeyFile /usr/local/apache/conf/ssl.key/server.key
SetEnvIf User-Agent ".*MSIE.*" nokeepalive ssl-unclean-shutdown
CustomLog logs/ssl_request_log \
   "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"

Step 7: Restart Apache and Test
To restart apache, please issue the following command
```
service httpd restart
```

### Configuring Apache
The Apache configuration files reside in /etc/httpd/conf/httpd.conf
The mod ssl_module configuration file is /etc/httpd/conf.d/ssl.conf

Let's change the configuration file of mod_ssl to enable hardware acceleration of SSL/TLS communication of Apache. Please edit the following configuration file issuing the following command:
```
[root@ghrhel74crypt conf]# vi /etc/httpd/conf.d/ssl.conf
```

From there, add the following line to your configuration (or if SSLCryptoDevice is already set, "ubsec" by "ibmca" as follow:
```
SSLCryptoDevice ibmca
#SSLCryptoDevice ubsec
```

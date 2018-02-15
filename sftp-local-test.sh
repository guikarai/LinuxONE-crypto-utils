#!/bin/bash
for cipher in aes128-ctr aes192-ctr aes256-ctr arcfour256 arcfour128 aes128-cbc 3des-cbc blowfish-cbc cast128-cbc aes192-cbc aes256-cbc arcfour ; do
        echo "$cipher"
        for try in 1 2 ; do
                sftp -c "$cipher" root@localhost:/home/guillaumeh/LinuxONE-crypto-utils/5G.file /dev/null
        done
done

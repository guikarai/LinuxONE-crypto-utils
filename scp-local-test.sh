for cipher in aes128-ctr aes192-ctr aes256-ctr arcfour256 arcfour128 aes128-cbc 3des-cbc blowfish-cbc cast128-cbc aes192-cbc aes256-cbc arcfour ; do
        echo "$cipher"
        for try in 1 2 ; do
                scp -c "$cipher" 5G.file root@localhost:/dev/null
        done
done

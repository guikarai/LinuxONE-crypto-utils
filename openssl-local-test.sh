echo "#Compare relative performance of various ciphers in 10 seconds (New Session only)"
# 10-second tests
IFS=":"
for c in $(openssl ciphers -tls1_2 RSA); do
  echo $c
  openssl s_time -connect 10.3.57.112:443 \
    -www / -new -time 10 -cipher $c 2>&1 | \
    grep bytes
  echo
done

echo "#Compare relative performance of various ciphers in 10 seconds (Session reused)"
# 10-second tests
IFS=":"
for c in $(openssl ciphers -tls1_2 RSA); do
  echo $c
  openssl s_time -connect 10.3.57.112:443 \
    -www / -reuse -time 10 -cipher $c 2>&1 | \
    grep bytes
  echo
done

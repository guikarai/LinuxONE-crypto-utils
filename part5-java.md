# Part VI : Optimization - Enabling JAVA to use the Crypto Hardware

Assess how many application is accessing your hardware implementation. Please issue the following command:
```
```
As you can see there are 4 application accessing the crypto card implementation.
Let's add a new one with JAVA!

Let's install Java in its version 1.8.0 from IBM.
```
[root@ghrhel74crypt ~]# yum install java-1.8.0-ibm*
```

Let's start by modifying the Java.security file. It may reside in different place according configuration. Let's check where this file is. Please issue the following command:
```
[root@ghrhel74crypt ~]# find / -name java.security
/usr/lib/jvm/java-1.8.0-ibm-1.8.0.4.5-1jpp.1.el7_3.s390x/jre/lib/security/java.security
```

Let's move in the folder of java.security. Please issue the folowing command:
```
[root@ghrhel74crypt ~]# cd /usr/lib/jvm/java-1.8.0-ibm-1.8.0.4.5-1jpp.1.el7_3.s390x/jre/lib/security/
```

Let's edit the java.seurity file:

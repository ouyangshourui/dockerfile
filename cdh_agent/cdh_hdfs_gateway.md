# 1、Dockerfile

```
FROM   docker.io/centos:centos7.2.1511
MAINTAINER  "https://github.com/ouyangshourui"
RUN yum -y install net-tools
RUN yum -y install openssh-server
RUN yum -y install openssh-clients
RUN yum -y  install krb5-workstation krb5-libs krb5-auth-dialog 1.3
RUN yum -y install nss-pam-ldapd
RUN yum -y install authconfig
RUN yum -y install initscripts
RUN echo "root:123456" | chpasswd
RUN systemctl enable sshd
CMD ["/usr/sbin/init"]
```
# 2、make images

```
imagename=hdfs_agent
docker build  -t centos:hdfs_gateway
```
生成了centos:hdfs_gateway

# 3、制作hdfs gateway

```
docker run --name hdfs_gateway -v `pwd`/hosts:/etc/hosts -v /etc/localtime:/etc/localtime:ro -itd centos:hdfs_gateway /bin/sh
```
## 进入hdfs_gateway

```
docker exec -it hdfs_gateway /bin/sh
```

## 拷贝kerberos


```
scp 10.214.128.67:/etc/krb5.conf /etc

```

## 拷贝hadoop client

```
scp -r 10.214.128.67:/opt/cloudera /opt
scp -r /etc/hadoop  /etc
```

## 拷贝ktab

```
kadmin.local: addprinc -randkey  deepinsight_app_user@IDC.WANDA-GROUP.NET

kadmin.local: xst -norandkey -k deepinsight_app_user.keytab  deepinsight_app_user@IDC.WANDA-GROUP.NET

kinit -k -t deepinsight_app_user.keytab deepinsight_app_user@IDC.WANDA-GROUP.NET
 
 scp deepinsight_app_user.keytab  /opt/
```

## 拷贝java

```
scp -r 10.214.128.67:/user/java/laster /user/java
```

## 设置.bashrc

```
export JAVA_HOME=/usr/java/latest
export HADOOP_HOME=/opt/cloudera/parcels/CDH
export PATH=$HADOOP_HOME/bin:$JAVA_HOME/bin:$PATH
```

# 3、制作hdfs_gateway_kerberos images

```
docker commit hdfs_gateway centos:hdfs_gateway_kerberos
```

# 4、启动centos:hdfs_gateway_kerberos的container

```
docker run --name hdfs_gateway_kerberos -v `pwd`/hosts:/etc/hosts -v /etc/localtime:/etc/localtime:ro -v /opt/hdfs:/opt/hdfs -itd centos:hdfs_gateway_kerberos /bin/sh
```
# 5、测试

进入hdfs_gateway_kerberos

```
sh-4.2# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: deepinsight_app_user@IDC.WANDA-GROUP.NET

Valid starting     Expires            Service principal
03/03/17 12:25:57  03/04/17 12:25:57  krbtgt/IDC.WANDA-GROUP.NET@IDC.WANDA-GROUP.NET
        renew until 03/10/17 12:25:57
sh-4.2# hadoop fs -ls /user
sh: hadoop: command not found
sh-4.2# hadoop fs -ls /user
sh: hadoop: command not found
sh-4.2# bash    
bash: warning: setlocale: LC_CTYPE: cannot change locale (en_US.UTF-8): No such file or directory
bash: warning: setlocale: LC_COLLATE: cannot change locale (en_US.UTF-8): No such file or directory
bash: warning: setlocale: LC_MESSAGES: cannot change locale (en_US.UTF-8): No such file or directory
bash: warning: setlocale: LC_NUMERIC: cannot change locale (en_US.UTF-8): No such file or directory
bash: warning: setlocale: LC_TIME: cannot change locale (en_US.UTF-8): No such file or directory
[root@21fa3a304745 /]# hadoop fs -ls 
/opt/cloudera/parcels/CDH-5.7.1-1.cdh5.7.1.p0.11/bin/../lib/hadoop/bin/hadoop: line 20: which: command not found
dirname: missing operand
Try 'dirname --help' for more information.
ls: `.': No such file or directory
[root@21fa3a304745 /]# hadoop fs -ls /
/opt/cloudera/parcels/CDH-5.7.1-1.cdh5.7.1.p0.11/bin/../lib/hadoop/bin/hadoop: line 20: which: command not found
dirname: missing operand
Try 'dirname --help' for more information.
Found 7 items
drwxr-xr-x   - hdfs  supergroup          0 2017-03-03 03:35 /data
drwx------   - hbase hbase               0 2016-12-23 13:46 /hbase
drwxrwx--x   - hive  hive                0 2017-02-16 01:35 /raw
drwxr-xr-x   - hdfs  supergroup          0 2016-06-21 12:50 /raw.db
drwxrwxr-x   - solr  solr                0 2016-06-12 15:11 /solr
drwxrwxrwt   - hdfs  supergroup          0 2017-03-02 17:04 /tmp
drwxr-xr-x   - hdfs  supergroup          0 2017-02-09 03:19 /user
```

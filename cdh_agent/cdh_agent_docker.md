 
# CDH Gateway docker实战 
CDH 生产集群的Gateway节点需要给用户提供所有组件(HDFS,YARN,HBase,Impala、Spark)的gateway。在目前的使用情况下遇到的两个问题：

- gateway host压力不断增加，用户任务相互影响严重；
- 用户需要在gateway上面部署单独的组件（比如phonix querey server）并要修改gateway上面的配置。
为了解决这两个问题，选择将gateway 节点部署到docker的container里面。为了保证用户无缝切换到docker环境，下面几个问题需要考虑：
-  container 需要提供一个局域网ip＋port，用户可以通过ssh 登录到docker里面执行相关命令；
-  cm 可以监控到container 里面的cm agent 状态；
-  container 可以无缝迁移到别的节点，保证cm agent 可扩张行；

为了解决上面几个问题，我们选择给每一个container 提供一个独立的ip，初步选择了pipework＋docker的方案，有docker基础使用经验后再迁移到kubernetes或者openshift上面。我简单介绍一下pipework：

- Pipework lets you connect together containers in arbitrarily complex scenarios. 
- Pipework uses cgroups and namespace and works with "plain" LXC containers (created with lxc-start), and with the awesome Docker.

实现步骤：

## 1、Dockerfile 
```
FROM   docker.io/centos:centos7.2.1511
MAINTAINER  "https://github.com/ouyangshourui"
RUN yum -y install net-tools
＃install ssh service
RUN yum -y install openssh-server
RUN yum -y install openssh-clients
＃install kerberos client
RUN yum -y  install krb5-workstation krb5-libs krb5-auth-dialog 1.3
＃install ldap client
RUN yum -y install nss-pam-ldapd
＃install ifconfig tool
RUN yum -y install authconfig
＃install system rc.d folder
RUN yum -y install initscripts
# set root password 
RUN echo "root:123456" | chpasswd
RUN systemctl enable sshd
RUN   systemctl enable   nslcd
CMD ["/usr/sbin/init"]
```
## 2、load image
在dockerfile目录下面执行：
```
imagename=cdh_agent
dip=CDH_gateway_host_ip
docker build -t centos:7.2.1511${imagename} .
docker save   centos:7.2.1511${imagename} > 7.2.1511${imagename}.tar
scp 7.2.1511${imagename}.tar  $dip:/opt
#load 到目标机器
ssh $dip "docker rmi centos:7.2.1511${imagename} && docker load -i /opt/7.2.1511${imagename}.tar"
```

## 3、install pipework
到docker 宿主机环境安装pipework
- 官方网站：https://github.com/jpetazzo/pipework
- 宿主环境：centos7
安装pipework
```
# wget https://github.com/jpetazzo/pipework/archive/master.zip
# unzip master.zip 
# cp pipework-master/pipework  /usr/local/bin/
# chmod +x /usr/local/bin/pipework 
```

## 4、启动container 并配置IP
```
imagename=cdh_agent
dname=10.214.128.27
docker run  --name $dname --net=none -v /etc/hosts:/etc/hosts  --hostname testbig27.wanda.cn    -v /etc/localtime:/etc/localtime:ro    --privileged -d centos:${dname}  /sbin/init 
#配置ip
pipework br0   $dname 10.214.128.27/24@10.214.128.1
```
docker ps 查看相关信息：
```
[root@ctum2f0802001 ~]# docker ps
CONTAINER ID        IMAGE                              COMMAND             CREATED             STATUS              PORTS               NAMES
dab99972e41d        centos:7.2.1511cdh_agent  "/sbin/init"        39 hours ago        Up 39 hours                             10.214.128.27
```
## 5、 安装gateway相关依赖
### 1)拷贝kerberos 配置文件
  scp  krb5.conf /etc/krb5.conf
### 2)配置ldap client
  ```
    systemctl stop   nslcd

  authconfig --enableldap --enableldapauth --ldapserver=ldapserver:389 --ldapbasedn="dc=idc,dc=wanda-group,dc=net" --enablemkhomedir --update
  
  systemctl start   nslcd
  ```
### 3)jdk 安装
 安装jdk1.8 ，安装路径如下：
 ```
 # pwd
/usr/java
# ll
total 4
lrwxrwxrwx. 1 root root   16 Jun 14  2016 default -> /usr/java/latest
drwxr-xr-x. 9 root root 4096 Jun 14  2016 jdk1.8.0_60
lrwxrwxrwx. 1 root root   21 Jun 14  2016 latest -> /usr/java/jdk1.8.0_60
 ```
 
#  5、 安装gateway
CDH console -> hosts -> add host

![image](https://github.com/ouyangshourui/dockerfile/blob/master/httpd/add_gateway.png)

按照执行步骤执行即可。最后在CDH consle 显示如下：
![image](https://github.com/ouyangshourui/dockerfile/blob/master/httpd/docker_agent.png)

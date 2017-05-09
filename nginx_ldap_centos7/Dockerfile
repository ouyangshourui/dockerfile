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
RUN yum -y install unzip
RUN yum -y install  gcc-c++ gcc 
RUN yum -y install zlib-devel
RUN yum -y install openldap-devel
RUN yum -y install openssl*
ADD pcre-8.39.zip  /opt/
ADD nginx-1.12.0.zip /opt
ADD nginx-auth-ldap.zip /opt
WORKDIR /opt/
RUN unzip pcre-8.39.zip
RUN unzip nginx-1.12.0.zip
RUN unzip nginx-auth-ldap.zip
WORKDIR /opt/pcre-8.39
RUN    /opt/pcre-8.39/configure && make && make install
WORKDIR /opt/nginx-1.12.0
RUN /opt/nginx-1.12.0/configure  --add-module=../nginx-auth-ldap  && make && make install
ADD nginx.conf /opt
RUN \cp /opt/nginx.conf /usr/local/nginx/conf/nginx.conf
# nginx start command : /usr/local/sbin/nginx
# change nginx command :vim /usr/local/nginx/conf/nginx.conf  && /usr/local/sbin/nginx -s reload
CMD ["/usr/sbin/init"]

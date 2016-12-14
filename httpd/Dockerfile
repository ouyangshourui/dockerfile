FROM  centos:centos7.2.1511
MAINTAINER  "ouyangshourui"
RUN   mkdir -p /usr/java
#COPY jdk1.8.0_60.tar    /usr/java
#WORKDIR /usr/java  
#RUN   tar -xvf jdk1.8.0_60.tar
#RUN   yum -y install mysql
RUN   yum  -y install http*
EXPOSE 80
RUN  systemctl enable httpd.service
CMD ["/usr/sbin/init"]

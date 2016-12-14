docker build -t centos:java1.8 .

docker stop  http_server  && docker rm http_server  && docker run  --name http_server --privileged -d -p 10080:80 centos:java1.8 /sbin/init  

docker exec -it http_server  /bin/sh 

docker exec -it http_server  systemctl  status  httpd

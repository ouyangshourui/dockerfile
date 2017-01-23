 
# CDH gateway docker 制作和部署实战 
CDH 生产集群的Gateway节点需要给用户提供所有组件(HDFS,YARN,HBase,Impala、Spark)的gateway。在目前的使用情况下遇到的两个问题：

- gateway host压力不断增加，用户任务相互影响严重；
- 用户需要在gateway上面部署单独的组件（比如phonix querey server）并要修改gateway上面的配置。
为了解决这两个问题，选择将gateway 节点部署到docker的container里面。

 为了保证用户无缝切换到docker环境，下面几个问题需要考虑：
-  container 需要提供一个局域网ip＋port，用户可以通过ssh 登录到docker里面执行相关命令；
-  cm 可以监控到container 里面的cm agent 状态；
-  container 可以无缝迁移到别的节点，保证cm agent 可扩张行；

为了解决上面几个问题，我们选择给每一个container 提供一个独立的ip，初步选择了pipework＋docker的方案，有docker基础使用经验后再迁移到kubernetes或者openshift上面。我简单介绍一下pipework：
```
Pipework lets you connect together containers in arbitrarily complex scenarios. Pipework uses cgroups and namespace and works with "plain" LXC containers (created with lxc-start), and with the awesome Docker.
```
实现步骤：
## docker file 制作

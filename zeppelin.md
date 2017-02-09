# Zeppelin的编译与安装

## 一、前言

本文档说明在万达云基地编译、安装Zeppelin的操作过程。文档有如下前提假设：

* 操作系统为CentOS7.2
* 已配置yum repo，包含操作系统自身的repo、EPEL的repo
* 已安装Git，并且编译人员已在GitHub中申请配置了账户
* 已安装CDH-5.5.2，且编译节点是其中一个节点

安装前提与安装步骤亦可参考[Zeppelin](https://zeppelin.incubator.apache.org/)官网说明

---------------------------------------------------

## 二、编译
  
编译过程分为以下三个大的过程：
1. 从GitHub下载Zeppelin源代码，并修正其中一行配置（NPM相关）
2. 安装编译Zeppelin所需的各种前提软件
3. 编译基于CDH-5.5.2的Zeppelin
  
下面对这三步分别说明。

### 2.1 下载Zeppelin源代码

1. 进入Git下载的根目录，如 `$ cd ~/_git/github.com/apache`
2. 从GitHub下载源代码: `$ git clone https://github.com/apache/incubator-zeppelin.git`
3. 修正配置：  
    进入目录：`$ cd /incubator-zeppelin/zeppelin-web`  
    编辑package.json，删除行： `"karma-phantomjs-launcher": "~0.1.4",`  
    保存文件  
    提交文件：`$ git submit -m "delete one line in zeppelin-web/package.json"`
    
### 2.2 安装Zeppelin的前提软件

1. 安装JDK，安装版本是JDK-1.8.0_60（此外CDH推荐版本），具体步骤这里不再赘述
2. 安装NPM，命令：`sudo yum install npm`
3. 安装FontConfig，命令：`sudo yum install fontconfig`
4. 安装Maven，版本要求3.1.x以上，步骤如下：  
    下载最新版Mave,这里是安装的3.3.9，下载这里不赘述  
    ```
    $ sudo tar -zvxf apache-maven-3.3.9-bin.tar.gz -c /usr/local/
    $ sudo ln -s /usr/local/apache-maven-3.3.9/bin/mvn /usr/local/bin/mvn
    ```
    编辑/etc/profile，为maven添加：`export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=1024m"`  
5. 验证安装的软件
    ```
    $ node --version  # 验证NPM
    $ mvn -version    # 验证Maven
    ```

### 2.3 编译Zeppelin
1. 编译
    ```
    $ cd ~/_git/github.com/apache/incubator-zeppelin
    $ mvn clean package -Pspark-1.5 -Phadoop-2.6 -Dhadoop.version=2.6.0-cdh5.5.2 -Pyarn -Ppyspark \
        -Pvendor-repo -DskipTests
    ```
2. 打包
    ```
    $ mvn clean package -Pbuild-distr -Pspark-1.5 -Phadoop-2.6 -Dhadoop.version=2.6.0-cdh5.5.2 \
        -Pyarn -Ppyspark -Pvendor-repo -DskipTests
    ```
     生成的tar.gz包在`~/github.com/apache/incubator-zeppelin/zeppelin-distribution/target`目录下  
    * **注意1：由于maven编译需要不断从网上下载文件，而带宽有限，编译过程会很长，甚至几个小时，编译前应做    好心理准备**
    * **注意2：若发生下载超时从而编译中断的情况，可重新执行mvn的编译命令，继续编译**
    * **注意3：若编译成功，应得到类似如下输出：**
    ```
      [INFO] Reactor Summary:
      [INFO] 
      [INFO] Zeppelin ........................................... SUCCESS [  1.751 s]
      [INFO] Zeppelin: Interpreter .............................. SUCCESS [  4.480 s]
      [INFO] Zeppelin: Zengine .................................. SUCCESS [  1.688 s]
      [INFO] Zeppelin: Display system apis ...................... SUCCESS [  7.433 s]
      [INFO] Zeppelin: Spark dependencies ....................... SUCCESS [ 23.563 s]
      [INFO] Zeppelin: Spark .................................... SUCCESS [ 10.695 s]
      [INFO] Zeppelin: Markdown interpreter ..................... SUCCESS [  0.185 s]
      [INFO] Zeppelin: Angular interpreter ...................... SUCCESS [  0.213 s]
      [INFO] Zeppelin: Shell interpreter ........................ SUCCESS [  0.154 s]
      [INFO] Zeppelin: Hive interpreter ......................... SUCCESS [  1.021 s]
      [INFO] Zeppelin: HBase interpreter ........................ SUCCESS [  1.544 s]
      [INFO] Zeppelin: Apache Phoenix Interpreter ............... SUCCESS [  1.641 s]
      [INFO] Zeppelin: PostgreSQL interpreter ................... SUCCESS [  0.249 s]
      [INFO] Zeppelin: JDBC interpreter ......................... SUCCESS [  0.233 s]
      [INFO] Zeppelin: Tajo interpreter ......................... SUCCESS [  0.393 s]
      [INFO] Zeppelin File System Interpreters .................. SUCCESS [  0.457 s]
      [INFO] Zeppelin: Flink .................................... SUCCESS [  3.643 s]
      [INFO] Zeppelin: Apache Ignite interpreter ................ SUCCESS [  0.387 s]
      [INFO] Zeppelin: Kylin interpreter ........................ SUCCESS [  0.205 s]
      [INFO] Zeppelin: Lens interpreter ......................... SUCCESS [  1.095 s]
      [INFO] Zeppelin: Cassandra ................................ SUCCESS [ 25.672 s]
      [INFO] Zeppelin: Elasticsearch interpreter ................ SUCCESS [  1.087 s]
      [INFO] Zeppelin: Alluxio interpreter ...................... SUCCESS [  0.997 s]
      [INFO] Zeppelin: web Application .......................... SUCCESS [ 38.544 s]
      [INFO] Zeppelin: Server ................................... SUCCESS [ 26.353 s]
      [INFO] Zeppelin: Packaging distribution ................... SUCCESS [  0.530 s]
      [INFO] ------------------------------------------------------------------------
      [INFO] BUILD SUCCESS
      [INFO] ------------------------------------------------------------------------
      [INFO] Total time: 02:34 min
      [INFO] Finished at: 2016-03-22T17:21:53+08:00
      [INFO] Final Memory: 189M/1938M
      [INFO] ------------------------------------------------------------------------
    ``` 

---------------------------------------------------

## 三、安装与配置

### 3.1 设置用户与安装目录

设置一个zeppelin用户，专门运行zeppelin服务  

    $ sudo useradd zeppelin
    $ sudo passwd XXXXXX  # XXXXX为zeppelin用户的密码
    $ su - zeppelin  # 切换为zeppelin用户
    $ mkdir zeppelin  # ~/zeppelin作为zeppelin解压tar包的根目录

### 3.2 安装
1. 执行以下命令部署软件
    ```
    $ su - zeppelin  #切换到zeppelin用户
    $ tar -zvxf zeppelin-0.6.0-incubating-SNAPSHOT.tar.gz -C ~/zeppelin/
    $ cd ~/zeppelin/zeppelin-0.6.0-incubating-SNAPSHOT/conf
    $ cp zeppelin-env.sh.template zeppelin-env.sh
    $ cp zeppelin-site.xml.template zeppelin-site.xml
    ```
    
2. 修改zeppelin-site.xml，将zeppelin.server.port改为10001  
*注：这是因为云基地的端口为10000-15000，故这里将端口由缺省的8080改为10001*

3. 修改zeppelin-env.sh，添加以下内容
    ```
    export ZEPPELIN_MEM="-Xmx4096m -XX:MaxPermSize-2048m"
    export SPARK_HOME=/opt/cloudera/parcels/CDH/lib/spark
    export SPARK_SUBMIT_OPTIONS="--driver-memory 2G --executor-memory 6G"
    export HADOOP_CONF_DIR=/etc/hadoop/conf
    ```  
    _注：SPARK_HOME与HADOOP_CONF_DIR为必须的配置，路径应根据实际环境进行设置，ZEPPELIN_MEM与SPARK_SUBMIT_OPTIONS是用来改善性能的配置，其值可根据实际情况相应调整_

### 3.2 启动  

部署Zeppelin并配置完毕后，用如下命令启动Zeppelin  
    
    $ cd ~/zeppelin/zeppelin-0.6.0-incubating-SNAPSHOT
    $ bin/zeppelin-daemon.sh start

### 3.3 设置
    
启动Zeppelin后，需在Zeppelin界面里进一步设置如下属性：

* 进入Interpreter界面设置以下属性并保存
* 设置spark运行模式：`master=yarn-client`
* 设置hive JDBC：`jdbc:hive2://10.209.22.141:10000`

### 3.4 停止

如果要停止Zeppelin，可用以下命令：

    $ cd ~/zeppelin/zeppelin-0.6.0-incubating-SNAPSHOT
    $ bin/zeppelin-daemon.sh stop
    

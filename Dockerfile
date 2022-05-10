# 使用Ubuntu文件系统
FROM ubuntu:20.04

# 定义Hadoop的环境变量
ENV HADOOP_HOME "/usr/local/hadoop"
ENV HADOOP_STREAMING_HOME "$HADOOP_HOME/share/hadoop/tools/lib"

# 定义Shell
SHELL ["/bin/bash", "-c"]

# 安装一系列必须软件如Python、JDK、SSH工具（并配置SSH相关参数）
RUN apt update \
    && apt install -y python3 python3-venv openjdk-8-jdk wget ssh openssh-server openssh-client net-tools nano iputils-ping \
    && echo 'ssh:ALL:allow' >> /etc/hosts.allow \
    && echo 'sshd:ALL:allow' >> /etc/hosts.allow \
    && ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && service ssh restart
    
# 下载并解压Hadoop
RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.2/hadoop-3.3.2.tar.gz

# 配置Hadoop环境变量
RUN tar -xzvf hadoop-3.3.2.tar.gz \
    && mv hadoop-3.3.2 $HADOOP_HOME \
    && echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> ~/.bashrc \
    && echo 'export PATH=$PATH:$HADOOP_HOME/sbin' >> ~/.bashrc \
    && rm hadoop-3.3.2.tar.gz

# 下载Spark
RUN wget https://dlcdn.apache.org/spark/spark-3.1.2/spark-3.1.2-bin-without-hadoop.tgz

# 配置Spark环境变量
RUN tar -xvzf spark-3.1.2-bin-without-hadoop.tgz \
    && mv spark-3.1.2-bin-without-hadoop sbin/ \
    && echo 'export PATH=$PATH:/sbin/spark-3.1.2-bin-without-hadoop/sbin/' >> ~/.bashrc \
    && echo 'export PATH=/sbin/spark-3.1.2-bin-without-hadoop/bin/:$PATH' >> ~/.bashrc \
    && rm spark-3.1.2-bin-without-hadoop.tgz

RUN mv ${HADOOP_STREAMING_HOME}/hadoop-streaming-3.3.2.jar ${HADOOP_STREAMING_HOME}/hadoop-streaming.jar \
    && source ~/.bashrc

# 再安装一些必要的库
RUN apt-get update --fix-missing && apt-get install -y netcat software-properties-common build-essential cmake
RUN add-apt-repository universe

# 指定工作目录
WORKDIR /home/big_data

# 安装Python各种库（pySpark需要）
RUN apt-get update
RUN apt-get install -y python3-pip
COPY ./config/requirements.txt ./requirements.txt
RUN pip3 install -r ./requirements.txt

# 增添环境变量
ENV HDFS_NAMENODE_USER "root"
ENV HDFS_DATANODE_USER "root"
ENV HDFS_SECONDARYNAMENODE_USER "root"
ENV YARN_RESOURCEMANAGER_USER "root"
ENV YARN_NODEMANAGER_USER "root"
ENV PYSPARK_PYTHON "python3"

# Hadoop配置
WORKDIR /usr/local/hadoop/etc/hadoop
COPY ./config/core-site.xml .
COPY ./config/hdfs-site.xml .
COPY ./config/mapred-site.xml .
COPY ./config/yarn-site.xml .

# Spark配置
WORKDIR /sbin/spark-3.1.2-bin-without-hadoop/conf/
COPY ./config/spark-env.sh .
COPY ./config/spark-defaults.conf .
COPY ./config/log4j.properties .

# 拷贝安装脚本并开启ssh服务
WORKDIR /home/big_data
COPY ./config/spark-cmd.sh .
RUN chmod +x /home/big_data/spark-cmd.sh

CMD service ssh start && sleep infinity
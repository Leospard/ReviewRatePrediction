# ReviewRatePrediction
BigData Homework

`docker build . -t sparkbase`生成镜像文件

`bash toy-cluster.sh`运行spark集群

`docker ps -a`查看容器

然后进入master node内将已分词处理的评论数据传到hdfs中然后使用pyspark运行process.py即可。

> src文件夹中的crawler.py 为爬虫代码

> preprocess.py 为中文评论分词处理

> process.py 为pyspark分布式计算的程序
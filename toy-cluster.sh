#!/bin/bash                                                               
imageName="sparkbase:latest"

# 创建docker network
docker network create --driver bridge cluster_net

# 创建3个work节点
echo ">> Starting nodes master and worker nodes ..."
docker run -dP --network cluster_net --name master-node -h master-node -it $imageName
docker run -dP --network cluster_net --name worker-1 -it -h worker-1 $imageName
docker run -dP --network cluster_net --name worker-2 -it -h worker-2 $imageName
docker run -dP --network cluster_net --name worker-3 -it -h worker-3 $imageName

# 格式化hdfs
echo ">> Formatting hdfs ..."
docker exec -it master-node /usr/local/hadoop/bin/hdfs namenode -format

docker start master-node worker-1 worker-2 worker-3
sleep 5
echo ">> Starting Master and Workers ..."

# 在各个节点内运行启动spark的脚本
docker exec -d master-node /home/big_data/spark-cmd.sh start master-node
docker exec -d worker-1 /home/big_data/spark-cmd.sh start
docker exec -d worker-2 /home/big_data/spark-cmd.sh start
docker exec -d worker-3 /home/big_data/spark-cmd.sh start
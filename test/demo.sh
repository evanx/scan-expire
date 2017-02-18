
name='scan-expire'
appImage="evanxsummers/$name"
network="$name-network"
redisName="$name-redis"
appName="$name-instance"

removeContainers() {
    for name in $@
    do
      if docker ps -a -q -f "name=/$name" | grep '\w'
      then
        docker rm -f `docker ps -a -q -f "name=/$name"`
      fi
    done
}

removeNetwork() {
    if docker network ls -q -f name=^$network | grep '\w'
    then
      docker network rm $network
    fi
}

createRedis() {
  redisContainer=`docker run --network=$network \
      --name $redisName -d redis`
  redisHost=`docker inspect $redisContainer |
      grep '"IPAddress":' | tail -1 | sed 's/.*"\([0-9\.]*\)",/\1/'`
}

(
  removeContainers $redisName $appName
  removeNetwork
  set -u -e -x
  sleep 1
  docker network create -d bridge $network
  createRedis
  sleep 1
  redis-cli -h $redisHost set user:evanxsummers '{"twitter": "@evanxsummers"}'
  redis-cli -h $redisHost set user:other '{"twitter": ""@evanxsummers"}'
  redis-cli -h $redisHost set group:evanxsummers '["evanxsummers"]'
  redis-cli -h $redisHost keys '*'
  docker run --name $appName --rm -i \
    --network=$network \
    -e host=$redisHost \
    -e port=6379 \
    -e pattern='user:*' \
    -e ttl=1 \
    $appImage
  redis-cli -h $redisHost keys '*'
  docker rm -f $redisName $appName
  docker network rm $network
)

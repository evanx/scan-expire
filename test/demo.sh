
appName='scan-expire'
appImage='evanxsummers/scan-expire'
network='scan-expire-network'

removeContainers() {
    for name in $@
    do
      if docker ps -a -q -f "name=/$appName" | grep '\w'
      then
        docker rm -f `docker ps -a -q -f "name=/$appName"`
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
      --name $appName-redis -d redis`
  redisHost=`docker inspect $redisContainer |
      grep '"IPAddress":' | tail -1 | sed 's/.*"\([0-9\.]*\)",/\1/'`
}

(
  removeContainers scan-redis scan-app
  removeNetwork
  set -u -e -x
  sleep 1
  docker network create -d bridge $network
  createRedis
  redis-cli -h $redisHost -p 6379 set user:evanxsummers '{"twitter": "@evanxsummers"}'
  redis-cli -h $redisHost -p 6379 set user:other '{"twitter": ""@evanxsummers"}'
  redis-cli -h $redisHost -p 6379 set group:evanxsummers '["evanxsummers"]'
  redis-cli -h $redisHost -p 6379 keys '*'
  appContainer=`docker run --name $appName-app -d \
    --network=$network \
    -e host=$redisHost \
    -e port=6379 \
    -e pattern='user:*' \
    -e ttl=1 \
    $appImage`
  sleep 2
  redis-cli -h $redisHost -p 6379 keys '*'
  docker logs $appContainer
  docker rm -f scan-redis scan-app
  docker network rm scan-network
)

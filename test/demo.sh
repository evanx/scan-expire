
name='scan-expire'
network="$name-network"
redisName="$name-redis"

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

(
  removeContainers $redisName
  removeNetwork
  set -u -e -x
  sleep 1
  docker network create -d bridge scan-expire-network
  redisContainer=`docker run --network=scan-expire-network \
      --name $redisName -d redis`
  redisHost=`docker inspect $redisContainer |
      grep '"IPAddress":' | tail -1 | sed 's/.*"\([0-9\.]*\)",/\1/'`
  sleep 1
  redis-cli -h $redisHost set user:evanxsummers '{"twitter": "@evanxsummers"}'
  redis-cli -h $redisHost set user:other '{"twitter": "@evanxsummers"}'
  redis-cli -h $redisHost set group:evanxsummers '["evanxsummers"]'
  redis-cli -h $redisHost keys '*'
  docker build -t scan-expire https://github.com/evanx/scan-expire.git
  docker run --name scan-expire-instance --rm -i \
    --network=scan-expire-network \
    -e host=$redisHost \
    -e pattern='user:*' \
    -e ttl=1 \
    scan-expire
  sleep 2
  redis-cli -h $redisHost keys '*'
  docker rm -f $redisName
  docker network rm $network
)

(
  set -u -e -x
  mkdir -p tmp
  mkdir -p $HOME/volumes/reo/
  for name in reo-redis reo-app reo-decipher reo-encipher
  do
    if docker ps -a -q -f "name=/$name" | grep '\w'
    then
      docker rm -f `docker ps -a -q -f "name=/$name"`
    fi
  done
  sleep 1
  if docker network ls -q -f name=^reo-network | grep '\w'
  then
    docker network rm reo-network
  fi
  docker network create -d bridge reo-network
  redisContainer=`docker run --network=reo-network \
      --name reo-redis -d redis`
  redisHost=`docker inspect $redisContainer |
      grep '"IPAddress":' | tail -1 | sed 's/.*"\([0-9\.]*\)",/\1/'`
  dd if=/dev/urandom bs=32 count=1 > $HOME/volumes/reo/spiped-keyfile
  decipherContainer=`docker run --network=reo-network \
    --name reo-decipher -v $HOME/volumes/reo/spiped-keyfile:/spiped/key:ro \
    -d spiped \
    -d -s "[0.0.0.0]:6444" -t "[$redisHost]:6379"`
  decipherHost=`docker inspect $decipherContainer |
    grep '"IPAddress":' | tail -1 | sed 's/.*"\([0-9\.]*\)",/\1/'`
  encipherContainer=`docker run --network=reo-network \
    --name reo-encipher -v $HOME/volumes/reo/spiped-keyfile:/spiped/key:ro \
    -d spiped \
    -e -s "[0.0.0.0]:6333" -t "[$decipherHost]:6444"`
  encipherHost=`docker inspect $encipherContainer |
    grep '"IPAddress":' | tail -1 | sed 's/.*"\([0-9\.]*\)",/\1/'`
  redis-cli -h $encipherHost -p 6333 set user:evanxsummers '{"twitter":"evanxsummers"}'
  redis-cli -h $encipherHost -p 6333 lpush reo:key:q user:evanxsummers
  redis-cli -h $encipherHost -p 6333 llen reo:key:q
  appContainer=`docker run --name reo-app -d \
    --network=reo-network \
    -v $HOME/volumes/reo/data:/data \
    -e host=$encipherHost \
    -e port=6333 \
    evanxsummers/reo`
  sleep 2
  redis-cli -h $encipherHost -p 6333 llen reo:key:q
  docker logs $appContainer
  find ~/volumes/reo/data | grep '.gz$'
  zcat `find ~/volumes/reo/data | grep '.gz$' | tail -1`
  #docker rm -f reo-redis reo-app reo-decipher reo-encipher
  #docker network rm reo-network
)

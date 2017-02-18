
set -u -e

name=`cat package.json | grep '"name":'
  sed 's/.*"\([0-9].*\)",/\1/'`

user=`npm whoami`

echo "$user/$name"
sleep 2

set -x

cd development

  docker build -t name https://github.com/evanx/$name.git
  docker tag $name $user/$name
  docker push $user/$name


set -u -e

name=`cat package.json | jq '.name' | sed 's/"\(.*\)"/\1/'`

user=`npm whoami`

echo "$user/$name"

set -x

cd development

  docker build -t $name https://github.com/evanx/$name.git
  docker tag $name $user/$name
  docker push $user/$name

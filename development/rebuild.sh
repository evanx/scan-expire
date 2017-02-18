
set -u -e

name=`
  cat package.json |
  jq '.name' |
  sed 's/"\(.*\)"/\1/'`

user=`
  docker info 2>/dev/null |
  grep ^Username |
  sed 's/^Username: \(.*\)$/\1/'`

echo "$user/$name"

[ "$user/$name" = 'evanxsummers/scan-expire' ]

set -x

cd development

  docker build -t $name https://github.com/evanx/$name.git
  docker tag $name $user/$name
  docker push $user/$name

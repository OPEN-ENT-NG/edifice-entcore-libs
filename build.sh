#!/bin/bash

if [ ! -e node_modules ]
then
  mkdir node_modules
fi

# Set CI_OPTION to " -T " if running in CI environment
CI_OPTION=""
if [ ! -z "$CI" ] && [ "$CI" = "true" ]
then
  CI_OPTION=" -T "
fi

case `uname -s` in
  MINGW* | Darwin*)
    USER_UID=1000
    GROUP_UID=1000
    ;;
  *)
    if [ -z ${USER_UID:+x} ]
    then
      USER_UID=`id -u`
      GROUP_GID=`id -g`
    fi
esac

# If DEBUG env var is set to "true" then set -x to enable debug mode
if [ "$DEBUG" == "true" ]; then
	set -x
	EDIFICE_CLI_DEBUG_OPTION="--debug"
else
	EDIFICE_CLI_DEBUG_OPTION=""
fi

# build options
NO_DOCKER=""
SPRINGBOARD="recette"
MODULE=""
MVN_OPTS="-Duser.home=/var/maven -T 4"
for i in "$@"
do
case $i in
  --no-docker*)
    NO_DOCKER="true"
    MVN_OPTS=""
    shift
    ;;
  -s=*|--springboard=*)
    SPRINGBOARD="${i#*=}"
    shift
    ;;
  -m=*|--module=*)
    MODULE="${i#*=}"
    shift
    ;;
  *)
    ;;
esac
done

if [ "$MODULE" = "" ]; then
    GRADLE_OPTION=""
    NODE_OPTION=""
else
  GRADLE_OPTION=":$MODULE:"
  NODE_OPTION="--module $MODULE"
  if [ -e "$MODULE/backend" ]; then
    echo "BACKEND SUB-PROJECT $MODULE/backend DETECTED"
    MVN_OPTS="$MVN_OPTS --projects $MODULE/backend -am"
  else
    MVN_OPTS="$MVN_OPTS --projects $MODULE -am"
  fi
fi

#try jenkins branch name => then local git branch name => then jenkins params
echo "[buildNode] Get branch name from jenkins env..."
BRANCH_NAME=`echo $GIT_BRANCH | sed -e "s|origin/||g"`
if [ "$BRANCH_NAME" = "" ]; then
  echo "[buildNode] Get branch name from git..."
  BRANCH_NAME=`git branch | sed -n -e "s/^\* \(.*\)/\1/p"`
fi
if [ ! -z "$FRONT_TAG" ]; then
  echo "[buildNode] Get tag name from jenkins param... $FRONT_TAG"
  BRANCH_NAME="$FRONT_TAG"
fi
if [ "$BRANCH_NAME" = "" ]; then
  echo "[buildNode] Branch name should not be empty!"
  exit -1
fi

echo "======================"
echo "BRANCH_NAME = $BRANCH_NAME"
echo "======================"

init() {
  me=`id -u`:`id -g`
  echo "DEFAULT_DOCKER_USER=$me" > .env

    # If CLI_VERSION is empty set $cli_version to latest
  	if [ -z "$CLI_VERSION" ]; then
  		CLI_VERSION="latest"
  	fi
  	# Create a build.compose.yaml file from following template
  	cat <<EOF > build.compose.yaml
services:
  edifice-cli:
    image: opendigitaleducation/edifice-cli:$CLI_VERSION
    user: "$DEFAULT_DOCKER_USER"
EOF
  	# Copy /root/edifice from edifice-cli container to host machine
  	docker compose -f build.compose.yaml create edifice-cli
  	docker compose -f build.compose.yaml cp edifice-cli:/root/edifice ./edifice
  	docker compose -f build.compose.yaml rm -fsv edifice-cli
  	rm -f build.compose.yaml
  	chmod +x edifice
  	./edifice version $EDIFICE_CLI_DEBUG_OPTION
}

clean () {
  if [ "$NO_DOCKER" = "true" ] ; then
    mvn $MVN_OPTS clean
  else
    docker compose run --rm $USER_OPTION maven mvn $MVN_OPTS clean
  fi
}

install () {
  docker compose run $CI_OPTION --rm maven mvn $MVN_OPTS clean install -DskipTests
  buildBroker
}

buildBroker () {
  ./edifice install --all=false --clients=false --client-nest=true --client-node=true --client-vertx=true --back=false --project-type=entcore --client-python=false $EDIFICE_CLI_DEBUG_OPTION
}

test () {
  docker compose run $CI_OPTION --rm maven mvn $MVN_OPTS test
}

publish() {
  ./edifice publish --clients=true --dry-run=false --service=TRUE  --project-type=entcore $EDIFICE_CLI_DEBUG_OPTION
}

image() {
  ./edifice image --project-type=entcore $EDIFICE_CLI_DEBUG_OPTION
}

if [ ! -e .env ]; then
  init
fi

for param in "$@"
do
  case $param in
    '--no-user')
      ;;
    init)
      init
      ;;
    clean)
      clean
      ;;
    install)
      install
      ;;
    test)
      test
      ;;
    publish)
      publish
      ;;
    image)
      image
      ;;
    *)
      echo "Invalid argument : $param"
  esac
  if [ ! $? -eq 0 ]; then
    exit 1
  fi
done
#!/bin/bash

# I'd prefer to write this in python bc I'm more comfortable there, but one of
# these had to be in _not_ python/ruby/whatever and sh/bash is req'd... so here
# ya go. for linting, I found shellcheck.net and that seemed pretty cool. I'd
# likely spend some time there if this was a prod thing and more than one
# person were developing against this because arguments around "formatting
# should look like <>!" are best left to machines with lint rules.

OUTPUT_LOG=/home/"${USER}"/container_build_log;
DOCKER_HUB_ROOT="devops-blinkingboxes"

# give teams the power to name things;
# likely a horrible idea @scale- TARGETS https://docs.bazel.build/versions/main/guide.html
if [ "$1" = "" ] || [ $# -ne 2 ]; then
    echo "you must supply the name of the build;"
    echo "usage:"
    echo "  ${0} <build_name> [test]"
    echo ""
    echo "  required:"
    echo "    build_name: name of the build"
    echo "  optional:"
    echo "    test: run this container locally"
    echo "    publish: publish container to docker hub"
    echo ""
    exit 0
fi

# use hash of git-head for current build
build_hash=`git rev-parse HEAD`

build_name=$1;
docker build -t ${build_name} . >> "${OUTPUT_LOG}";

# we built, now we wanna spin it up locally to poke at it.
# Good call, and encouraged for this simple setup.
if [ "$2" = "test" ]; then
    # check and see if that build name is currently running locally
    # make it die if so
    docker ps | grep ${build_name};
    if [ $? -eq 0 ]; then
        docker stop ${build_name};
    fi
    # ...and now run it
    echo "Running ${build_name} locally for testing"
    docker run -it --rm -d -p 8080:80 --name ${build_name} ${build_name};
elif [ "$2" = "publish" ]; then
    echo "publishing..."
    # TODO(drewconner): add the variables from above here...
    # get moving for now and def come back to this
    # tag...
    deployment="devopsblinkingboxes/devops-test:latest"
    docker tag webserver ${deployment} >> "${OUTPUT_LOG}";
    # and then publish
    docker push ${deployment} >> "${OUTPUT_LOG}";
    printf "${deployment}\n"
fi
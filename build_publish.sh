#!/bin/bash

# I'd prefer to write this in python, but one of these had to be in _not_ python/ruby/whatever
# and sh/bash is req'd... so here ya go.
# for linting, I found shellcheck.net and that seemed pretty cool. I'd likely spend some time
# there if this was a prod thing and more than one person were developing against this
# because arguments around "formatting should look like <>!" are best left to machines with lint rules.

# give teams the power to name things
if [ "$1" = "" ] || [ "$1" = "test" ]; then
    echo "you must supply the name of the build;"
    echo "usage:"
    echo "  ${0} <build_name> [test]"
    echo ""
    echo "  required:"
    echo "    build_name: name of the build"
    echo "  optional:"
    echo "    test: run this container locally"
    echo ""
    exit 0
fi

build_name=$1;
echo "building ${build_name}"
docker build -t ${build_name} .;

# we built, now we wanna spin it up locally to poke at it.
# Good call, and encouraged for this simple setup.
if [ "$2" = "test" ]; then
    docker ps | grep ${build_name};
    # check and see if that build name is currently running locally
    # make it die if so
    if [ $? -eq 0 ]; then
        docker stop ${build_name};
    fi
    echo "Running ${build_name} locally for testing"
    docker run -it --rm -d -p 8080:80 --name ${build_name} ${build_name};
fi
#!/bin/bash

if [ -e /etc/redhat-release ]; then
    ./scripts/create-repo-rhel.sh || exit 1
elif [ -e /etc/openEuler-release ]; then
    ./scripts/create-repo-openEuler.sh || exit 1
elif [ -e /etc/kylin-release ]; then
    ./scripts/create-repo-kylin.sh || exit 1
else
    ./scripts/create-repo-ubuntu.sh || exit 1
fi

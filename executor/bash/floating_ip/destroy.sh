#!/usr/bin/env bash

###
# Executes on server node.
#
if [[ $1 == "server" ]]; then
    carburator log info \
        "Floating IP destroy can only be invoked from client nodes."
    exit 0
fi

###
# Executes on client node.
#
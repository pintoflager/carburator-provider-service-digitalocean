#!/usr/bin/env bash

###
# Executes on server node.
#
if [[ $1 == "server" ]]; then
    carburator log info \
        "Volume destroy can only be invoked from client nodes."
    exit 0
fi

###
# Executes on client node.
#

# local app="$1" volumes="$2" provisioner_sh;
# local volinst_dir="$PWD/$app/volume_instances"

# if [[ ! -d $volinst_dir || ! $(ls -A "$volinst_dir") ]]; then return; fi

# # Execute provisioner logic of the selected program.
# provisioner_sh=$(get-resource-provisioner "$app")
# "$provisioner_sh" provisioner-destroy-volumes "$app" "$volumes"


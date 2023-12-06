#!/usr/bin/env bash

###
# Executes on server node.
#
if [[ $1 == "server" ]]; then
    carburator log info \
        "Node destroy can only be invoked from client nodes."
    exit 0
fi

###
# Executes on client node.
#

# # Provisioner defined with a parent command flag
# provisioner="$PROVISIONER_NAME"
# provider="$SERVICE_PROVIDER_NAME"

# # ...Or take the first package provider has in it's packages list.
# # with service / dns provider we know packages are provisioners.
# if [[ -z $provisioner ]]; then
#     provisioner="$SERVICE_PROVIDER_PACKAGES_0_NAME"
# fi

# ###
# # Service provider has information about the nodes we have to pass along to the
# # provisioner.
# #
# provisioner_node="$PROJECT_PUBLIC/provisioners/$provisioner/providers/$provider/node"
# provider_node="$SERVICE_PROVIDER_PATH/node"

# # We could process the nodes array here to the format the provisioner is expecting
# # but better keep provider layer thin and let the provisioner do what it needs
# # with the original data
# copy_exec_envr() {
#     if [[ -e $1 ]]; then
#         carburator log debug \
#             "Copying $provider $1 to $provisioner as .provider$1..."
#         cp -f "$1" "$provisioner_node/.provider$1"
#     fi
# }

# copy_exec_envr .exec.env
# copy_exec_envr .exec.json
# copy_exec_envr .exec.yaml
# copy_exec_envr .exec.toml

# ###
# # Private networking
# #
# provisioner_net="$PROJECT_PUBLIC/provisioners/$provisioner/providers/$provider/network"

# # How many nodes are we dealing with
# len=$(carburator get json nodes array --path "$provider_node/.exec.json" | wc -l)

# # Digital Ocean has 3 network zones, europe and yankie east/west
# declare -a eu_nodes; declare -a us_east_nodes; declare -a us_west_nodes;

# for (( i=0; i<len; i++ )); do
#     name=$(carburator get json "nodes.$i.hostname" string \
#         --path "$provider_node/.exec.json")

#     location=$(carburator get json "nodes.$i.location.name" string \
#         --path "$provider_node/.exec.json")

#     if [[ $location == "ash" ]]; then us_east_nodes+=("$name")
#     elif [[ $location == "hil" ]]; then us_west_nodes+=("$name")
#     else eu_nodes+=("$name"); fi
# done

# net_name=$(carburator get env PROJECT_IDENTIFIER --path "$provider_node/.exec.env")
# range="10.10.0.0/24"

# # Each net zone should be called individually and only if they hold nodes.
# if [[ ${#eu_nodes[@]} -gt 0 ]]; then
#     carburator put json network "{\
#     name: \"$net_name-eu\",\
#     range: \"$range\",\
#     zone: eu-central,\
#     type: cloud}" --path "$provisioner_net/.eu.nodes.json"

#     IFS=\, eval 'node_csv="${eu_nodes[*]}"'
    
#     # shellcheck disable=SC2154
#     carburator put json nodes "[$node_csv]" \
#         --path "$provisioner_net/.eu.nodes.json"

# # Make sure files from previous iterations are not present.
# else
#     rm -f "$provisioner_net/.eu.nodes.json"
# fi

# if [[ ${#us_east_nodes[@]} -gt 0 ]]; then
#     carburator put json network "{\
#     name: \"$net_name-us\",\
#     range: \"$range\",\
#     zone: us-east,\
#     type: cloud}" --path "$provisioner_net/.us.east.nodes.json"

#     IFS=\, eval 'node_csv="${us_east_nodes[*]}"'
#     carburator put json nodes "[$node_csv]" \
#         --path "$provisioner_net/.us.east.nodes.json"
# else
#     rm -f "$provisioner_net/.us.east.nodes.json"
# fi

# if [[ ${#us_west_nodes[@]} -gt 0 ]]; then
#     carburator put json network "{\
#     name: \"$net_name-us\",\
#     range: \"$range\",\
#     zone: us-west,\
#     type: cloud}" --path "$provisioner_net/.us.west.nodes.json"

#     IFS=\, eval 'node_csv="${us_west_nodes[*]}"'
#     carburator put json nodes "[$node_csv]" \
#         --path "$provisioner_net/.us.west.nodes.json"
# else
#     rm -f "$provisioner_net/.us.west.nodes.json"
# fi

# # Invoke the provisioner
# carburator provisioner request \
#     service-provider \
#     destroy \
#     network \
#     --provider "$provider" \
#     --provisioner "$provisioner" || exit 120

# carburator provisioner request \
#     service-provider \
#     destroy \
#     node \
#     --provider "$provider" \
#     --provisioner "$provisioner" || exit 120

# carburator log success "Digital Ocean network(s) and node(s) destroyed."
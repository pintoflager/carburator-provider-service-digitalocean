#!/usr/bin/env bash

carburator print terminal info "Invoking Digital Ocean service provider..."

###
# Executes on server node.
#
if [[ $1 == "server" ]]; then
    carburator print terminal info \
        "Node create can only be invoked from client nodes."
    exit 0
fi

###
# Executes on client node.
#
# Provisioner defined with a parent command flag
# ...Or take the first package provider has in it's packages list.
provisioner="${PROVISIONER_NAME:-$SERVICE_PROVIDER_PACKAGES_0_NAME}"
provider="$SERVICE_PROVIDER_NAME"

nodes=$(carburator get json nodes array-raw -p .exec.json)


# TODO: D.O adds networks to nodes, not nodes to networks. Create networks first.
###
# Private networking
#
carburator print terminal info 'Creating private networks for Digital Ocean nodes...'

carburator provisioner request \
    service-provider \
        create \
        network \
            --provider "$provider" \
            --provisioner "$provisioner" \
            --json-kv "nodes=$nodes" || exit 120


###
# Service provider has information about the nodes we have to pass along to the
# provisioner.
#
carburator provisioner request \
    service-provider \
    create \
    node \
    --provider "$provider" \
    --provisioner "$provisioner" \
    --json-kv "nodes=$nodes"|| exit 120

# Nodes might not boot fast enough.
av_time=$(carburator fn time-offset 30 s) || exit 120

# Loop nodes one by one, using index number for array item access
len=$(carburator get json nodes array -p .exec.json | wc -l)

for (( i=0; i<len; i++ )); do
    # Only delay init for (supposedly) new nodes.
    init=$(carburator get json "nodes.$i.toggles.initialized" boolean \
        -p .exec.json)

    if [[ $init == false ]]; then
        # Say something.
        node=$(carburator get json "nodes.$i.hostname" string -p .exec.json)
        if [[ -n $node ]]; then
            carburator print terminal info "Setting initilization delay for $node"
        fi

        # Alter node toml to have the available time
        path=$(carburator node conf-path -n "$node") || exit 120

        # Add availability timestamp and flip the switch
        carburator put toml available "$av_time" -p "$path"
        carburator put toml toggles.initialized true -p "$path"
    fi
done

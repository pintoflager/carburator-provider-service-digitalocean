#!/usr/bin/env bash

carburator print terminal info "Invoking Digital Ocean service provider..."

###
# Executes on server node.
#
if [[ $1 == "server" ]]; then
    carburator print terminal info \
        "Floating IP create can only be invoked from client nodes."
    exit 0
fi

###
# Executes on client node.
#

# Provisioner defined with a parent command flag
# ...Or take the first package provider has in it's packages list.
provisioner="${PROVISIONER_NAME:-$SERVICE_PROVIDER_PACKAGES_0_NAME}"
provider="$SERVICE_PROVIDER_NAME"

###
# Service provider has information about the proxy nodes we have to pass along to the
# provisioner.
#
nodes=$(carburator get json nodes array-raw -p .exec.json)
tag=$(carburator get toml floating_ip_name string -p .exec.toml)
ipv4=$(carburator get toml floating_ip_v4 boolean -p .exec.toml)
ipv6=$(carburator get toml floating_ip_v4 boolean -p .exec.toml)

carburator provisioner request \
    service-provider \
    create \
    floating_ip \
        --provider "$provider" \
        --provisioner "$provisioner" \
        --key-val "ip_name=$tag" \
        --key-val "ip_v4=$ipv4" \
        --key-val "ip_v6=$ipv6" \
        --json-kv "nodes=$nodes"|| exit 120


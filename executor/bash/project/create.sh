#!/usr/bin/env bash

carburator log info "Invoking Digital Ocean service provider..."

###
# Executes on server node.
#
if [[ $1 == "server" ]]; then
    carburator log info \
        "Project create can only be invoked from client nodes."
    exit 0
fi

###
# Executes on client node.
#
# Provisioner defined with a parent command flag
# ...Or take the first package provider has in it's packages list.
provisioner="${PROVISIONER_NAME:-$SERVICE_PROVIDER_PACKAGES_0_NAME}"

# Digital Ocean recreates all nodes where root key changes. This will most likely
# destroy your complete environment so let's not do that and instead lock in
# our root key.
root_pubkey=$(carburator get env DIGITALOCEAN_ROOT_PUBLIC_SSKEY -s digitalocean -p digitalocean.env)

if [[ -z $root_pubkey ]]; then
    root_pubkey=$(carburator get env REGISTER_ROOT_PUBLIC_SSHKEY_0 \
        -p .exec.env) || exit 120

    carburator put env DIGITALOCEAN_ROOT_PUBLIC_SSKEY "$root_pubkey" \
        -s digitalocean \
        -p digitalocean.env || exit 120
fi

if [[ -z $root_pubkey ]]; then
    carburator log error \
        "Unable to find path to root public SSH key from .exec.env"
    exit 120
fi

###
# Run the provisioner and hope it succeeds. Provisioner function has
# retries baked in (if enabled in provisioner.toml).
#
carburator provisioner request \
    service-provider \
    create \
    project \
        --provider "$SERVICE_PROVIDER_NAME" \
        --provisioner "$provisioner" \
        --key-val "ROOT_SSH_PUBKEY=$root_pubkey" || exit 120

carburator log success "Digital Ocean project created."

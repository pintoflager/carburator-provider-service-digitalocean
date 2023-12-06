#!/usr/bin/env bash

###
# Register on server node.
#
if [[ $1 == "server" ]]; then
    carburator log info \
        "Digital Ocean service provider executes register only on client nodes"
    exit 0
fi

###
# Register on client node.
#
# User holding the secret, provider package user or root.
user="${PACKAGE_USER_PUBLIC_IDENTIFIER:-root}"

# We know we have secrets but this is a good practice anyways.
if carburator has json service_provider.secrets -p .exec.json; then

    # Read secrets from json exec environment line by line
    while read -r secret; do
        # Prompt secret if it doesn't exist yet.
        if ! carburator has secret "$secret" --user "$user"; then
            # ATTENTION: We know only one secret is present. Otherwise
            # prompt texts should be adjusted accordingly.
            carburator log warn \
                "Could not find secret containing Digital Ocean cloud API token."
            
            carburator prompt secret "Digital Ocean cloud API key" \
                --name "$secret" \
                --user "$user" || exit 120
        fi
    done < <(carburator get json service_provider.secrets array -p .exec.json)
fi

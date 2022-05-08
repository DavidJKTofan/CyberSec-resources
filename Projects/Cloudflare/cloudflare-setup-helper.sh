#!/bin/sh
# Title: Cloudflare Setup Helper
# Reference https://api.cloudflare.com/

#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}
#{{{ Variables
read -ronly script_name=$(basename "${0}")
read -ronly script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IFS=$'\t\n' # Split on newlines and tabs (but not on spaces)
#}}}

###########################################################

echo "Welcome to the Cloudflare Setup Helper!"
sleep 2

###########################################################
######################## FUNCTIONS ########################
###########################################################

# Email Validator Regex
# Reference https://gist.github.com/guessi/82a73ee7eb2b1216eb9db17bb8d65dd1
regex="^(([A-Za-z0-9]+((\.|\-|\_|\+)?[A-Za-z0-9]?)*[A-Za-z0-9]+)|[A-Za-z0-9]+)@(([A-Za-z0-9]+)+((\.|\-|\_)?([A-Za-z0-9]+)+)*)+\.([A-Za-z]{2,})+$"
function validator {
  if [[ $1 =~ ${regex} ]]; then
    printf "* %-48s \e[1;32m[pass]\e[m\n" "${1}"
  else
    printf "* %-48s \e[1;31m[fail]\e[m\n" "${1}"
    printf "Try again!"
    exit 1
  fi
}

get_cloudflare_parameters() {

    # Cloudflare email
    printf "What is your Cloudflare login email?\n"
    read -r user_email
    validator "${user_email}"

    # Cloudflare Global API Key
    printf "What is your Cloudflare API Auth Key?\n"
    printf "We will need this...\n"
    read -r x_auth_key

    # Wait for user
    read -r -n 1 -s -r -p "Press any key to continue...\n"
}

cloudflare_get_zoneid() {

    # Get the Zone IDs
    curl -X GET "https://api.cloudflare.com/client/v4/zones" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" > zoneids_tmp.json

    # Iterate over Zone IDs
    count=`jq '.result | keys | length' zoneids_tmp.json`
    for ((i=0; i<${count}; i++))
    do
        name=`jq -r '.result['$i'].name' zoneids_tmp.json`
        zoneid=`jq -r '.result['$i'].id' zoneids_tmp.json`
        echo "$name = $zoneid"
    done

    # Remove zoneids_tmp.json file
    #rm zoneids_tmp.json

    # Wait for user
    read -r -n 1 -s -r -p "Press any key to continue...\n"
}

cloudflare_improve_settings() {

    # Check for user_email and x_auth_key
    if [[ -z "$user_email" ]] && [[ -z "$x_auth_key" ]]; then
        echo "Must provide user_email and x_auth_key\n" 1>&2
        get_cloudflare_parameters
    fi

    # Get the Zone IDs
    cloudflare_get_zoneid

    # Get Zone ID / hostname
    printf "\nCopy-paste the Zone ID you want to check and improve the settings for here:\n"
    read -r zone_id

    # Get Always Use HTTPS Settings
    alwayshttps_value=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/always_use_https" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" | jq '.result')

    if [[ "${alwayshttps_value}" == *"on"* ]]; then
        printf "Always Use HTTPS is already activated.\n"
    elif [[ "${alwayshttps_value}" == *"off"* ]]; then
        printf "Always Use HTTPS is not activated...\n"
        printf "Activating now...\n"
        sleep 2
        # Turn on Always Use HTTPS
        curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/always_use_https" \
            -H "X-Auth-Email: ${user_email}" \
            -H "X-Auth-Key: ${x_auth_key}" \
            -H "Content-Type: application/json" \
            --data '{"value":"on"}'
        printf "Always Use HTTPS activated!\n"
    else
        printf "\nSomething went wrong.\n"
        exit 1
    fi

    # Get Brotli setting
    brotli_value=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/brotli" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" | jq '.result.value')

    if [[ "${brotli_value}" == *"on"* ]]; then
        printf "Brotli is already activated.\n"
    elif [[ "${brotli_value}" == *"off"* ]]; then
        printf "Brotli is not activated...\n"
        printf "Activating now...\n"
        sleep 2
        # Turn on Brotli
        curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/brotli" \
            -H "X-Auth-Email: ${user_email}" \
            -H "X-Auth-Key: ${x_auth_key}" \
            -H "Content-Type: application/json" \
            --data '{"value":"on"}'
        printf "Brotli activated!\n"
    else
        printf "\nSomething went wrong.\n"
        exit 1
    fi

    # Get HTTP2 setting
    http2_value=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/http2" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" | jq '.result.value')

    if [[ "${http2_value}" == *"on"* ]]; then
        printf "HTTP2 is already activated.\n"
    elif [[ "${http2_value}" == *"off"* ]]; then
        printf "HTTP2 is not activated...\n"
        printf "Activating now...\n"
        sleep 2
        # Turn on HTTP2
        curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/http2" \
            -H "X-Auth-Email: ${user_email}" \
            -H "X-Auth-Key: ${x_auth_key}" \
            -H "Content-Type: application/json" \
            --data '{"value":"on"}'
        printf "HTTP2 activated!\n"
    else
        printf "\nSomething went wrong.\n"
        exit 1
    fi

    # Get HTTP/2 Edge Prioritization Settings
    http2prio_value=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/h2_prioritization" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" | jq '.result.value')

    if [[ "${http2prio_value}" == *"on"* ]]; then
        printf "HTTP/2 Edge Prioritization is already activated.\n"
    elif [[ "${http2prio_value}" == *"off"* ]]; then
        printf "HTTP/2 Edge Prioritization is not activated...\n"
        printf "Activating now...\n"
        sleep 2
        # Turn on HTTP/2 Edge Prioritization
        curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/h2_prioritization" \
            -H "X-Auth-Email: ${user_email}" \
            -H "X-Auth-Key: ${x_auth_key}" \
            -H "Content-Type: application/json" \
            --data '{"value":"on"}'
        printf "HTTP/2 Edge Prioritization activated!\n"
    else
        printf "\nSomething went wrong.\n"
        exit 1
    fi

    # Get HTTP3 setting
    http3_value=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/http3" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" | jq '.result.value')

    if [[ "${http3_value}" == *"on"* ]]; then
        printf "HTTP3 is already activated.\n"
    elif [[ "${http3_value}" == *"off"* ]]; then
        printf "HTTP3 is not activated...\n"
        printf "Activating now...\n"
        sleep 2
        # Turn on HTTP3
        curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/http3" \
            -H "X-Auth-Email: ${user_email}" \
            -H "X-Auth-Key: ${x_auth_key}" \
            -H "Content-Type: application/json" \
            --data '{"value":"on"}'
        printf "HTTP3 activated!\n"
    else
        printf "\nSomething went wrong.\n"
        exit 1
    fi

    # Get IPv6 Settings
    ipv6_value=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/ipv6" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" | jq '.result.value')

    if [[ "${ipv6_value}" == *"on"* ]]; then
        printf "IPv6 is already activated.\n"
    elif [[ "${ipv6_value}" == *"off"* ]]; then
        printf "IPv6 is not activated...\n"
        printf "Activating now...\n"
        sleep 2
        # Turn on IPv6
        curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/ipv6" \
            -H "X-Auth-Email: ${user_email}" \
            -H "X-Auth-Key: ${x_auth_key}" \
            -H "Content-Type: application/json" \
            --data '{"value":"on"}'
        printf "IPv6 activated!\n"
    else
        printf "\nSomething went wrong.\n"
        exit 1
    fi

    # Get Minify Settings
    # Just check JS, should be enough
    minify_values=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/minify" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" | jq '.result.value.js')
    
    if [[ "${minify_values}" == *"on"* ]]; then
        printf "Minify is already activated.\n"
    elif [[ "${ipv6_value}" == *"off"* ]]; then
        printf "IPv6 is not activated...\n"
        printf "Activating now...\n"
        sleep 2
        # Turn on Minify
        curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/minify" \
            -H "X-Auth-Email: ${user_email}" \
            -H "X-Auth-Key: ${x_auth_key}" \
            -H "Content-Type: application/json" \
            --data '{"value":{"css":"on","html":"on","js":"on"}}'
        printf "Minify activated!\n"
    else
        printf "\nSomething went wrong.\n"
        exit 1
    fi

    # Get Early Hints Settings
    earlyhints_value=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/early_hints" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" | jq '.result.value')

    if [[ "${earlyhints_value}" == *"on"* ]]; then
        printf "Early Hints is already activated.\n"
    elif [[ "${earlyhints_value}" == *"off"* ]]; then
        printf "Early Hints is not activated...\n"
        printf "Activating now...\n"
        sleep 2
        # Turn on Early Hints
        curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/early_hints" \
            -H "X-Auth-Email: ${user_email}" \
            -H "X-Auth-Key: ${x_auth_key}" \
            -H "Content-Type: application/json" \
            --data '{"value":"on"}'
        printf "Early Hints activated!\n"
    else
        printf "\nSomething went wrong.\n"
        exit 1
    fi

    # Get TLS 1.3 Settings
    tls_value=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/tls_1_3" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" | jq '.result')

    if [[ "${tls_value}" == *"on"* ]]; then
        printf "TLS 1.3 is already activated.\n"
    elif [[ "${tls_value}" == *"off"* ]]; then
        printf "TLS 1.3 is not activated...\n"
        printf "Activating now...\n"
        sleep 2
        # Turn on TLS 1.3
        curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/tls_1_3" \
            -H "X-Auth-Email: ${user_email}" \
            -H "X-Auth-Key: ${x_auth_key}" \
            -H "Content-Type: application/json" \
            --data '{"value":"on"}'
        printf "TLS 1.3 activated!\n"
    else
        printf "\nSomething went wrong.\n"
        exit 1
    fi

    # Get DNSSEC Settings
    tls_value=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/dnssec" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" | jq '.result.status')

    if [[ "${tls_value}" == *"active"* ]]; then
        printf "DNSSEC is already activated.\n"
    elif [[ "${tls_value}" == *"disabled"* ]]; then
        printf "DNSSEC is not activated...\n"
        printf "Activating now...\n"
        sleep 2
        # Turn on DNSSEC
        curl -X PATCH "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/dnssec" \
            -H "X-Auth-Email: ${user_email}" \
            -H "X-Auth-Key: ${x_auth_key}" \
            -H "Content-Type: application/json" \
            --data '{"status":"active"}'
        printf "DNSSEC activated!\n"
    else
        printf "\nSomething went wrong.\n"
        exit 1
    fi

    # Wait for user
    read -r -n 1 -s -r -p "Press any key to continue...\n"
}

cleanup() {
    # Remove zoneids_tmp.json file
    rm --force zoneids_tmp.json
    # Delete X-Auth-Key variable
    unset x_auth_key
    printf "\nDone! Good job!\n"
}

###########################################################
####################### GET STARTED #######################
###########################################################

get_cloudflare_parameters
cloudflare_get_zoneid
cloudflare_improve_settings
trap cleanup EXIT
exit 0
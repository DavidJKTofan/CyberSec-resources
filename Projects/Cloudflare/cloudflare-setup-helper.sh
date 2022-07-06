#!/bin/bash
# Title: Cloudflare Setup Helper
# API Reference https://api.cloudflare.com/

#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}
#{{{ Variables
#read -ronly script_name="$(basename "${0}")"
#read -ronly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)
#}}}

###########################################################

printf "Welcome to Cloudflare Setup Helper!\n"
sleep 2
printf "What is your name?\n"
read -r name
printf "Hello %s! Please give me a second, or two...\n" "${name}"
sleep 2
# Ask for sudo privileges
# if [ "$UID" != 0 ]; then
#     sudo "$0" "$@"
#     exit $?
# fi

###########################################################
######################## FUNCTIONS ########################
###########################################################

# Set up your Cloudflare Tunnel for your server (if you haven't done so yet)
# Reference https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/
# We recommend that you do that via the Zero Trust Dashboard :)

# Email Validator Regex
# Reference https://gist.github.com/guessi/82a73ee7eb2b1216eb9db17bb8d65dd1
regex="^(([A-Za-z0-9]+((\.|\-|\_|\+)?[A-Za-z0-9]?)*[A-Za-z0-9]+)|[A-Za-z0-9]+)@(([A-Za-z0-9]+)+((\.|\-|\_)?([A-Za-z0-9]+)+)*)+\.([A-Za-z]{2,})+$"
validator() {
    if [[ $1 =~ ${regex} ]]; then
        printf "* %-48s \e[1;32m[pass]\e[m\n" "${1}"
        email_approved="success"
    else
        printf "* %-48s \e[1;31m[fail]\e[m\n" "${1}"
        printf "Something went wrong!\n\n"
        #exit 1
    fi
}

get_cloudflare_parameters() {
    # Get user_email and x_auth_key variables
    # Cloudflare email
    while true
    do
        printf "What is your Cloudflare login email?\n"
        read -r user_email
        validator "${user_email}"
        if [[ -n email_approved ]]; then
            break
        fi
    done

    printf "\nWhat is your Cloudflare API Auth Key?\n"
    read -r x_auth_key

    # Wait for user
    read -r -n 1 -s -r -p "\nPress any key to continue...\n"
}

cloudflare_get_zoneid() {
    # Get all Cloudflare zones on your account
    # Set temporary filename
    zone_filename="zoneids_tmp.json"

    # Get the Zone IDs
    curl -X GET "https://api.cloudflare.com/client/v4/zones" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" > $zone_filename

    # Iterate over Zone IDs
    #count=`jq '.result | keys | length' $zone_filename`
    count=$(jq '.result | keys | length' $zone_filename)
    for ((i=0; i<${count}; i++))
    do
        #name=`jq -r '.result['$i'].name' $zone_filename`
        name=$(jq -r '.result['$i'].name' $zone_filename)
        #zoneid=`jq -r '.result['$i'].id' $zone_filename`
        zoneid=$(jq -r '.result['$i'].id' $zone_filename)
        printf "\n%s = %s\n" "$name" "$zoneid"
    done

    # Wait for user
    read -r -n 1 -s -r -p "Press any key to continue...\n"
}

cloudflare_improve_performance_settings() {
    # Optimize site speed and improve SEO
    # Reference: https://developers.cloudflare.com/fundamentals/get-started/task-guides/optimize-site-speed/ 

    # Check for user_email and x_auth_key
    if [[ -z "${user_email}" ]] && [[ -z "${x_auth_key}" ]]; then
        printf "Must provide user_email and x_auth_key\n"
        get_cloudflare_parameters
    fi

    printf "=%.0s"  $(seq 1 63)
    printf "\n"

    # Get the Zone IDs
    cloudflare_get_zoneid

    # Get Zone ID / hostname
    printf "\nCopy-paste the Zone ID you want to check and improve the settings for here:\n"
    read -r zone_id

    # Check if jq is installed
    REQUIRED_PKG="jq"
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
    printf "Checking for %s: %s...\n" "$REQUIRED_PKG" "$PKG_OK"
    # Install if not installed
    if [ "" = "$PKG_OK" ]; then
        printf "No %s. Setting up %s.\n" "${REQUIRED_PKG}" "${REQUIRED_PKG}"
        sudo apt-get install $REQUIRED_PKG -y
        printf "=%.0s"  $(seq 1 63)
        printf "\n"
    fi

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
        exit $?
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
        exit $?
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
        exit $?
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
        exit $?
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
        exit $?
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
        exit $?
    fi

    # Get Minify Settings
    # Just check JS, should be enough
    minify_values=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/minify" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" | jq '.result.value.js')
    
    if [[ "${minify_values}" == *"on"* ]]; then
        printf "Minify is already activated.\n"
    elif [[ "${minify_values}" == *"off"* ]]; then
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
        exit $?
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
        exit $?
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
        exit $?
    fi

    # Get DNSSEC Settings
    dnssec_value=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/settings/dnssec" \
        -H "X-Auth-Email: ${user_email}" \
        -H "X-Auth-Key: ${x_auth_key}" \
        -H "Content-Type: application/json" | jq '.result.status')

    if [[ "${dnssec_value}" == *"active"* ]]; then
        printf "DNSSEC is already activated.\n"
    elif [[ "${dnssec_value}" == *"disabled"* ]]; then
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
        exit $?
    fi

    # Wait for user
    read -r -n 1 -s -r -p "Press any key to continue...\n"
}

cloudflare_improve_security_settings() {
    # Protect website against malicious traffic and bad actors
    # Reference: https://developers.cloudflare.com/fundamentals/get-started/task-guides/secure-your-website/ 

    # Wait for user
    read -r -n 1 -s -r -p "Press any key to continue...\n"
}

get_paramteres() {

  printf "What is your Cloudflare login email?\n"
  read -r user_email
  validator "${user_email}"

  printf "What is your Cloudflare API Auth Key?\n"
  printf "We will need this for some operations...\n"
  read -r x_auth_key

  printf "What is the zone / hostname that you want to setup?\n"
  printf "i.e. 'cloudflare.com'\n"
  read -r zone_hostname
  printf "Ok, your zone is:  %s\n" "${zone_hostname}"

  printf "What should your SSH hostname be like?"
  printf "i.e. 'ssh.cloudflare.com'\n"
  read -r hostname 
  printf "Ok, your SSH hostname:  %s\n" "${hostname}"

  printf "What's the email address you will be using via Cloudflare Access to login via SSH?\n"
  read -r ssh_username
  printf "Ok, your SSH username:  %s\n" "${ssh_username}"

  printf "=%.0s"  $(seq 1 63)
  sleep 2

  # Wait for user
  read -r -n 1 -s -r -p "Press any key to continue with the Cloudflare account setup...\n"
}

os_level_firewall() {
    # Check OS-level firewall
    # Reference: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/do-more-with-tunnels/secure-server/ 
    
    # Allow localhost to communicate with itself
    sudo iptables -A INPUT -i lo -j ACCEPT

    # Allow already established connection and related traffic
    sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    # Allow new SSH connections
    sudo iptables -A INPUT -p tcp --dport ssh -j ACCEPT

    # Drop all other ingress traffic (careful here!)
    read -p "\nDo you want to drop all other ingress traffic? " -n 1 -r
    printf    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        sudo iptables -A INPUT -j DROP
    fi

    # Check the current iptables settings
    sudo iptables -L
    sleep 2

    # Wait for user
    read -r -n 1 -s -r -p "\nPress any key to continue\n"
}

update_ufw() {
    # Set up UFW rules
    # Reference https://www.digitalocean.com/community/tutorials/how-to-setup-a-firewall-with-ufw-on-an-ubuntu-and-debian-cloud-server 

    # Check if UFW is installed
    REQUIRED_PKG="ufw"
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
    printf "Checking for %s: %s...\n" "$REQUIRED_PKG" "$PKG_OK"
    # Install if not installed
    if [ "" = "$PKG_OK" ]; then
        printf "No %s. Setting up %s.\n" "${REQUIRED_PKG}" "${REQUIRED_PKG}"
        sudo apt-get install $REQUIRED_PKG -y
        printf "=%.0s"  $(seq 1 63)
        printf "\n"
    fi

    # Stop UFW if it already is enabled
    sudo ufw --force disable
    #sudo ufw --force reset

    # Deny incoming traffic
    sudo ufw default deny incoming

    # Allow outgoing traffic
    sudo ufw default allow outgoing

    # Allow standard SSH
    sudo ufw allow ssh
    sudo ufw allow 22/tcp
    sudo ufw allow OpenSSH

    # Allow HTTP and HTTPS
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow www
    sudo ufw allow "Nginx Full"

    # Download latest Cloudflare IPs
    curl -s https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips
    curl -s https://www.cloudflare.com/ips-v6 >> /tmp/cf_ips

    # Allow all traffic from Cloudflare IPs (no ports restriction)
    #for cfip in `cat /tmp/cf_ips`; do ufw allow proto tcp from $cfip comment 'Cloudflare IP'; done
    for cfip in $(cat /tmp/cf_ips); do ufw allow proto tcp from "$cfip" comment 'Cloudflare IP'; done
    printf "\n"

    # Reload UFW
    ufw reload > /dev/null
    sleep 2

    # Start UFW
    sudo ufw enable

    # Reload
    #sudo ufw reload

    # Check UFW status
    sudo ufw status numbered

    # Add any other rules
    printf "\nAdd any other rules you might need or want.\n"
    sleep 2

    # Wait for user
    read -r -n 1 -s -r -p "Press any key to continue\n"
}

cleanup() {
    # Remove zoneids_tmp.json file
    if [ -f $zone_filename ]; then
        printf "Remove the temporary file %s?" "${zone_filename}"
        rm -if $zone_filename
        printf "%s is removed.\n" "${zone_filename}"
    fi
    # Delete X-Auth-Key variable
    unset x_auth_key
    # Delete User Email variable
    unset user_email
    printf "\nDone! Good job!\n"
    sleep 2
}

###########################################################
####################### GET STARTED #######################
###########################################################

# Set up your Cloudflare account (!)
printf "Do you have a Cloudflare account? [Y,n]\n"
read -r input
if [[ $input == "Y" || $input == "y" ]]; then
        printf "Perfect! Let's continue...\n\n"
else
        printf "Well, create one now! And come back later...\n"
        printf "https://dash.cloudflare.com/sign-up"
        printf "\n"
        exit 1
fi

PS3="Please select your choice: "
options=("Secure Server" "Setup Cloudflare Zone" "Improve Cloudflare Zone" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Secure Server")
            # SERVER SECURITY
            printf "you chose choice %s which is %s" "$REPLY" "$opt"
            printf "\nLet's start with your OS-Level Firewall.\n"
            sleep 2
            os_level_firewall
            sleep 2
            printf "\nLet's continue with the Uncomplicated Firewall (ufw).\n"
            update_ufw
            sleep 2
            printf "\nYour server should have basic security now :)\n"
            printf "Just in case, review your firewall settings and rules later.\n"
            ;;
        "Setup Cloudflare Zone")
            # GENERAL ZONE SETUP (WORK IN PROGRESS)
            printf "you chose choice %s which is %s" "$REPLY" "$opt"
            ;;
        "Improve Cloudflare Zone")
            # PERFORMANCE AND SECURITY SETTINGS UPDATES
            printf "you chose choice %s which is %s" "$REPLY" "$opt"
            printf "\nLet's check your zone PERFORMANCE settings and see what we can improve...\n"
            sleep 3
            cloudflare_improve_performance_settings
            printf "\nLet's check your zone SECURITY settings and see what we can improve...\n"
            sleep 3
            cloudflare_improve_security_settings
            sleep 2
            printf "\nYour Cloudflare zone has now improved settings turned on :)\n"
            printf "Review your zones on the Dashboard later.\n"
            ;;
        "Quit")
            # END PROGRAM
            cleanup
            break
            exit 0
            ;;
        *) printf "invalid option %s \n" "$REPLY";;
    esac
done

###########################################################
######################### CLEANUP #########################
###########################################################

trap cleanup EXIT
exit 0
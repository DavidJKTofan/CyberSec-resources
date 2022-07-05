#!/bin/sh
# TITLE: Cloudflare Quick Commands
# DESCRIPTION: Quickly create a zsh shell profile on your macOS with useful cURL commands for the Cloudflare API.

# CHECK CURRENT OS
if [[ $OSTYPE == 'darwin'* ]]; then
    echo "You are using macOS. Let's continue...\n"
    sleep 2
else
    echo "\nYou are not using macOS. Cannot continue, sorry.\n"
    exit 1
fi


# CHECK CURRENT SHELL
#CURRENT_SHELL=$(echo $0)
CURRENT_SHELL="echo $0"
if [[ "$CURRENT_SHELL" == *"zsh"* ]]; then
    #echo "You are using ${CURRENT_SHELL}.\n"
    SHELL_PROFILE=".zshrc"
    ## Reference: https://unix.stackexchange.com/a/487889
    sleep 2
else
    echo "\nYou are not using zsh... Or something else went wrong.\n"
    ## Switch from bash to zsh
    #chsh -s $(which zsh)
    exit 1
fi


# CREATE VARIABLES
## Cloudflare User Email
echo "\nCloudflare User Email: " && read CLOUDFLARE_EMAIL
echo "export CLOUDFLARE_EMAIL=${CLOUDFLARE_EMAIL}" >> ${SHELL_PROFILE}
## Cloudflare Global API Key
echo "\nCloudflare Global API Key: " && read READ_CLOUDFLARE_API
security add-generic-password -a ${USER} -s api.cloudflare.com -w ${READ_CLOUDFLARE_API}
unset READ_CLOUDFLARE_API   # delete variable
echo "export CLOUDFLARE_API=\$(security find-generic-password -a ${USER} -s api.cloudflare.com -w)" >> ${SHELL_PROFILE}
## Reference: https://www.netmeister.org/blog/keychain-passwords.html


## RELOAD SHELL / execute the content
source ~/${SHELL_PROFILE}


# CLOUDFLARE COMMAND ALIASES
## Cloudflare API References: https://api.cloudflare.com/
## Conditions
if [ -n "$CLOUDFLARE_EMAIL" ] && [ -n "$CLOUDFLARE_API" ]; then

    ## downgrade_zone command to FREE Plan
    echo 'downgrade_zone(){echo -n "Zone to DOWNGRADE: " && read CLOUDFLARE_ZONE && curl -vX PATCH "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE}" --header "X-Auth-Email: ${CLOUDFLARE_EMAIL}" --header "X-Auth-Key: ${CLOUDFLARE_API}" --header "Content-Type: application/json" --data-raw '\''{"plan": {"id": "0feeeeeeeeeeeeeeeeeeeeeeeeeeeeee"}}'\''}' >> ${SHELL_PROFILE}
    ## Reference 1: https://support.cloudflare.com/hc/en-us/articles/360000841472-Adding-Multiple-Sites-to-Cloudflare-via-Automation
    ## Reference 2: https://community.cloudflare.com/t/curl-add-new-zone-how-to-indicate-plan-in-data-field/383119/2

    ## delete_zone command to delete Zone
    echo 'delete_zone(){echo -n "Zone to DELETE: " && read CLOUDFLARE_ZONE && curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE}" --header "X-Auth-Email: ${CLOUDFLARE_EMAIL}" --header "X-Auth-Key: ${CLOUDFLARE_API}"}' >> ${SHELL_PROFILE}

    ## RELOAD SHELL / execute the content
    source ~/${SHELL_PROFILE}
    echo "\nSuccess! \n"
    exit 0

else
    echo "\nSomething went wrong! \n\n"
    exit 1
fi

exit 1
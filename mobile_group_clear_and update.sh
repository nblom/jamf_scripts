#!/bin/bash
########################################### ABOUT ##############################################
#
# Name: mobile_group_clear_and update.sh
# Date: Sept 2020
# By: Steven Russell
#
########################################## VARIABLES ############################################
### Update the values here 

### API Info
api_user="api_user_here"
api_pass="api_pass_here"

## JAMF URL
jss_url="https://jss.domain:8443"

## Static or Smart Group ID here
# Insert the groupID here, found easily in the URL of the mobile device smart group
# For example: https://jss.domain:8443/smartMobileDeviceGroups.html?id=1234&o=r
#___________________________________________________Smart_Group_Here___^^^^____

group_id="0000" 


############################################# MAIN ##############################################
# Do not edit below the line
IFS=' '
# We are going to grab the mobile device IDs first from the smart or static group and place them
# into an array to loop through.

/bin/echo "Gather iPad device IDs from group: $group_ids"
members_of_group=$(/usr/bin/curl -sku "${api_user}:${api_pass}" ${jss_url}/JSSResource/mobiledevicegroups/id/${group_id} | xpath //mobile_devices/mobile_device/id | tr '</id>' '\n')
array_id=$(/bin/echo $members_of_group | awk '$1=$1' | tr '\n' ' ')

#count items in array
array_calc=$(echo ${array_id} | wc -w)
array_size=$(echo $array_calc | sed -e 's,\\[trn],,g')
count=1

# Start the for loop to apply command to each mobile device id
for mobile_id in $array_id; do
    #### Going to output some sort of progress to the screen...
    /bin/echo "iPad number: $count of $array_size"
    ((count=count+1))
    
    #### CANCEL ALL PENDING AND FAILED COMMANDS:
    /usr/bin/curl -sku "${api_user}:${api_pass}" ${jss_url}/JSSResource/commandflush/mobiledevices/id/"${mobile_id}"/status/Pending+Failed -X DELETE > /dev/null
    if [ $? = 0 ]; then
        /bin/echo "iPad ID: ${mobile_id} successfully cleared commands"
    else
        /bin/echo "iPad ID: ${mobile_id} failed to clear commands"
    fi

    #### UPDATE INVENTORY COMMANDS:
    /usr/bin/curl -sku "${api_user}:${api_pass}" ${jss_url}/JSSResource/mobiledevicecommands/command/UpdateInventory/id/"${mobile_id}" -X POST > /dev/null
        if [ $? = 0 ]; then
        /bin/echo "iPad ID: ${mobile_id} successfully updated inventory"
        /bin/echo "=========================="
    else
        /bin/echo "iPad ID: ${mobile_id} failed to update inventory"
    fi
    sleep 1
done

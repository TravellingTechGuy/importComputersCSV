#!/bin/bash

############################################################################################################################
# This script will create unmanaged records based on a CSV file with 1st column serial number and 2nd column assettag.
# Optional: add computers to a Static group
# Optional: create the computer group
#
# Based on original repo below.
#
# Original source code:
# https://github.com/JAMFSupport/API_Scripts/blob/master/createUserFromCSV.sh
# Copyright (c) 2014, JAMF Software, LLC.  All rights reserved.
#		THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# HISTORY
#
#   -Created by Sam Fortuna, JAMF Software, LLC, on June 18th, 2014
#   -Updated by Sam Fortuna, JAMF Software, LLC, on August 5th, 2014
#        - Improved error handling
#        - Returns a list of failed submissions
#   -Updated by Bram Cohen, JAMF Software, LLC, on September 10th, 2014
#        - Added ID check of ID #'s to start the posting 
#   -Edited by Pat Best, on January 27th, 2015
#        - to change it from user creation to computer creation
#        - removed the ID check portion
############################################################################################################################
#   -Edited by Frederick Abeloos | Field Technician | Jamf | March 10th, 2018
#		 - re-purposed for only importing computer records with name and serialnumber
#		 - added option to prompt (w/ masked password) Jamf API user credentials, instead of hardcoding it in the script
#		 - added option to prompt settings, instead of hardcoding it in the script
#		 - added creation for static group for inventory purposes and testing scenarios after importing the computers
#		 - added compatibility for groups containing white spaces in groupname
#
#
# Github Repository: https://github.com/TravellingTechGuy
############################################################################################################################
# INSTRUCTIONS
#
# - Create a CSV file or export it from a 3rd party Asset Manager
# - Complete settings below, or leave empty to get prompts in Terminal
# - WARNING: Make sure the group does not exist already. Existing assignments wil be overwritten ! (unless desired)
#
# Also, changing the assignment or group settings in Jamf Pro will remove the imported computers from the group.
# (Jamf Pro only sees enrolled devices in the "Assignments tab".
# Hence editing the group while not being able to select "imported devices" will clear the membership list.)
############################################################################################################################

# SETTINGS

# Leave empty if you want to be prompted in Terminal

apiUser=""
apiPassword=""
# (JamfPro user with API privileges)

JamfProURL=""
# (for instance: https://myjamfpro.mydomain.com:8443 or https://myjamfpro.jamfcloud.com)

csvPath=""
# (full path to the local csv file)

addToGroup=""
# Yes (y) or No (n) ?

computerGroup=""
# Name of computer group to which imported computers have to be assigned

############################################################################################################################

# DO NOT CHANGE ANYTHING BELOW

#Option to prompt the user for Jamf Pro API credentials
if [[ "$apiUser" == "" ]]; then
    echo "JamfPro User: "
    read apiUser
fi

if [[ "$apiPassword" == "" ]]; then
    echo "JamfPro Password: "
    read -s apiPassword
fi

#Option to prompt the user for Jamf Pro URL
if [[ "$JamfProURL" == "" ]]; then
    echo "JamfPro URL: "
    read JamfProURL
fi

#Option to read in the path from Terminal
if [[ "$csvPath" == "" ]]; then
    echo "Please enter the path to the CSV"
    read csvPath
fi

#Prompt user if computers need to be added to a group
echo "Add computer to a group? - WARNING group membership will be overwritten if existing group!"
Echo "Yes (y) or No (n) ?"
read addToGroup

	if [[ "$addToGroup" == "YES" ]] | [[ "$addToGroup" == "Yes" ]] | [[ "$addToGroup" == "yes" ]] | [[ "$addToGroup" == "y" ]]; then

			#Option to read in the computer group from Terminal
			if [[ "$computerGroup" == "" ]]; then
    			echo "Please enter the computer group"
    			read computerGroup

    			echo " "
				echo "###########################################################################################################"
			fi

			#check if computer group already exist

			curlURL="$JamfProURL/JSSResource/computergroups/name/$computerGroup"
			groupCurlURL=${curlURL// /%20}

			checkGroup=`curl -k -H "Content-Type: application/xml" -u $apiUser:$apiPassword $groupCurlURL -X GET`

			replyXML="The server has not found anything matching the request URI"


			if [[ $checkGroup = *$replyXML* ]]; then
			
				#create the group

				echo "Creating group $computerGroup"
				groupName="<computer_group><name>$computerGroup</name><is_smart>false</is_smart></computer_group>"
				curl -k -H "Content-Type: application/xml" -u $apiUser:$apiPassword $JamfProURL/JSSResource/computergroups/id/0 -d "$groupName" -X POST

			else
				echo " "
				echo "Assigning computers to $computerGroup - overwriting existing assignments!"

			fi

	else
			echo " "
			echo "Not adding computers to a group"		
	
	fi

#Verify we can read the file
data=`cat $csvPath`
if [[ "$data" == "" ]]; then
    echo "Unable to read the file path specified"
    echo "Ensure there are no spaces and that the path is correct"
    exit 1
fi


#Count number of computers in the CSV file
numberOfComputers=`awk -F, 'END {printf "%s\n", NR}' $csvPath`

#Loop through the CSV and get serialNumber and assetTag

counter="0"
duplicates=""
createdRecords="0"

echo " "
echo "###########################################################################################################"

while [ $counter -lt $numberOfComputers ]
do
	counter=$[$counter+1]
	line=`echo "$data" | head -n $counter | tail -n 1`
	serialNumber=`echo "$line" | awk -F , '{print $1}'`
	assetTag=`echo "$line" | awk -F , '{print $2}'`
	groupData="<computer_group><computer_additions><computer><name>$assetTag</name></computer></computer_additions></computer_group>"

echo " "
echo "Processing $serialNumber $assetTag"

	#process data to Jamf Pro

		recordData="<computer><general><name>$assetTag</name><serial_number>$serialNumber</serial_number></general></computer>"
		output=`curl -k -H "Content-Type: application/xml" -u $apiUser:$apiPassword $JamfProURL/JSSResource/computers/id/0 -d "$recordData" -X POST`
		update=`curl -k -H "Content-Type: application/xml" -u $apiUser:$apiPassword $groupCurlURL -d "$groupData" -X PUT`
		echo " "

	#Error Checking
    	error=""
    	error=`echo $output | grep "Conflict"`
    	if [[ $error != "" ]]; then
        	duplicates+=($serialNumber)

    	else 
    		createdRecords=$[$createdRecords+1]

    	fi
done

#provide feedback

echo " "
echo "###########################################################################################################"

	#number of computer records created
		echo " "
		echo "Number of created computer records: ${createdRecords}"
		echo ""

	#Errors
		echo "The following computers could not be created:"
		printf -- '%s\n' "${duplicates[@]}"
		echo " "
		echo "Computer already exists or duplicate in csv file!"
		echo " "

echo "###########################################################################################################"

exit 0
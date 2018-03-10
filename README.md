# importComputersCSV

This script allows you to import a CSV file with serial numbers and computer names. Some people have a 3rd party Asset Manager alongside Jamf Pro, or have a stock of un-enrolled computers which they don't want to enroll in Jamf Pro yet.

Whatever the reason might be to add unmanaged computers to the Jamf Pro inventory, this script will create the inventory records and (optional) assign them to a static group.

Be careful, assigning imported computers to an existing group will overwrite existing assignments in that group.

Also, changing the assignment or group settings in Jamf Pro will remove the imported computers from the group.
(Jamf Pro only sees enrolled devices in the "Assignments tab". Hence editing the group while not being able to select "imported devices" will clear the membership list.)





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

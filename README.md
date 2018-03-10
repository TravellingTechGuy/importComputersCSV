# importComputersCSV

This script allows you to import a CSV file with serial numbers and computer names. Some people have a 3rd party Asset Manager alongside Jamf Pro, or have a stock of un-enrolled computers which they don't want to enroll in Jamf Pro yet.

Whatever the reason might be to add unmanaged computers to the Jamf Pro inventory, this script will create the inventory records and (optional) assign them to a static group.

Be careful, assigning imported computers to an existing group will overwrite existing assignments in that group.

Also, changing the assignment or group settings in Jamf Pro will remove the imported computers from the group.
(Jamf Pro only sees enrolled devices in the "Assignments tab". Hence editing the group while not being able to select "imported devices" will clear the membership list.)

# INSTRUCTIONS

- Create a CSV file or export it from a 3rd party Asset Manager
- Complete settings below, or leave empty to get prompts in Terminal
- WARNING: Make sure the group does not exist already. Existing assignments wil be overwritten ! (unless desired)

Also, changing the assignment or group settings in Jamf Pro will remove the imported computers from the group.
(Jamf Pro only sees enrolled devices in the "Assignments tab").

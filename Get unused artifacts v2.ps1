#Author: Dre Fababeir
#Date Created: 4/29/23
#Date Last Modified: 4/29/23
#This is using a service account
###############################################################################################
# Authenticate with Power BI using the Connect-PowerBIServiceAccount cmdlet
Connect-PowerBIServiceAccount

# Create an empty array to hold the results
$results = @()

# Get all workspaces and their IDs
$allWorkspaces = Get-PowerBIWorkspace

# Loop through the workspaces and add them to the results array
foreach ($workspace in $allWorkspaces) {
    $results += [pscustomobject] @{
        'Workspace Name' = $workspace.Name
        'groupId' = $workspace.Id
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "C:\Users\ahfab\Documents\Lab\workspace_info.csv" -NoTypeInformation

###############################################################################################

# Set the parameters

$csvPath = "C:\Users\ahfab\Documents\Lab\workspace_info.csv"
$apiUrlFormat = "https://api.powerbi.com/v1.0/myorg/admin/groups/{0}/unused"
$outputCsvPath = "C:\Users\ahfab\Documents\Lab\unused_artifacts.csv"

# Create an empty table to store the results
$table = @()

# Read the groupIds from the CSV file
$groupIds = Import-Csv $csvPath

# Loop through each groupId and make the API call
foreach ($groupId in $groupIds) {
    $apiUrl = $apiUrlFormat -f $groupId.groupId
    
# Make the API call and get the response
$response = Invoke-PowerBIRestMethod -Url $apiUrl -Method Get

# Extract the data from the response and select only the desired properties
$groupTable = $response.unusedArtifactEntities | Select-Object -Property `
    artifactId,
    displayName,
    artifactType,
    artifactSizeInMB,
    createdDateTime,
    lastAccessedDateTime

# Add the associated workspace name and groupId to the table
$groupTable | Add-Member -NotePropertyName "Workspace Name" -NotePropertyValue $groupId."Workspace Name"
$groupTable | Add-Member -NotePropertyName "groupId" -NotePropertyValue $groupId."groupId"

# Append the groupTable to the main table
$table += $groupTable

# Display a message to indicate that the export was successful

}

# Export the data to a CSV file
$table | Export-Csv -Path $outputCsvPath -NoTypeInformation

# Display a message to indicate that the export was successful
Write-Host "Exported response to $outputCsvPath" -ForegroundColor Green

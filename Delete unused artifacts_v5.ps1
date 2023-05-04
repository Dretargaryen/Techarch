#Author: Dre Fababeir
#Date Created: 4/29/23
#Date Last Modified: 4/29/23
###################################################################################################################################################################

# Authenticate with Power BI using the Connect-PowerBIServiceAccount cmdlet
Connect-PowerBIServiceAccount

###################################################################################################################################################################

# Parameters
$csvFilePath = "C:\Users\ahfab\Documents\Lab\Cleanupsample.csv"   # Path to the CSV file containing the list of datasets and reports to delete
$exportCsvFilePath = "C:\Users\ahfab\Documents\Lab\deletedartifacts.csv"   # Path to the CSV file to export the confirmed deleted datasets and reports

###################################################################################################################################################################

# Read the CSV file and delete the datasets and reports
$csvData = Import-Csv -Path $csvFilePath
$deletedData = @()

foreach ($row in $csvData) {
    $groupId = $row.GroupId
    $artifactId = $row.ArtifactId
    $artifactType = $row.ArtifactType
    $workspaceName = $row.WorkspaceName

    # Validate the input data
    if (-not $groupId -or -not $artifactId -or -not $artifactType) {
        Write-Host "Warning: Missing required data in row $($csvData.IndexOf($row) + 2) of the input CSV file. Skipping this row."
        continue
    }

    # Delete the artifact based on the type
    switch ($artifactType) {
        "dataset" {
            $deleteArtifactUri = "https://api.powerbi.com/v1.0/myorg/groups/$groupId/datasets/$artifactId"
            $deletedArtifactType = "Dataset"
        }
        "report" {
            $deleteArtifactUri = "https://api.powerbi.com/v1.0/myorg/groups/$groupId/reports/$artifactId"
            $deletedArtifactType = "Report"
        }
        default {
            Write-Host "Warning: Invalid artifact type '$artifactType' in row $($csvData.IndexOf($row) + 2) of the input CSV file. Skipping this row."
            continue
        }
    }

    try {
        Invoke-PowerBIRestMethod -Url $deleteArtifactUri -Method DELETE
        $deletedData += [PSCustomObject] @{
            GroupId = $groupId
            ArtifactId = $artifactId
            ArtifactType = $deletedArtifactType
		WorkspaceName = $workspaceName
            DeletedDate = (Get-Date)
        }
        Write-Host "$deletedArtifactType '$artifactId' has been deleted from group '$groupId' in workspace '$workspaceName'."
    }
    catch {
        Write-Host "Error: Failed to delete $deletedArtifactType '$artifactId' from group '$groupId' in workspace '$workspaceName': $_"
    }
}

# Export the confirmed deleted datasets and reports to a CSV file
$deletedData | Export-Csv -Path $exportCsvFilePath -NoTypeInformation

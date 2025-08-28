 param (
        [string]$sourceDir
    )


#$sourceDir = "C:\path\to\your\directory"
#$zipFile = "C:\path\to\your\zipfile.zip"

$zipFile = $SourceDir.Substring($SourceDir.LastIndexOf('\'))
Write-Host $zipFile

$zipFile = $SourceDir.Substring(0, $SourceDir.LastIndexOf('\')) + $zipFile + '.zip'
Write-Host $zipFile


# Check if the source directory exists
if (!(Test-Path -Path $sourceDir -PathType Container)) {
    Write-Error "Source directory '$sourceDir' not found."
    exit
}

# Check if a zip file with the same name already exists and delete it
if (Test-Path -Path $zipFile) {
    Remove-Item $zipFile
}

# Zip the directory
Compress-Archive -Path $sourceDir -DestinationPath $zipFile

# Check if the zip was successful
if (Test-Path -Path $zipFile) {
    Write-Host "Successfully zipped '$sourceDir' to '$zipFile'."

    # Delete the original directory and its contents
    Remove-Item $sourceDir -Recurse -Force
    Write-Host "Successfully deleted '$sourceDir' and its contents."
} else {
    Write-Error "Failed to zip '$sourceDir'."
}
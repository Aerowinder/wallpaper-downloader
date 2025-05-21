param([Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)][string]$destination)

if (!(Test-Path $destination)){
    Write-Host "ERROR: Provided destination folder does not exist." -ForegroundColor Red
    exit
}

#Local
$src_path = "$($env:LOCALAPPDATA)\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"
foreach ($i in Get-ChildItem -Path $src_path) {
    $image = New-Object System.Drawing.Bitmap $i.Fullname

    if ($image.Width -eq '1920' -And !(Test-Path -Path ($destination + '\' + $i.Name + '.jpg'))) {
        Copy-Item -Path $i.FullName -Destination ($destination + '\' + $i.Name + '.jpg')
    }

    $image.Dispose()
}

#Remote
$w10spotlight = Invoke-WebRequest https://windows10spotlight.com
foreach ($image in $w10spotlight.Images.src) {
    if ($image -notlike '*.jpg') {continue}

    $web_path = $image.Replace('-1024x576','') #Remove thumbnail size info from name
    $local_filename = $web_path -Replace '.*\/' #Pull out the filename of the .jpg from the URL

    if (!(Test-Path -Path "$destination\$local_filename")) {
        Invoke-WebRequest -Uri $web_path -OutFile "$destination\$local_filename"
    }
}

#Changelog
#2024-02-09 - AS - v1, First release.
#2024-02-16 - AS - v2, Commandline destination required for compatibility in multiple locations.
#2024-03-01 - AS - v3, Added windows10spotlight.com scraping. Got tired of manually downloading.
#                      Removed 1080 and 4K downloads. I don't use them and it would take more work to scrape the images from windows10spotlight.com.

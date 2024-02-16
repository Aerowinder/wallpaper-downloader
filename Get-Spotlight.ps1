param([Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)][string]$destination)

if (Test-Path $destination){
    $dst_path_1080 = "$destination\1080x1920\"
    $dst_path_1920 = "$destination\1920x1080\"
    $dst_path_3840 = "$destination\3840x2160\"
} else {
    Write-Host "ERROR: Provided destination folder does not exist." -ForegroundColor Red
    exit
}

$src_path = "$($env:LOCALAPPDATA)\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"

foreach ($i in Get-ChildItem -Path $src_path) {
    $image = New-Object System.Drawing.Bitmap $i.Fullname

    switch ($image.Width) {
        #We are testing to see if the file exists in the destination path before copying. This is just to reduce OneDrive new file spam and to keep file dates accurate.
        '1080' {if (-Not(Test-Path -Path ($dst_path_1080 + $i.Name + '.jpg'))) {Copy-Item -Path $i.FullName -Destination ($dst_path_1080 + $i.Name + '.jpg')}}
        '1920' {if (-Not(Test-Path -Path ($dst_path_1920 + $i.Name + '.jpg'))) {Copy-Item -Path $i.FullName -Destination ($dst_path_1920 + $i.Name + '.jpg')}}
        '3840' {if (-Not(Test-Path -Path ($dst_path_3840 + $i.Name + '.jpg'))) {Copy-Item -Path $i.FullName -Destination ($dst_path_3840 + $i.Name + '.jpg')}}
    }

    $image.Dispose()
}

#Changelog
#2024-02-09 - AS - v1, First release.
#2024-02-16 - As - v2, Commandline destination required for compatibility in multiple locations.

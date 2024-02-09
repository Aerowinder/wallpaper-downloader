#User customizable variables#
$src_path = "$($env:LOCALAPPDATA)\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"
$dst_path_1080 = "$($env:ONEDRIVE)\Private\Wallpaper\1080x1920\"
$dst_path_1920 = "$($env:ONEDRIVE)\Private\Wallpaper\1920x1080\"
$dst_path_3840 = "$($env:ONEDRIVE)\Private\Wallpaper\3840x2160\"
#############################

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

$total_pages = 1075
$destination = 'C:\Users\aseverns\Desktop\image'

for ($page = 1; $page -le $total_pages; $page++) {
    Write-Host "Scraping page $page of $total_pages..."

    $w10spotlight = Invoke-WebRequest "https://windows10spotlight.com/page/$page"
    foreach ($image in $w10spotlight.Images.src) {
        if ($image -notlike '*.jpg') {continue}

        $web_path = $image.Replace('-1024x576','') #Remove thumbnail size info from name
        $local_filename = $web_path -Replace '.*\/' #Pull out the filename of the .jpg from the URL

        if (!(Test-Path -Path "$destination\$local_filename")) {
            Invoke-WebRequest -Uri $web_path -OutFile "$destination\$local_filename"
        }
    }
}

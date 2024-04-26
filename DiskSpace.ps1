#force TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

#defining device name
$deviceName = [System.Net.Dns]::GetHostByName($env:computerName).HostName

#Get the date/time
$date = Get-Date -Format "MM/dd/yyyy HH:mm:ss"

#Define the minimum free space percentage
$threshold = 10

#Get all drives on the device
$drives = Get-WmiObject Win32_LogicalDisk -Filter "DriveType = 3" | Select-Object DeviceID, FreeSpace, Size

#initialize a variable to return false if any drive is below the threshold
$driveHealth = $true

#Loop through each drive and check the free space percentage, set driveHealth to false if any drive is below the threshold
foreach ($drive in $drives){
    $freeSpacePercentage = ($drive.FreeSpace / $drive.Size) * 100

    if ($freeSpacePercentage -lt $threshold){
        $driveHealth = $false
    }
}

#retrieving info from supabase json file
$jsonFilePath = "C:\GreenBananas\supabase.json"
$jsonContent = Get-Content -Raw -Path $jsonFilePath
$jsonObject = ConvertFrom-Json $jsonContent

#defining variables for each object in json file
$anonKey = $jsonObject.anonKey
$url = $jsonObject.url
$clientJWT = $jsonObject.clientJWT

#defining variables for each object in json file
$anonKey = $jsonObject.anonKey
$url = $jsonObject.url
$clientJWT = $jsonObject.clientJWT

#defining table name
$tableName = "Disk Space"

#defining primary key
$primaryKey = "?ServerName=eq." + $deviceName

#preparing uri
$uri = $url + "/" + $tableName + $primaryKey

#prepare headers
$headers = @{
    "Content-Type" = "application/json"
    "apikey" = $anonKey
    "Authorization" = "Bearer " + $clientJWT
}

#prepare json body
$body = @{
    "DriveHealth" = $driveHealth
    "Date" = $date
} | ConvertTo-Json

#send the servername, date, and drivehealth to supabase
Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body $body

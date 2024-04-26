#force TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

#checking for Defender/Huntress Services
$defenderService = Get-Service sense
$huntressService = Get-Service huntressagent

#creating booleans for defender/huntress and string for device name
[bool] $defender
[bool] $huntress
[bool] $antivirusHealth

#Get device name
$deviceName = [System.Net.Dns]::GetHostByName($env:computerName).HostName

#Get the date/time
$date = Get-Date -Format "MM/dd/yyyy HH:mm:ss"

#check if defender service is running
if ($defenderService.Status -eq 'Running') {
    $defender = $true}
    else {$defender = $false
}

#check if Huntress service running
if ($huntressService.Status -eq 'Running') {
    $huntress = $true}
    else {$huntress = $false
}

#if either service is running, set antivirus health to true
if ($defender -eq $true -or $huntress -eq $true) {
    $antivirusHealth = $true}
    else {$antivirusHealth = $false
}

#retrieving info from supabase json file
$jsonFilePath = "C:\GreenBananas\supabase.json"
$jsonContent = Get-Content -Raw -Path $jsonFilePath
$jsonObject = ConvertFrom-Json $jsonContent

#defining variables for each object in json file
$anonKey = $jsonObject.anonKey
$url = $jsonObject.url
$clientJWT = $jsonObject.clientJWT

#defining table name
$tableName = "Anti-Virus"

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
    "Antivirus" = $antivirusHealth
    "Date" = $date
} | ConvertTo-Json

#send the servername, date, and drivehealth to supabase
Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body $body
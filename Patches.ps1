#force TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

#query the device for missing updates (excludeing drivers with Type='Software')
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$SearchResult = $Searcher.Search("IsInstalled=0 and Type='Software'")
$Updates = $SearchResult.Updates

# defining variables to store number of missing updates and names of missing updates
$updateCount = 0
$updateNames = @()

#loop through all the updates and store missing update count and names 
foreach ($Update in $Updates) {
    $updateCount++
    $updateNames += $Update.Title
}

#defining device name
$deviceName = [System.Net.Dns]::GetHostByName($env:computerName).HostName

#Get the date/time
$date = Get-Date -Format "MM/dd/yyyy HH:mm:ss"

#retreiving info from json file created by setup script
$jsonFilePath = "C:\GreenBananas\supabase.json"
$jsonContent = Get-Content -Raw -Path $jsonFilePath
$jsonObject = ConvertFrom-Json $jsonContent

#defining variables for each object in json file
$anonKey = $jsonObject.anonKey
$url = $jsonObject.url
$clientJWT = $jsonObject.clientJWT

#defining table name
$tableName = "Patches"

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
    "Date" = $date
    "UpdateCount" = $updateCount
    "Updates" = $updateNames
} | ConvertTo-Json

#send missing update count and names to supabase with timestamp
Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body $body
# Force TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Query the device for missing updates (excluding drivers and updates where category isn't definition)
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$SearchResult = $Searcher.Search("IsInstalled=0 and Type='Software'")
$Updates = $SearchResult.Updates | Where-Object { $_.Categories | ForEach-Object { $_.Name -notlike "*Definition*" } }

# Defining variables to store number of missing updates and names of missing updates
$updateCount = 0
$updateNames = @()

# Loop through all the updates and store missing update count and names 
foreach ($Update in $Updates) {
    $updateCount++
    $updateNames += $Update.Title
}

# Create an instance of AutomaticUpdates
$AutoUpdate = New-Object -ComObject "Microsoft.Update.AutoUpdate"

# Get the settings
$Settings = $AutoUpdate.Settings

# Check if automatic updates are enabled
if ($Settings.NotificationLevel -eq 4) {
    $automaticUpdates = $true
} else {
    $automaticUpdates = $false
}

# Defining device name
$deviceName = [System.Net.Dns]::GetHostByName($env:computerName).HostName

# Get the date/time
$date = Get-Date -Format "MM/dd/yyyy HH:mm:ss"

# Retrieving info from JSON file created by setup script
$jsonFilePath = "C:\GreenBananas\supabase.json"
$jsonContent = Get-Content -Raw -Path $jsonFilePath
$jsonObject = ConvertFrom-Json $jsonContent

# Defining variables for each object in JSON file
$anonKey = $jsonObject.anonKey
$url = $jsonObject.url
$clientJWT = $jsonObject.clientJWT

# Defining table name
$tableName = "Patches"

# Defining primary key
$primaryKey = "?ServerName=eq." + $deviceName

# Preparing URI
$uri = $url + "/" + $tableName + $primaryKey

# Prepare headers
$headers = @{
    "Content-Type" = "application/json"
    "apikey" = $anonKey  
    "Authorization" = "Bearer " + $clientJWT
}

# Prepare JSON body
$body = @{
    "Date" = $date
    "UpdateCount" = $updateCount
    "Updates" = $updateNames
    "AutoUpdate" = $automaticUpdates
} | ConvertTo-Json

# Send missing update count and names to Supabase with timestamp
Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body $body

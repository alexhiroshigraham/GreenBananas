#force TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

#retreiving info from json file created by setup script
$jsonFilePath = "C:\GreenBananas\supabase.json"
$jsonContent = Get-Content -Raw -Path $jsonFilePath
$jsonObject = ConvertFrom-Json $jsonContent

#defining variables for each object in json file
$anonKey = $jsonObject.anonKey
$clientName = $jsonObject.clientName
$url = $jsonObject.url
$clientJWT = $jsonObject.clientJWT

#defining device name
$deviceName = $($env:COMPUTERNAME)

#defining table name
$tableName = "StoragePool"

#defining primary key
$primaryKey = "?ServerName=eq." + $deviceName

#preparing uri
$uri = $url + "/" + $tableName + $primaryKey

#Get current date/time
$date = Get-Date -Format "MM/dd/yyyy HH:mm:ss"

#defining variable for storage pool health
$health=(Get-StoragePool -IsPrimordial $False).HealthStatus


#prepare headers
$headers = @{
    "Content-Type" = "application/json"
    "apikey" = $anonKey  
    "Authorization" = "Bearer " + $clientJWT
}

#prepare json body
$body = @{
    "StoragePool" = $date
} | ConvertTo-Json

#check if Storage Pool health = healthy and send current date to supabase
if ($health -contains 'Healthy' -and $health -notcontains 'Warning' -and $health -notcontains 'Critical'){
    Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body $body
}

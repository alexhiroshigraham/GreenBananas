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
$deviceName = [System.Net.Dns]::GetHostByName($env:computerName).HostName

#Get current date/time
$date = Get-Date -Format "MM/dd/yyyy HH:mm:ss"

#defining Supabase table name
$tableName = "Hyper-V"

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
    "Hyper-V" = $date
} | ConvertTo-Json

#defining variable for replication health
$repHealth = (Get-VMReplication).Health

#check if replication health = healthy and send current date to supabase
if ($rephealth -contains 'Normal' -and $rephealth -notcontains 'Warning' -and $rephealth -notcontains 'Critical'){
    Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body $body
}

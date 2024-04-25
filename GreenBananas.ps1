#force TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

#defining Github URLs
$downloaderURL = "https://github.com/alexhiroshigraham/GreenBananas/raw/main/Downloader.ps1"


#defining file path
$filePath = "C:\GreenBananas\"
$downloaderPath = "C:\GreenBananas\Downloader.ps1"

#retreiving info from supabase.json
$jsonFilePath = "C:\GreenBananas\supabase.json"
$jsonContent = Get-Content -Raw -Path $jsonFilePath
$jsonObject = ConvertFrom-Json $jsonContent

$serversURL = $jsonObject.serversURL

#download servers.json from supabase
Invoke-WebRequest -Uri $serversURL -OutFile "$filePath\servers.json" 

#load json file into variables
$serverJSONPath = $filePath + "\servers.json"
$serversContent = Get-Content -Raw -Path $serverJSONPath
$serversObject = ConvertFrom-Json $serversContent

#download the scripts downloader from Github
Invoke-WebRequest -Uri $downloaderURL -OutFile $downloaderPath

#run the downloader script
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File $downloaderPath" -Wait

#defining device name
$deviceName = [System.Net.Dns]::GetHostByName($env:computerName).HostName

#read the servers json and if the device name matches $_.Name, run the scripts in the array.
$serversObject | ForEach-Object {
    if ($deviceName -eq $_.Name){
        $_.Scripts | ForEach-Object {
            $fullPath = Join-Path $filePath $_
            Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File $fullPath" -Wait
        }
    }
}

#force TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

#defining file path
$filePath = "C:\GreenBananas\"

#defining Storage Pool Script URL
$storagePool = "https://github.com/alexhiroshigraham/GreenBananas/raw/main/StoragePool.ps1"

#defining Hyper-V Replication Health Script URL
$hyperV = "https://github.com/alexhiroshigraham/GreenBananas/raw/main/HyperV.ps1"

#defining Disk Space Script URL
$diskSpace = "https://github.com/alexhiroshigraham/GreenBananas/raw/main/DiskSpace.ps1"

#downloading Storage Pool Script from Github
Invoke-WebRequest -Uri $storagePool -OutFile "$filePath\StoragePool.ps1"

#downloading Hyper-V Replication Health Script from Github
Invoke-WebRequest -Uri $hyperV -OutFile "$filePath\HyperV.ps1"

#downloading Disk Space Script from Github
Invoke-WebRequest -Uri $diskSpace -OutFile "$filePath\DiskSpace.ps1"

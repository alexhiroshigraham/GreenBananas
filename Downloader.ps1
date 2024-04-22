#defining file path
$filePath = "C:\GreenBananas\"

#defining Storage Pool Script URL
$storagePool = "https://github.com/alexhiroshigraham/GreenBananas/raw/main/StoragePool.ps1"

#defining Hyper-V Replication Health Script URL
$hyperV = "https://github.com/alexhiroshigraham/GreenBananas/raw/main/HyperV.ps1"

#downloading Storage Pool Script from Github
Invoke-WebRequest -Uri $storagePool -OutFile "$filePath\StoragePool.ps1"

#downloading Hyper-V Replication Health Script from Github
Invoke-WebRequest -Uri $hyperV -OutFile "$filePath\HyperV.ps1"

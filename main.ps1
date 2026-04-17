# scanner.ps1
# Suppress error messages for a cleaner output
$ErrorActionPreference = "SilentlyContinue"

Write-Host "Scanning hardware... Please wait." -ForegroundColor Cyan

# Gather CPU Info
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

# Gather RAM Info
$system = Get-CimInstance Win32_ComputerSystem | Select-Object -First 1

# Gather Storage Info
$disks = Get-CimInstance Win32_DiskDrive | Select-Object Model, @{Name="SizeGB";Expression={[Math]::Round($_.Size / 1GB, 2)}}

# Gather GPU Info
$gpus = Get-CimInstance Win32_VideoController | Select-Object Name, @{Name="VRAM_MB";Expression={[Math]::Round($_.AdapterRAM / 1MB, 2)}}

# Gather Network Info (Only physical adapters to filter out virtual VPN adapters)
$network = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -eq $true } | Select-Object Name, NetConnectionID

# Construct the JSON structure
$hardwareInfo = @{
    "System" = @{
        "Manufacturer" = $system.Manufacturer
        "Model" = $system.Model
    }
    "CPU" = @{
        "Model" = $cpu.Name
        "Cores" = $cpu.NumberOfCores
# Simplified for modern processors
        "Architecture" = "x64"
    }
    "Memory" = @{
        "Total_GB" = [Math]::Round($system.TotalPhysicalMemory / 1GB, 2)
    }
    "Storage" = $disks
    "Graphics" = $gpus
    "Network_Adapters" = $network
}

# Output to JSON file
$outputPath = Join-Path -Path $env:USERPROFILE\Desktop -ChildPath "lab_hardware_specs.json"

$hardwareInfo | ConvertTo-Json -Depth 4 | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host "Success! Hardware specs saved to: $outputPath" -ForegroundColor Green

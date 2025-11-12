# Quick Configuration Script
Write-Host "Configuring Windows Agent..." -ForegroundColor Cyan

# Stop service
Stop-Service WazuhSvc -Force
Start-Sleep -Seconds 3

# Backup
Copy-Item "C:\Program Files (x86)\ossec-agent\ossec.conf" "C:\Program Files (x86)\ossec-agent\ossec.conf.backup"

# Enable Windows Auditing
auditpol /set /subcategory:"Process Creation" /success:enable
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f

# Add Event 4688 to ossec.conf
[xml]$xml = Get-Content "C:\Program Files (x86)\ossec-agent\ossec.conf"

$localfile = $xml.CreateElement("localfile")
$location = $xml.CreateElement("location")
$location.InnerText = "Security"
$localfile.AppendChild($location) | Out-Null

$logFormat = $xml.CreateElement("log_format")
$logFormat.InnerText = "eventchannel"
$localfile.AppendChild($logFormat) | Out-Null

$query = $xml.CreateElement("query")
$query.InnerText = "Event/System[EventID=4688]"
$localfile.AppendChild($query) | Out-Null

$xml.ossec_config.AppendChild($localfile) | Out-Null
$xml.Save("C:\Program Files (x86)\ossec-agent\ossec.conf")

# Start service
Start-Service WazuhSvc
Start-Sleep -Seconds 15

Write-Host "Configuration complete! Generating test event..." -ForegroundColor Green

# Generate test event
powershell.exe -EncodedCommand UABvAHcAZQByAFMAaABlAGwAbAAgAC0ATgBvAFAAcgBvAGYAaQBsAGUA

Write-Host "Done! Check Wazuh manager in 60 seconds:" -ForegroundColor Yellow
Write-Host "  sudo tail -f /var/ossec/logs/archives/archives.log" -ForegroundColor White
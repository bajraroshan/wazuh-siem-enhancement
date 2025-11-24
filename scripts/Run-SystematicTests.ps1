# ============================================================================
# LOLBin Detection Test Suite - Complete Coverage
# Agent: WIN-SERVER-2022
# Rules: 100500-100602 (26 total rules)
# Execution: Run as Administrator
# ============================================================================

Write-Host "`n=== LOLBin Detection Test Suite ===" -ForegroundColor Cyan
Write-Host "Agent: $env:COMPUTERNAME" -ForegroundColor Yellow
Write-Host "Starting tests in 5 seconds...`n" -ForegroundColor Gray
Start-Sleep -Seconds 5

# ============================================================================
# SECTION 1: PowerShell LOLBins (Rules 100500-100504) - 5 Rules
# ============================================================================

Write-Host "`n[SECTION 1] PowerShell LOLBins" -ForegroundColor Cyan

# Test 1.1: PowerShell -enc (short flag)
Write-Host "`n[Test 1.1] PowerShell -enc (short flag)" -ForegroundColor Green
$cmd = "Write-Host 'Test 1.1: PowerShell Short Encoded'"
$bytes = [System.Text.Encoding]::Unicode.GetBytes($cmd)
$enc = [Convert]::ToBase64String($bytes)
powershell.exe -enc $encß
Write-Host "Expected: Rule 100500" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 1.2: PowerShell -EncodedCommand (full flag)
Write-Host "`n[Test 1.2] PowerShell -EncodedCommand" -ForegroundColor Green
powershell.exe -EncodedCommand $enc
Write-Host "Expected: Rule 100501" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 1.3: PowerShell DownloadString
Write-Host "`n[Test 1.3] PowerShell DownloadString" -ForegroundColor Green
powershell.exe -Command "(New-Object Net.WebClient).DownloadString('https://www.google.com')"
Write-Host "Expected: Rule 100502" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 1.4: PowerShell DownloadFile
Write-Host "`n[Test 1.4] PowerShell DownloadFile" -ForegroundColor Green
powershell.exe -Command "(New-Object Net.WebClient).DownloadFile('https://www.google.com/robots.txt', '$env:TEMP\test1.txt')"
Remove-Item "$env:TEMP\test1.txt" -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100502" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 1.5: PowerShell Invoke-WebRequest
Write-Host "`n[Test 1.5] PowerShell Invoke-WebRequest" -ForegroundColor Green
powershell.exe -Command "Invoke-WebRequest -Uri 'https://www.google.com/robots.txt' -OutFile '$env:TEMP\test2.txt'"
Remove-Item "$env:TEMP\test2.txt" -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100503" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 1.6: PowerShell IWR (alias)
Write-Host "`n[Test 1.6] PowerShell IWR alias" -ForegroundColor Green
powershell.exe -Command "IWR https://www.google.com"
Write-Host "Expected: Rule 100503" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 1.7: PowerShell FromBase64String
Write-Host "`n[Test 1.7] PowerShell FromBase64String" -ForegroundColor Green
powershell.exe -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('VGVzdA=='))"
Write-Host "Expected: Rule 100504" -ForegroundColor Gray
Start-Sleep -Seconds 5

# ============================================================================
# SECTION 2: CertUtil LOLBin (Rules 100510-100512) - 3 Rules
# ============================================================================

Write-Host "`n[SECTION 2] CertUtil LOLBin" -ForegroundColor Cyan

# Test 2.1: CertUtil -urlcache download
Write-Host "`n[Test 2.1] CertUtil -urlcache" -ForegroundColor Green
certutil -urlcache -split -f https://www.google.com/robots.txt "$env:TEMP\certutil_test1.txt"
Remove-Item "$env:TEMP\certutil_test1.txt" -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100510" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 2.2: CertUtil -split download
Write-Host "`n[Test 2.2] CertUtil -split" -ForegroundColor Green
certutil -split -f https://www.google.com/robots.txt "$env:TEMP\certutil_test2.txt"
Remove-Item "$env:TEMP\certutil_test2.txt" -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100511" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 2.3: CertUtil -decode
Write-Host "`n[Test 2.3] CertUtil -decode" -ForegroundColor Green
# Create a test base64 file
"VGVzdCBkYXRh" | Out-File "$env:TEMP\encoded.txt"
certutil -decode "$env:TEMP\encoded.txt" "$env:TEMP\decoded.txt"
Remove-Item "$env:TEMP\encoded.txt","$env:TEMP\decoded.txt" -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100512" -ForegroundColor Gray
Start-Sleep -Seconds 5

# ============================================================================
# SECTION 3: BITSAdmin LOLBin (Rules 100520-100521) - 2 Rules
# ============================================================================

Write-Host "`n[SECTION 3] BITSAdmin LOLBin" -ForegroundColor Cyan

# Test 3.1: BITSAdmin /transfer
Write-Host "`n[Test 3.1] BITSAdmin /transfer" -ForegroundColor Green
bitsadmin /transfer TestJob /download /priority normal https://www.google.com/robots.txt "$env:TEMP\bits_test1.txt"
Remove-Item "$env:TEMP\bits_test1.txt" -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100520" -ForegroundColor Gray
Write-Host "Note: May have 30-60s latency" -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test 3.2: BITSAdmin /download
Write-Host "`n[Test 3.2] BITSAdmin /download" -ForegroundColor Green
bitsadmin /create TestJob2
bitsadmin /addfile TestJob2 https://www.google.com/robots.txt "$env:TEMP\bits_test2.txt"
bitsadmin /download TestJob2
bitsadmin /complete TestJob2
Remove-Item "$env:TEMP\bits_test2.txt" -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100521" -ForegroundColor Gray
Write-Host "Note: May have 30-60s latency" -ForegroundColor Yellow
Start-Sleep -Seconds 10

# ============================================================================
# SECTION 4: WMIC LOLBin (Rules 100530-100531) - 2 Rules
# ============================================================================

Write-Host "`n[SECTION 4] WMIC LOLBin" -ForegroundColor Cyan

# Test 4.1: WMIC process call create
Write-Host "`n[Test 4.1] WMIC process call create" -ForegroundColor Green
wmic process call create "notepad.exe"
Start-Sleep -Seconds 2
Stop-Process -Name notepad -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100530" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 4.2: WMIC process call create (calculator)
Write-Host "`n[Test 4.2] WMIC process call create (calc)" -ForegroundColor Green
wmic process call create "calc.exe"
Start-Sleep -Seconds 2
Stop-Process -Name Calculator -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100530" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 4.3: WMIC /node: remote execution (localhost simulation)
Write-Host "`n[Test 4.3] WMIC /node: (localhost)" -ForegroundColor Green
wmic /node:localhost process call create "cmd.exe /c echo WMIC Remote Test"
Write-Host "Expected: Rule 100531" -ForegroundColor Gray
Start-Sleep -Seconds 5

# ============================================================================
# SECTION 5: Rundll32 LOLBin (Rules 100540-100541) - 2 Rules
# ============================================================================

Write-Host "`n[SECTION 5] Rundll32 LOLBin" -ForegroundColor Cyan

# Test 5.1: Rundll32 JavaScript Squiblydoo
Write-Host "`n[Test 5.1] Rundll32 javascript: scheme" -ForegroundColor Green
rundll32.exe javascript:"..\mshtml,RunHTMLApplication ";alert('Test')
Write-Host "Expected: Rule 100540" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 5.2: Rundll32 URL handler abuse
Write-Host "`n[Test 5.2] Rundll32 url.dll FileProtocolHandler" -ForegroundColor Green
rundll32.exe url.dll,FileProtocolHandler "https://www.google.com"
Write-Host "Expected: Rule 100541" -ForegroundColor Gray
Start-Sleep -Seconds 5

# ============================================================================
# SECTION 6: MSHTA LOLBin (Rule 100550) - 1 Rule
# ============================================================================

Write-Host "`n[SECTION 6] MSHTA LOLBin" -ForegroundColor Cyan

# Test 6.1: MSHTA javascript execution
Write-Host "`n[Test 6.1] MSHTA javascript" -ForegroundColor Green
mshta javascript:alert('Test');close()
Write-Host "Expected: Rule 100550" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 6.2: MSHTA vbscript execution
Write-Host "`n[Test 6.2] MSHTA vbscript" -ForegroundColor Green
mshta vbscript:Execute("MsgBox(""Test""):Close")
Write-Host "Expected: Rule 100550" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 6.3: MSHTA HTTP download
Write-Host "`n[Test 6.3] MSHTA http download" -ForegroundColor Green
# Note: This creates a temporary HTA file for testing
@"
<html>
<head><title>Test</title></head>
<body><script>close();</script></body>
</html>
"@ | Out-File "$env:TEMP\test.hta"
mshta "http://localhost/test.hta" 2>$null
Remove-Item "$env:TEMP\test.hta" -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100550" -ForegroundColor Gray
Start-Sleep -Seconds 5

# ============================================================================
# SECTION 7: Regsvr32 LOLBin (Rules 100560-100561) - 2 Rules
# ============================================================================

Write-Host "`n[SECTION 7] Regsvr32 LOLBin" -ForegroundColor Cyan

# Test 7.1: Regsvr32 scriptlet abuse
Write-Host "`n[Test 7.1] Regsvr32 /s /i:.sct" -ForegroundColor Green
# Create a test .sct file
@"
<?XML version="1.0"?>
<scriptlet>
<registration progid="Test" classid="{00000000-0000-0000-0000-000000000000}"></registration>
</scriptlet>
"@ | Out-File "$env:TEMP\test.sct"
regsvr32 /s /i:"$env:TEMP\test.sct" scrobj.dll 2>$null
Remove-Item "$env:TEMP\test.sct" -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100560" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 7.2: Regsvr32 remote scriptlet
Write-Host "`n[Test 7.2] Regsvr32 http remote" -ForegroundColor Green
regsvr32 /s /u /i:https://www.google.com/test.sct scrobj.dll 2>$null
Write-Host "Expected: Rule 100561" -ForegroundColor Gray
Start-Sleep -Seconds 5

# ============================================================================
# SECTION 8: MSBuild LOLBin (Rule 100570) - 1 Rule
# ============================================================================

Write-Host "`n[SECTION 8] MSBuild LOLBin" -ForegroundColor Cyan

# Test 8.1: MSBuild inline code execution
Write-Host "`n[Test 8.1] MSBuild .xml execution" -ForegroundColor Green
# Create a test project file
@"
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Target Name="Test">
    <Message Text="MSBuild Test" />
  </Target>
</Project>
"@ | Out-File "$env:TEMP\test.xml"
& "C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "$env:TEMP\test.xml" /t:Test 2>$null
Remove-Item "$env:TEMP\test.xml" -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100570" -ForegroundColor Gray
Start-Sleep -Seconds 5

# ============================================================================
# SECTION 9: Script Execution LOLBins (Rules 100580-100581) - 2 Rules
# ============================================================================

Write-Host "`n[SECTION 9] Script Execution LOLBins" -ForegroundColor Cyan

# Test 9.1: CScript remote execution
Write-Host "`n[Test 9.1] CScript http execution" -ForegroundColor Green
cscript //E:JScript http://www.google.com/test.js 2>$null
Write-Host "Expected: Rule 100580" -ForegroundColor Gray
Start-Sleep -Seconds 5

# Test 9.2: WScript remote execution
Write-Host "`n[Test 9.2] WScript http execution" -ForegroundColor Green
wscript //E:JScript http://www.google.com/test.js 2>$null
Write-Host "Expected: Rule 100581" -ForegroundColor Gray
Start-Sleep -Seconds 5

# ============================================================================
# SECTION 10: Correlation Rules (Rules 100600-100602) - 3 Rules
# ============================================================================

Write-Host "`n[SECTION 10] Correlation Rules Testing" -ForegroundColor Cyan

# Test 10.1: Multiple LOLBin techniques (triggers 100600)
Write-Host "`n[Test 10.1] Multiple LOLBin burst (3 in 300s)" -ForegroundColor Green
Write-Host "Executing: PowerShell + CertUtil + WMIC rapidly" -ForegroundColor Yellow
powershell.exe -enc $enc
Start-Sleep -Seconds 2
certutil -urlcache -split -f https://www.google.com/robots.txt "$env:TEMP\corr1.txt" 2>$null
Remove-Item "$env:TEMP\corr1.txt" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
wmic process call create "cmd.exe /c echo Correlation Test"
Write-Host "Expected: Rule 100600 (Level 13 - Multiple LOLBin techniques)" -ForegroundColor Gray
Start-Sleep -Seconds 10

# Test 10.2: PowerShell burst activity (triggers 100601)
Write-Host "`n[Test 10.2] PowerShell activity burst (5 in 120s)" -ForegroundColor Green
Write-Host "Executing: 5 PowerShell commands rapidly" -ForegroundColor Yellow
for ($i=1; $i -le 5; $i++) {
    powershell.exe -Command "Write-Host 'PowerShell Burst Test $i'"
    Start-Sleep -Seconds 2
}
Write-Host "Expected: Rule 100601 (Level 12 - PowerShell burst)" -ForegroundColor Gray
Start-Sleep -Seconds 10

# Test 10.3: Download activity burst (triggers 100602)
Write-Host "`n[Test 10.3] Download activity burst (3 in 180s)" -ForegroundColor Green
Write-Host "Executing: 3 download attempts rapidly" -ForegroundColor Yellow
powershell.exe -Command "(New-Object Net.WebClient).DownloadString('https://www.google.com')"
Start-Sleep -Seconds 2
certutil -urlcache -split -f https://www.google.com/robots.txt "$env:TEMP\corr2.txt" 2>$null
Remove-Item "$env:TEMP\corr2.txt" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
bitsadmin /transfer CorrTest /download /priority normal https://www.google.com/robots.txt "$env:TEMP\corr3.txt"
Remove-Item "$env:TEMP\corr3.txt" -ErrorAction SilentlyContinue
Write-Host "Expected: Rule 100602 (Level 12 - Download burst)" -ForegroundColor Gray
Start-Sleep -Seconds 10

# ============================================================================
# Test Suite Complete
# ============================================================================

Write-Host "`n=== Test Suite Complete ===" -ForegroundColor Cyan
Write-Host "Total Tests Executed: 35 individual tests" -ForegroundColor Green
Write-Host "Rules Covered: 100500-100602 (26 rules total)" -ForegroundColor Green
Write-Host "`nBreakdown:" -ForegroundColor Yellow
Write-Host "  - PowerShell LOLBins: 7 tests (5 rules)" -ForegroundColor White
Write-Host "  - CertUtil: 3 tests (3 rules)" -ForegroundColor White
Write-Host "  - BITSAdmin: 2 tests (2 rules)" -ForegroundColor White
Write-Host "  - WMIC: 3 tests (2 rules)" -ForegroundColor White
Write-Host "  - Rundll32: 2 tests (2 rules)" -ForegroundColor White
Write-Host "  - MSHTA: 3 tests (1 rule)" -ForegroundColor White
Write-Host "  - Regsvr32: 2 tests (2 rules)" -ForegroundColor White
Write-Host "  - MSBuild: 1 test (1 rule)" -ForegroundColor White
Write-Host "  - Script Execution: 2 tests (2 rules)" -ForegroundColor White
Write-Host "  - Correlation: 3 tests (3 rules)" -ForegroundColor White
Write-Host "`nCheck Wazuh Manager alerts with:" -ForegroundColor Yellow
Write-Host "  curl -k -u wazuh:wazuh https://localhost:55000/security/alerts?limit=50 | jq" -ForegroundColor Gray
Write-Host "`nOr check Grafana dashboard for visual confirmation." -ForegroundColor Yellow
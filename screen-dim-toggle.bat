@echo off
rem 3-stage toggle. 1: normal (light theme, night light OFF)  2: dim (dark theme, night light ON)  3: dimmer (stage 2 + screen dimmed by software)
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$s=Get-Content -LiteralPath '%~f0' -Raw; iex $s.Substring($s.LastIndexOf('#PSSTART')+8)"
exit /b
#PSSTART
$dim3=0.6   # stage 3 brightness (1.0 = normal, smaller = darker, about 0.5 is the Windows limit)

$p='HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$sk='HKCU:\Software\DimToggle'
$light=(Get-ItemProperty -Path $p -Name AppsUseLightTheme -ErrorAction SilentlyContinue).AppsUseLightTheme
$stage=(Get-ItemProperty -Path $sk -Name Stage -ErrorAction SilentlyContinue).Stage
if($light -ne 0){$stage=1}elseif($stage -ne 3){$stage=2}
$next=($stage % 3)+1

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class DimG {
  [StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)]
  public struct DD {
    public int cb;
    [MarshalAs(UnmanagedType.ByValTStr,SizeConst=32)] public string DeviceName;
    [MarshalAs(UnmanagedType.ByValTStr,SizeConst=128)] public string DeviceString;
    public int StateFlags;
    [MarshalAs(UnmanagedType.ByValTStr,SizeConst=128)] public string DeviceID;
    [MarshalAs(UnmanagedType.ByValTStr,SizeConst=128)] public string DeviceKey;
  }
  [DllImport("user32.dll",CharSet=CharSet.Unicode)] static extern bool EnumDisplayDevices(string d,uint i,ref DD dd,uint f);
  [DllImport("gdi32.dll",CharSet=CharSet.Unicode)] static extern IntPtr CreateDC(string drv,string dev,string o,IntPtr m);
  [DllImport("gdi32.dll")] static extern bool DeleteDC(IntPtr h);
  [DllImport("gdi32.dll")] static extern bool SetDeviceGammaRamp(IntPtr h,ushort[] r);
  [DllImport("user32.dll",CharSet=CharSet.Unicode)] static extern IntPtr SendMessageTimeout(IntPtr hWnd,uint Msg,UIntPtr wParam,string lParam,uint fuFlags,uint uTimeout,out UIntPtr res);
  public static void Notify(){ UIntPtr r; SendMessageTimeout((IntPtr)0xffff,0x1A,UIntPtr.Zero,"ImmersiveColorSet",2,2000,out r); }
  public static bool Set(double f){
    ushort[] r=new ushort[768];
    for(int i=0;i<256;i++){ int v=(int)(i*257*f); if(v>65535)v=65535; r[i]=(ushort)v; r[i+256]=(ushort)v; r[i+512]=(ushort)v; }
    bool any=false;
    for(uint n=0;n<32;n++){
      DD d=new DD(); d.cb=Marshal.SizeOf(typeof(DD));
      if(!EnumDisplayDevices(null,n,ref d,0)) break;
      if((d.StateFlags&1)==0) continue;
      IntPtr h=CreateDC(null,d.DeviceName,null,IntPtr.Zero);
      if(h!=IntPtr.Zero){ if(SetDeviceGammaRamp(h,r)) any=true; DeleteDC(h); }
    }
    return any;
  }
}
'@

# --- theme ---
if($next -eq 1){$new=1}else{$new=0}
Set-ItemProperty -Path $p -Name AppsUseLightTheme -Value $new -Type DWord
Set-ItemProperty -Path $p -Name SystemUsesLightTheme -Value $new -Type DWord
[DimG]::Notify()

# --- night light ---
$wantOn=($next -ge 2)
$k='HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\default$windows.data.bluelightreduction.bluelightreductionstate\windows.data.bluelightreduction.bluelightreductionstate'
$ok=$false
$d=[byte[]](Get-ItemProperty -LiteralPath $k -Name Data -ErrorAction SilentlyContinue).Data
if($d -and $d.Length -ge 41){
  $isOn=($d[18] -eq 0x15 -and $d[23] -eq 0x10 -and $d[24] -eq 0x00)
  $isOff=($d[18] -eq 0x13)
  if($isOn -or $isOff){
    $ok=$true
    if($isOn -ne $wantOn){
      $l=New-Object 'System.Collections.Generic.List[byte]'
      $l.AddRange($d)
      if($wantOn){$l[18]=[byte]0x15;$l.Insert(23,[byte]0x10);$l.Insert(24,[byte]0x00)}
      else{$l[18]=[byte]0x13;$l.RemoveRange(23,2)}
      for($i=10;$i -lt 15;$i++){if($l[$i] -ne 0xff){$l[$i]=[byte]($l[$i]+1);break}}
      Set-ItemProperty -LiteralPath $k -Name Data -Value ([byte[]]$l.ToArray()) -Type Binary
    }
  }
}
if(-not $ok){Start-Process 'ms-settings:nightlight'}

# --- software dimming (stage 3 only; reset on stages 1 and 2) ---
Start-Sleep -Milliseconds 1500
if($next -eq 3){ if(-not [DimG]::Set($dim3)){ [void][DimG]::Set(0.75) } }
else{ [void][DimG]::Set(1.0) }

if(-not (Test-Path $sk)){ New-Item -Path $sk -Force | Out-Null }
Set-ItemProperty -Path $sk -Name Stage -Value $next -Type DWord

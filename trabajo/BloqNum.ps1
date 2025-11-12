Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Keyboard {
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);
}
"@

# Código de tecla para NumLock
$VK_NUMLOCK = 0x90
$KEYEVENTF_EXTENDEDKEY = 0x1
$KEYEVENTF_KEYUP = 0x2

while ($true) {
    [Keyboard]::keybd_event($VK_NUMLOCK, 0, $KEYEVENTF_EXTENDEDKEY, 0)
    Start-Sleep -Milliseconds 100
    [Keyboard]::keybd_event($VK_NUMLOCK, 0, $KEYEVENTF_EXTENDEDKEY -bor $KEYEVENTF_KEYUP, 0)
    Start-Sleep -Seconds 5
}

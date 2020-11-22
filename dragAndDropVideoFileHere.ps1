# --------- Script section ---------

$script = {
    [CmdletBinding()]
    Param (
        [Parameter(Position=0)]
        [string]$Arg1,
    
        [Parameter(Position=1)]
        [string]$Arg2
    )
    
    Write-Host -ForegroundColor Yellow "inputFile: $Arg1"
    Write-Host -ForegroundColor Yellow "outputFile: $Arg2"
    Write-Host ""

    .\ffmpeg.exe -i "$Arg1" -vcodec libx264 -crf 24 "$Arg2"
    Write-Host ""
    Write-Host -ForegroundColor Green "Compression finished.`noutputFile: $Arg2"
    PAUSE;
}


# --------- Function section ---------

function Run-InNewProcess {
    param([String] $code)
    $code = "function Run{ $code }; Run $args"
    $encoded = [Convert]::ToBase64String( [Text.Encoding]::Unicode.GetBytes($code))
    
    start-process PowerShell.exe -argumentlist '-encodedCommand',$encoded
}


# ----------- Code section -----------

# Compress Drag&Dropped video files.
FOREACH ($inputFile in $args) {
    $splittedFileName = $inputFile.Split("{.}")
    $outputFile = ""
    FOREACH ($partOfFilename in $splittedFileName) {
        IF ( !($partOfFilename.equals($splittedFileName[-1])) ) {
            IF ( $outputFile.equals("") ) {
                $outputFile += $partOfFilename
            } ELSE {
                $outputFile += "." + $partOfFilename
            }
        } ELSE {
            $outputFile += "_compressed" + "." + $partOfFilename
            $fileType = $partOfFilename
        }
    }
    
    IF ($fileType.equals("mp4") -or $fileType.equals("avi")) {
        Write-Host -ForegroundColor Green @"
--------------------------------------------------------------------------------------------------------
InputFile `"$inputFile`" has a valid file type.
Compressed file will be saved here:
   `"$outputFile`"
Starting compression in an own process...
--------------------------------------------------------------------------------------------------------

"@
        cd $PSScriptRoot
        Run-InNewProcess $script -Arg1 "`"$inputFile`"" -Arg2 "`"$outputFile`""

    } ELSE {
        Write-Host -ForegroundColor Red @"
--------------------------------------------------------------------------------------------------------
The file
   `"$inputFile`",
   file type `"$fileType`",
has not a supported file type.

Only these file types are supported:
   avi
   mp4
--------------------------------------------------------------------------------------------------------

"@
    }
}

Write-Host "Script is at his end. The Window is closing itself after Enter got pressed.`n"
PAUSE
stop-process -Id $PID
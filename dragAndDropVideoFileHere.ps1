# --------- Script section ---------

$script = {
    [CmdletBinding()]
    Param (
        [Parameter(Position=0)]
        [string]$Arg1,
    
        [Parameter(Position=1)]
        [int]$Arg2,

        [Parameter(Position=2)]
        [string]$Arg3
    )

    
    Write-Host -ForegroundColor Yellow "inputFile: $Arg1"
    Write-Host -ForegroundColor Yellow "amountAudioTracks: $Arg2"
    Write-Host -ForegroundColor Yellow "outputFile: $Arg3"
    Write-Host ""
    
    [bool] $usePan = 1
    [bool] $normalizePan = 0
    $audioArgs = ""
    IF ($Arg2 -gt 0) {
        $audioFilter = ""
        $panConfig = ""
        $leftChannelPan = "c0"
        $rightChannelPan = "c1"
        IF ($normalizePan) {
            $leftChannelPan += "<"
            $rightChannelPan += "<"
        } ELSE {
            $leftChannelPan += "="
            $rightChannelPan += "="
        }

        FOR ($i = 0; $i -lt $Arg2; $i++) {
            $audioFilter += "[0:a:$i]"
            $leftChannelPan += "1*c" + ($i * 2 ) + "+" 
            $rightChannelPan += "1*c" + ($i * 2 + 1) + "+"
        }
        $audioFilter += "amerge=inputs=$Arg2"
        
        IF ($usePan) {
            $leftChannelPan = $leftChannelPan -replace ".{1}$"
            $rightChannelPan = $rightChannelPan -replace ".{1}$"
            $panConfig += "pan=stereo|$leftChannelPan|$rightChannelPan"
            $audioFilter += ",$panConfig"
        }
        
        $audioFilter += "[a]"
        $audioArgs = "-filter_complex `"$audioFilter`" -map `"[a]`""

        IF (!$usePan) {
            $audioArgs += " -ac 2"
        }
    }

    $cmd = ".\ffmpeg.exe -i `"$Arg1`" -vcodec libx264 -crf 24 $audioArgs -map `"0:v`" `"$Arg3`""
    echo "$cmd"

    Invoke-Expression $cmd

    Write-Host ""
    Write-Host -ForegroundColor Green "Compression finished.`noutputFile: $Arg3"
    PAUSE;
}


# --------- Function section ---------

function Run-InNewProcess {
    param([String] $code)
    $code = "function Run{ $code }; Run $args"
    $encoded = [Convert]::ToBase64String( [Text.Encoding]::Unicode.GetBytes($code))
    
    start-process PowerShell.exe -argumentlist '-encodedCommand',$encoded
}

function Check-If-File-Is-Supported([string]$inputFile) {
    cd $PSScriptRoot
    $ffprobeLogOutput = & .\ffprobe.exe "$inputFile" 2>&1

    $counter = 0
    $rowContainsInvalidOrMinusOne = -1
    FOREACH($ffprobeOutputItem in $ffprobeLogOutput) {
        IF ($ffprobeOutputItem -like "*Invalid*") {
            $rowContainsInvalidOrMinusOne = $counter
        }
        $counter++
    }

    return $rowContainsInvalidOrMinusOne.Equals(-1)
}

function Get-Amount-Of-Audio-Tracks([string] $file) {
    $ffprobeLogOutput = & .\ffprobe.exe "$file" 2>&1

    $counter = 0
    FOREACH($ffprobeOutputItem in $ffprobeLogOutput) {
        IF ($ffprobeOutputItem -like "*Audio*") {
            $counter++
        }
    }
    return $counter
}

# ----------- Code section -----------

$testing = 0

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

    IF ( $testing.Equals(0) ) {
    
        $fileSupported = Check-If-File-Is-Supported "$inputFile"
        IF ( $fileSupported ) {
            Write-Host -ForegroundColor Green @"
--------------------------------------------------------------------------------------------------------
InputFile `"$inputFile`" is readable.
Compressed file will be saved here:
   `"$outputFile`"
Starting compression in an own process...
--------------------------------------------------------------------------------------------------------

"@
            $amountAudioTracks = Get-Amount-Of-Audio-Tracks "$inputFile"
            cd $PSScriptRoot
            Run-InNewProcess $script -Arg1 "`"$inputFile`"" -Arg2 "`"$amountAudioTracks`"" -Arg3 "`"$outputFile`""

        } ELSE {
            Write-Host -ForegroundColor Red @"
--------------------------------------------------------------------------------------------------------
The file
   `"$inputFile`",
   file type `"$fileType`",
has not a supported file.

Only video files are supported.
--------------------------------------------------------------------------------------------------------

"@
        }
    

    } ELSE {
        
        $fileSupported = Check-If-File-Is-Supported "$inputFile"
        IF ( $fileSupported ) {
            Write-Host -ForegroundColor Green "File is somehow supported: $inputFile"
        } ELSE {
            Write-Host -ForegroundColor Red "File is not supported: $inputFile"
        }

        Write-Host "`n`n`n"
    }
}
Write-Host "`n`n`n"
Write-Host "Script is at his end. The Window is closing itself after Enter got pressed.`n"
PAUSE
stop-process -Id $PID

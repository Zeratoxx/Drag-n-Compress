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
        START powershell {cd $PSScriptRoot; .\ffmpeg.exe -i $inputFile -vcodec libx264 -crf 24 $outputFile; PAUSE}

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
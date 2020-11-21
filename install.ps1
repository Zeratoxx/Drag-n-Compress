# --------- Function section ---------

function Request-User-Input() {
    Write-Host -ForegroundColor Red @"
Did you finish all file usages? (y/n)

"@ -NoNewline

    $choice = Read-Host
    Write-Host ""
    
    IF ($choice.Equals("n")) {
        Write-Host -ForegroundColor Yellow "Press Enter to abort...`n"
        PAUSE
        stop-process -Id $PID
    
    } ELSE {
        IF ($choice.Equals("y")) {
            Write-Host -ForegroundColor Yellow "Let's go...`n"
        
        } ELSE {
            Write-Host -ForegroundColor Yellow "Invalid input.`n"
            Request-User-Input
        }
    }
}


# ----------- Code section -----------

Write-Host -ForegroundColor Yellow @"

--------------------------------------------------------------------------------------------------------

This installation needs to restart explorer.exe and so it will.

"@
Write-Host -ForegroundColor DarkRed -BackgroundColor White @"

----------------------------------------------------------------------------------------------
                                                                                              
 !! PLEASE MAKE SURE THAT NO FILES ARE BEING COPIED OR USED IN A SIMILAR WAY AT THE MOMENT !! 
                                                                                              
----------------------------------------------------------------------------------------------



"@

Request-User-Input
PAUSE

.\scriptForInstallation.ps1
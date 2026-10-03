@echo off
setlocal enabledelayedexpansion
title Nova_Notes Suite v2.0
color 8B

set "LOCAL_DIR=.\Notes_Archive"
if not exist "%LOCAL_DIR%" mkdir "%LOCAL_DIR%"

:CONNECTION_MODE
powershell -Command " +^
$choices = @('Work Offline (Local Storage Mode)', 'Connect to Remote Online Server'); +^
$selection = 0; +^
while ($true) { +^
    Clear-Host; +^
    Write-Host '  +---------------------------------------+' -ForegroundColor Cyan; +^
    Write-Host '  |        NOVASYNC CONNECTION CORE       |' -ForegroundColor Cyan; +^
    Write-Host '  +---------------------------------------+' -ForegroundColor Cyan; +^
    Write-Host ''; +^
    for ($i=0; $i -lt $choices.Count; $i++) { +^
        if ($i -eq $selection) { +^
            Write-Host ('   -> [ ' + $choices[$i] + ' ] ') -ForegroundColor Black -BackgroundColor Cyan; +^
        } else { +^
            Write-Host ('        ' + $choices[$i]); +^
        } +^
    }; +^
    Write-Host ''; +^
    Write-Host '  +---------------------------------------+' -ForegroundColor Gray; +^
    $key = [System.Console]::ReadKey($true).Key; +^
    if ($key -eq 'UpArrow') { $selection = ($selection -1 + $choices.Count) %% $choices.Count }; +^
    if ($key -eq 'DownArrow') { $selection = ($selection + 1) %% $choices.Count }; +^
    if ($key -eq 'Enter') { exit $selection }; +^
}"
set "mode_val=%errorlevel%"

if "%mode_val%"=="0" (
    set "NET_MODE=OFFLINE"
    goto MAIN_MENU
)

cls
echo  +---------------------------------------+
echo  ^|         CONNECT TO ONLINE SERVER      ^|
echo  +---------------------------------------+
echo.
set /p "SERVER_IP=  Enter Server IP / URL (e.g. http://127.0.0.1:3000): "
if "%SERVER_IP%"=="" goto CONNECTION_MODE
set "NET_MODE=ONLINE"

:MAIN_MENU
powershell -Command " +^
$choices = @('Create New Note', 'Read Saved Notes', 'Search Keywords', 'Delete All Notes', 'Disconnect / Exit'); +^
$selection = 0; +^
while ($true) { +^
    Clear-Host; +^
    Write-Host '  +---------------------------------------+' -ForegroundColor Cyan; +^
    Write-Host ('  |        NOVA_NOTES (Mode: ' + '%NET_MODE%'.PadRight(10) + ')   |') -ForegroundColor Cyan; +^
    Write-Host '  +---------------------------------------+' -ForegroundColor Cyan; +^
    Write-Host ''; +^
    for ($i=0; $i -lt $choices.Count; $i++) { +^
        if ($i -eq $selection) { +^
            Write-Host ('   -> [ ' + $choices[$i] + ' ] ') -ForegroundColor Black -BackgroundColor Cyan; +^
        } else { +^
            Write-Host ('        ' + $choices[$i]); +^
        } +^
    }; +^
    Write-Host ''; +^
    Write-Host '  +---------------------------------------+' -ForegroundColor Gray; +^
    Write-Host '   Made with ❤️ by Nova Studios.' -ForegroundColor White; +^
    Write-Host '  +---------------------------------------+' -ForegroundColor Gray; +^
    $key = [System.Console]::ReadKey($true).Key; +^
    if ($key -eq 'UpArrow') { $selection = ($selection -1 + $choices.Count) %% $choices.Count }; +^
    if ($key -eq 'DownArrow') { $selection = ($selection + 1) %% $choices.Count }; +^
    if ($key -eq 'Enter') { exit $selection }; +^
}"
set "action_val=%errorlevel%"

if "%action_val%"=="0" goto CREATE_NOTE
if "%action_val%"=="1" goto BROWSE_NOTES
if "%action_val%"=="2" goto SEARCH_NOTES
if "%action_val%"=="3" goto WIPE_ALL
if "%action_val%"=="4" goto CONNECTION_MODE

:CREATE_NOTE
cls
echo  +---------------------------------------+
echo  ^|            CREATE NEW NOTE            ^|
echo  +---------------------------------------+
echo.
set /p "title=  Enter Note Title: "
if "%title%"=="" goto MAIN_MENU
set "filename=%title: =_%"

echo.
set /p "content=  Note Text > "

if "%NET_MODE%"=="ONLINE" (
    powershell -Command "Invoke-RestMethod -Uri '%SERVER_IP%/api/save' -Method Post -Body (ConvertFrom-Json '{\"filename\":\"%filename%\",\"title\":\"%title%\",\"content\":\"%content%\",\"date\":\"%date%\"}' | ConvertTo-Json) -ContentType 'application/json'" >nul
) else (
    (
    echo =========================================
    echo  TITLE: %title%
    echo  DATE:  %date% @ %time%
    echo =========================================
    echo %content%
    echo =========================================
    echo  Made with ❤️ by Nova Studios.
    echo =========================================
    ) > "%LOCAL_DIR%\%filename%.txt"
)
echo.
echo   [^+] Note saved successfully!
pause
goto MAIN_MENU

:BROWSE_NOTES
cls
echo  +---------------------------------------+
echo  ^|           READ SAVED NOTES            ^|
echo  +---------------------------------------+
echo.
if "%NET_MODE%"=="ONLINE" (
    powershell -Command "$res = Invoke-RestMethod -Uri '%SERVER_IP%/api/notes'; if ($res) { $res | ForEach-Object { Write-Host '   [*] '$_ } } else { Write-Host '   [No notes found on server.]' }"
) else (
    set "count=0"
    for %%f in ("%LOCAL_DIR%\*.txt") do (set "fname=%%~nf" & set "fname=!fname:_= !" & echo    [*] !fname! & set /a count+=1)
)
echo.
set /p "read_target=  Type exact note name to open: "
if "%read_target%"=="" goto MAIN_MENU
set "read_file=%read_target: =_%"

cls
echo.
if "%NET_MODE%"=="ONLINE" (
    powershell -Command "Invoke-RestMethod -Uri '%SERVER_IP%/api/read' -Method Post -Body (ConvertFrom-Json '{\"filename\":\"%read_file%\"}' | ConvertTo-Json) -ContentType 'application/json'"
) else (
    if not exist "%LOCAL_DIR%\%read_file%.txt" (echo [X] Note not found. & pause & goto BROWSE_NOTES)
    type "%LOCAL_DIR%\%read_file%.txt"
)
echo.
pause
goto MAIN_MENU

:SEARCH_NOTES
cls
if "%NET_MODE%"=="ONLINE" (echo  [!] Online global keywords lookup is managed via backend repository index dashboards. & pause & goto MAIN_MENU)
echo  +---------------------------------------+
echo  ^|            SEARCH KEYWORDS            ^|
echo  +---------------------------------------+
set /p "keyword=  Enter word to find: "
findstr /i /m "%keyword%" "%LOCAL_DIR%\*.txt" >nul 2>&1
for /f "delims=" %%g in ('findstr /i /m "%keyword%" "%LOCAL_DIR%\*.txt"') do (set "matched_file=%%~ng" & echo    [^+] MATCH: !matched_file:_= !)
pause
goto MAIN_MENU

:WIPE_ALL
cls
set /p "confirm=  ⚠️ Delete ALL notes? (Y/N): "
if /i "%confirm%"=="Y" (
    if "%NET_MODE%"=="ONLINE" (powershell -Command "Invoke-RestMethod -Uri '%SERVER_IP%/api/wipe' -Method Post" >nul) else (del /f /q "%LOCAL_DIR%\*.txt" >nul 2>&1)
    echo   [^+] Clear completed.
    pause
)
goto MAIN_MENU


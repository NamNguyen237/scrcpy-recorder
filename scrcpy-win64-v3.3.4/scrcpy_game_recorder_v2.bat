@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"
set "SAVE_DIR=D:\RAW_Recorded"

title Scrcpy_Native_Flat_v9.1
cls

echo ======================================================
echo SCRCPY v3.3+ NATIVE VIRTUAL DISPLAY 
echo Moi App chay tren 1 man hinh doc lap, khong ghi de!
echo ======================================================
echo LUA CHON DO PHAN GIAI (16:9):
echo [1] 4K  ^|  [2] 2K  ^|  [3] 1080p  ^|  [4] 720p
set /p "res_choice=Chon muc (1-4): "

:: --- Gán độ phân giải bằng Flat Logic ---
set "new_res=1920x1080/320"
set "v_br=20M"

if "%res_choice%"=="1" goto :res_4k
if "%res_choice%"=="2" goto :res_2k
if "%res_choice%"=="3" goto :res_1080p
if "%res_choice%"=="4" goto :res_720p
goto :res_done

:res_4k
set "new_res=3840x2160/480"
set "v_br=45M"
goto :res_done

:res_2k
set "new_res=2560x1440/420"
set "v_br=30M"
goto :res_done

:res_1080p
set "new_res=1920x1080/320"
set "v_br=20M"
goto :res_done

:res_720p
set "new_res=1280x720/240"
set "v_br=15M"
goto :res_done

:res_done

:: --- BƯỚC 2: CHỌN APP ---
echo ------------------------------------------------------
adb.exe shell pm list packages -3 | findstr /v "Shell" > "%temp%\apps_v91.txt"
set "count=0"
for /f "tokens=2 delims=:" %%p in (%temp%\apps_v91.txt) do (
    set /a count+=1
    set "pkg!count!=%%p"
    echo  [!count!] %%p
)
echo ------------------------------------------------------
set /p "choice=Nhap STT App: "
set "target_pkg="
for /f "tokens=2 delims==" %%v in ('set pkg%choice% 2^>nul') do set "target_pkg=%%v"

:: --- BƯỚC 3: BOOLEAN DESKTOP (Fix lỗi ngoặc bằng Goto) ---
set /p "is_dex=Su dung Desktop Mode? (y/n): "
if /i "%is_dex%"=="y" goto :dex_on
goto :dex_off

:dex_on
echo [*] Kich hoat Desktop Mode...
adb.exe shell settings put global force_desktop_mode_on_external_displays 1
goto :dex_done

:dex_off
echo [*] Tat Desktop Mode ^(Che do Fullscreen Game^)...
adb.exe shell settings put global force_desktop_mode_on_external_displays 0
goto :dex_done

:dex_done
:: Doi 1 giay de Android ap dung setting vao he thong
timeout /t 1 >nul

:: --- BƯỚC 4: LỰA CHỌN XEM/QUAY ---
echo ------------------------------------------------------
echo [1] Chi xem  ^|  [2] Quay phim
set /p "mode=Lua chon (1/2): "

:: --- LENH SCRCPY NATIVE ---
set "CMD_ARGS=--new-display=%new_res% --start-app=+%target_pkg% --video-buffer=0 --video-bit-rate %v_br% --turn-screen-off --stay-awake"

if "%mode%"=="2" goto :run_record
goto :run_view

:run_record
if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "dt=%%I"
set "fname=%SAVE_DIR%\%target_pkg%_!dt:~0,12!.mkv"
echo [*] Dang khoi tao Scrcpy NATIVE...
start "Scrcpy_%target_pkg%" scrcpy.exe %CMD_ARGS% --record "%fname%" --window-title "Rec_%target_pkg%"
goto :end_script

:run_view
echo [*] Dang khoi tao Scrcpy NATIVE...
start "Scrcpy_%target_pkg%" scrcpy.exe %CMD_ARGS% --window-title "View_%target_pkg%"
goto :end_script

:end_script
echo ------------------------------------------------------
echo [V] DA XONG! KHI TAT SCRCPY, MAN HINH AO SE TU HUY.
:: Don dep not rac cua cac ban script cu cho sach may
adb.exe shell settings put global overlay_display_devices "none" >nul 2>&1
pause >nul
popd
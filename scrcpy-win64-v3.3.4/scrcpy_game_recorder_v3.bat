@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"
set "SAVE_DIR=D:\RAW_Recorded"

title Scrcpy_Orientation_v9.4
cls

echo ======================================================
echo SCRCPY v3.3+ NATIVE VIRTUAL DISPLAY
echo ======================================================
echo CHON DO PHAN GIAI:
echo [1] 4K  ^|  [2] 2K  ^|  [3] 1080p  ^|  [4] 720p
set /p "res_choice=Chon muc (1-4): "

:: --- Thiết lập thông số gốc (Ngang) ---
set "base_w=1920" & set "base_h=1080" & set "base_dpi=320" & set "v_br=20M"
if "%res_choice%"=="1" (set "base_w=3840" & set "base_h=2160" & set "base_dpi=480" & set "v_br=45M")
if "%res_choice%"=="2" (set "base_w=2560" & set "base_h=1440" & set "base_dpi=420" & set "v_br=30M")
if "%res_choice%"=="3" (set "base_w=1920" & set "base_h=1080" & set "base_dpi=320" & set "v_br=20M")
if "%res_choice%"=="4" (set "base_w=1280" & set "base_h=720"  & set "base_dpi=240" & set "v_br=15M")

:: --- BƯỚC MỚI: CHỌN HƯỚNG MÀN HÌNH ---
echo ------------------------------------------------------
echo CHON HUONG MAN HINH:
echo [1] Ngang (Landscape - Game, Video)
echo [2] Doc   (Portrait  - FB, TikTok, App)
set /p "ori_choice=Nhap lua chon (1/2): "

if "%ori_choice%"=="2" (
    :: Dao nguoc W va H cho man hinh doc
    set "new_res=!base_h!x!base_w!/!base_dpi!"
    echo [*] Da thiet lap che do: MAN DOC (!base_h!x!base_w!)
) else (
    set "new_res=!base_w!x!base_h!/!base_dpi!"
    echo [*] Da thiet lap che do: MAN NGANG (!base_w!x!base_h!)
)

:app_search
echo ------------------------------------------------------
set "search_term="
set /p "search_term=Nhap tu khoa tim App: "
echo Dang loc danh sach App...

adb.exe shell pm list packages -3 | findstr /i "%search_term%" > "%temp%\apps_list.txt"

set "count=0"
echo ------------------------------------------------------
echo DANH SACH APP TIM THAY:
for /f "usebackq tokens=2 delims=:" %%p in ("%temp%\apps_list.txt") do (
    set /a count+=1
    set "pkg!count!=%%p"
    echo  [!count!] %%p
)

if %count%==0 (
    echo [!] Khong tim thay App.
    goto :app_search
)

echo ------------------------------------------------------
set /p "choice=Nhap STT App: "
set "target_pkg="
for /f "tokens=2 delims==" %%v in ('set pkg%choice% 2^>nul') do set "target_pkg=%%v"

if "%target_pkg%"=="" goto :app_search

:: --- BƯỚC 3: BOOLEAN DESKTOP ---
set /p "is_dex=Su dung Desktop Mode? (y/n): "
if /i "%is_dex%"=="y" (
    adb.exe shell settings put global force_desktop_mode_on_external_displays 1
) else (
    adb.exe shell settings put global force_desktop_mode_on_external_displays 0
)
timeout /t 1 >nul

:: --- BƯỚC 4: LỰA CHỌN XEM/QUAY ---
echo ------------------------------------------------------
echo [1] Chi xem  ^|  [2] Quay phim
set /p "mode=Lua chon (1/2): "

:: --- LENH SCRCPY NATIVE ---
echo ------------------------------------------------------
echo [1] Keyboard Ao  ^|  [2] Keyboard That
set /p "keyboard=Lua chon (1/2): "
if "%keyboard%"=="2" goto :real_keyboard
goto :virt_keyboard

:real_keyboard
set "CMD_ARGS=--new-display=%new_res% --start-app=+%target_pkg% --video-buffer=0 --video-bit-rate %v_br% --turn-screen-off --stay-awake --keyboard=uhid"
if "%mode%"=="2" goto :run_record
goto :run_view

:virt_keyboard
set "CMD_ARGS=--new-display=%new_res% --start-app=+%target_pkg% --video-buffer=0 --video-bit-rate %v_br% --turn-screen-off --stay-awake"
if "%mode%"=="2" goto :run_record
goto :run_view

:run_record
if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "dt=%%I"
set "fname=%SAVE_DIR%\%target_pkg%_!dt:~0,12!.mkv"
start "Scrcpy_%target_pkg%" scrcpy.exe %CMD_ARGS% --record "%fname%" --window-title "Rec_%target_pkg%"
goto :end_script

:run_view
start "Scrcpy_%target_pkg%" scrcpy.exe %CMD_ARGS% --window-title "View_%target_pkg%"
goto :end_script

:end_script
echo ------------------------------------------------------
echo [V] DA MO CUA SO. Bam phim bat ky de tim App tiep theo...
adb.exe shell settings put global overlay_display_devices "none" >nul 2>&1
pause >nul
goto :app_search
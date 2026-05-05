@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"
set "SAVE_DIR=D:\RAW_Recorded"

title iQOO_Ultimate_Workstation_v11.6
cls

echo ======================================================
echo    SCRCPY NATIVE VIRTUAL DISPLAY + FPS GAMING
echo ======================================================

:: --- Thiết lập thông số gốc ---
echo [1] 4K  ^|  [2] 2K  ^|  [3] 1080p  ^|  [4] 720p
set /p "res_choice=Chon muc (1-4): "

:: Fix loi nhan dien bang cach dung dau ngoac kep trong so sanh
set "base_w=1920" & set "base_h=1080" & set "base_dpi=320" & set "v_br=20M"
if "%res_choice%"=="1" (set "base_w=3840" & set "base_h=2160" & set "base_dpi=480" & set "v_br=45M")
if "%res_choice%"=="2" (set "base_w=2560" & set "base_h=1440" & set "base_dpi=420" & set "v_br=30M")
if "%res_choice%"=="3" (set "base_w=1920" & set "base_h=1080" & set "base_dpi=320" & set "v_br=20M")
if "%res_choice%"=="4" (set "base_w=1280" & set "base_h=720"  & set "base_dpi=240" & set "v_br=15M")

:: --- CHỌN HƯỚNG MÀN HÌNH ---
echo ------------------------------------------------------
echo CHON HUONG MAN HINH:
echo [1] Ngang (Landscape - Game, Video)
echo [2] Doc    (Portrait  - FB, TikTok, App)
set /p "ori_choice=Nhap lua chon (1/2): "

if "%ori_choice%"=="2" (
    set "new_res=!base_h!x!base_w!/!base_dpi!"
    echo [*] Da thiet lap che do: MAN DOC (!base_h!x!base_w!)
) else (
    set "new_res=!base_w!x!base_h!/!base_dpi!"
    echo [*] Da thiet lap che do: MAN NGANG (!base_w!x!base_h!)
)

:app_search
echo ------------------------------------------------------
set "search_term="
set /p "search_term=Nhap tu khoa tim App (Enter de xem het): "
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

:: --- CẤU HÌNH GAMING (FIX LỖI NHẬN DIỆN) ---
echo ------------------------------------------------------
echo [1] Che do VAN PHONG (Chuot binh thuong)
echo [2] Che do GAMING FPS (Khoa chuot quay Camera)
set /p "game_mode=Lua chon (1/2): "

:: Khoi tao bien G_ARGS de tranh loi khi goi scrcpy
if "%game_mode%"=="2" (
    set "G_ARGS=--keyboard=uhid --mouse=uhid --shortcut-mod=lalt"
) else (
    set "G_ARGS=--keyboard=sdk --mouse=sdk"
)

set /p "is_dex=Su dung Desktop Mode? (y/n): "
if /i "%is_dex%"=="y" (
    adb.exe shell settings put global force_desktop_mode_on_external_displays 1
    adb.exe shell settings put global enable_freeform_support 1
) else (
    adb.exe shell settings put global force_desktop_mode_on_external_displays 0
)

:: --- CHỌN XEM/QUAY ---
echo ------------------------------------------------------
echo [1] Chi xem  ^|  [2] Quay phim (MKV)
set /p "mode=Lua chon (1/2): "

:: --- KHOI CHAY SCRCPY ---
:: Dung bien COMMON_ARGS de cau lenh gon gach, tranh loi ki tu la
set "COMMON_ARGS=--new-display=%new_res% --start-app=+%target_pkg% --video-bit-rate %v_br% --video-buffer=0 --stay-awake --audio-source=output --turn-screen-off !G_ARGS!"

if "%mode%"=="2" (
    if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"
    for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "dt=%%I"
    set "fname=%SAVE_DIR%\%target_pkg%_!dt:~0,12!.mkv"
    start "Scrcpy_Rec" scrcpy.exe %COMMON_ARGS% --record "!fname!" --window-title "REC: %target_pkg%"
) else (
    start "Scrcpy_View" scrcpy.exe %COMMON_ARGS% --window-title "VIEW: %target_pkg%"
)

echo ------------------------------------------------------
if "%game_mode%"=="2" echo
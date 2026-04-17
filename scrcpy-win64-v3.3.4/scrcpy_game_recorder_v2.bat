@echo off
setlocal enabledelayedexpansion

set "ADB=%~dp0adb.exe"
set "SCRCPY=%~dp0scrcpy.exe"

title Scrcpy_Auto_VirtualDisplay_v6.0
cls

:: --- BƯỚC 0: KÍCH HOẠT CHẾ ĐỘ DESKTOP ẨN (Giúp màn ảo không bị đen) ---
echo [*] Dang toi uu he thong đa man hinh...
"%ADB%" shell settings put global force_desktop_mode_on_external_displays 1

:: --- BƯỚC 1: TẠO MÀN HÌNH ẢO MỚI ---
echo ======================================================
set /p "create_new=Tao man hinh ao moi? (y/n): "

if /i "%create_new%"=="y" (
    :: Tạo màn hình mới và lấy ID ngay lập tức
    echo [*] Dang tao Virtual Display 4K Native...
    
    :: Chạy scrcpy ở chế độ chờ (no-playback) để khởi tạo Display
    start "V-Display-Daemon" /min "%SCRCPY%" --new-display=3840x2160/480 --no-audio --no-control --no-playback
    
    echo [*] Doi he thong cap ID...
    timeout /t 4 >nul

    :: Dò ID mới nhất (ID cao nhất thường là cái vừa tạo)
    for /f "tokens=2 delims==" %%i in ('"%ADB%" shell dumpsys display ^| findstr "mDisplayId="') do (
        set "display_id=%%i"
    )
    echo [v] Display ID moi: !display_id!
) else (
    set "display_id=0"
    echo [*] Su dung man hinh chinh (ID 0).
)

:: --- BƯỚC 2: CHỌN APP (Dò tự động) ---
echo ------------------------------------------------------
echo Chon Game muon day sang Display !display_id!:
set "count=0"
for /f "tokens=2 delims=:" %%p in ('"%ADB%" shell pm list packages -3') do (
    set /a count+=1
    set "pkg!count!=%%p"
    echo  [!count!] %%p
)
set /p "choice=Nhap so: "
set "target_pkg=!pkg%choice%!"

:: --- BƯỚC 3: MỞ GAME VÀ XUẤT MÀN HÌNH ---
echo [*] Dang day !target_pkg! sang man hinh !display_id!...
:: Lệnh mở game trực tiếp vào display chỉ định
"%ADB%" shell monkey -p !target_pkg! --display !display_id! 1 >nul 2>&1

echo ------------------------------------------------------
echo [1] Chi xem (View Mode)
echo [2] Quay phim (Record Mode)
set /p "mode=Lua chon: "

if "%mode%"=="2" (
    for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "dt=%%I"
    set "fname=D:\RAW_Recorded\NIKKE_!dt:~0,12!.mkv"
    "%SCRCPY%" --display-id !display_id! --video-bit-rate 45M --video-codec=h265 --record "!fname!"
) else (
    "%SCRCPY%" --display-id !display_id! --window-title "Game_Virtual_Display"
)

pause
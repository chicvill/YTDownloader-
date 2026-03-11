@echo off
setlocal
chcp 65001 > nul
cd /d "%~dp0"

echo ******************************************
echo * YouTube Downloader v2.0 (CLEAN RESET)  *
echo ******************************************
echo 주소: http://localhost:5000

:: yt-dlp 강제 업데이트
echo [1/2] 도구 업데이트 확인 중...
py -m pip install -U yt-dlp > nul

:: 서버 실행
echo [2/2] 서버를 시작합니다...
py app.py

if %ERRORLEVEL% neq 0 (
    echo.
    echo 서버 실행 중 문제가 발생했습니다. 파이썬 환경을 확인해 보세요.
    pause
)
endlocal

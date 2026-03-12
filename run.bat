@echo off
setlocal
chcp 65001 > nul
cd /d "%~dp0"

:: cloudflared 경로 설정
set "CLOUDFLARED=%LOCALAPPDATA%\Microsoft\WinGet\Packages\Cloudflare.cloudflared_Microsoft.Winget.Source_8wekyb3d8bbwe\cloudflared.exe"

echo ******************************************
echo * YouTube Downloader v2.0                *
echo * Server + Cloudflare Tunnel             *
echo ******************************************
echo.

:: yt-dlp 강제 업데이트
echo [1/3] 도구 업데이트 확인 중...
py -m pip install -U yt-dlp > nul 2>&1

:: Cloudflare Tunnel 시작 (백그라운드)
echo [2/3] Cloudflare Tunnel 연결 중...
if exist "%CLOUDFLARED%" (
    del /q tunnel.log > nul 2>&1
    start "" /B "%CLOUDFLARED%" tunnel --url http://localhost:5000 > tunnel.log 2>&1
    
    :: 터널 URL이 나올 때까지 대기 (최대 15초)
    set TUNNEL_URL=
    for /L %%i in (1,1,15) do (
        timeout /t 1 /nobreak > nul
        for /f "tokens=*" %%a in ('findstr /C:"trycloudflare.com" tunnel.log 2^>nul') do (
            for /f "tokens=*" %%u in ('powershell -Command "(Select-String -Path tunnel.log -Pattern 'https://[^ ]*trycloudflare.com' | Select-Object -First 1).Matches.Value"') do (
                set "TUNNEL_URL=%%u"
            )
        )
        if defined TUNNEL_URL goto :found
    )

    echo [경고] 터널 URL을 자동으로 가져오지 못했습니다.
    echo        tunnel.log 파일을 확인해 보세요.
    goto :start_server

    :found
    echo.
    echo ******************************************
    echo *  외부 접속 주소 (공유용):              *
    echo *  %TUNNEL_URL%
    echo ******************************************
    echo.
) else (
    echo [경고] cloudflared를 찾을 수 없습니다.
    echo        로컬 전용 모드로 실행합니다.
    echo        설치: winget install cloudflare.cloudflared
    echo.
)

:start_server
:: 서버 실행
echo [3/3] 서버를 시작합니다...
echo 로컬 주소: http://localhost:5000
echo.
py app.py

if %ERRORLEVEL% neq 0 (
    echo.
    echo 서버 실행 중 문제가 발생했습니다.
    pause
)

:: 종료 시 터널도 함께 종료
taskkill /f /im cloudflared.exe > nul 2>&1
endlocal

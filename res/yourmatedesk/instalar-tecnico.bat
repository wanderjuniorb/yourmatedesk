@echo off
REM ============================================================
REM  YourMateDesk - instalacao no computador do TECNICO
REM  (conecta nos clientes e tambem pode receber conexoes)
REM  Basta dar dois cliques. Coloque este arquivo na mesma pasta
REM  do YourMateDesk-*-x64.exe
REM  Opcional pela linha de comando: instalar-tecnico.bat SENHA
REM ============================================================
setlocal

REM --- Pede permissao de administrador automaticamente ---
net session >nul 2>&1
if errorlevel 1 (
  echo Pedindo permissao de administrador...
  if "%~1"=="" (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -WorkingDirectory '%~dp0' -Verb RunAs"
  ) else (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%~1' -WorkingDirectory '%~dp0' -Verb RunAs"
  )
  exit /b
)

cd /d "%~dp0"
set "PASTA=%ProgramFiles%\YourMateDesk"
set "APP=%PASTA%\YourMateDesk.exe"
set "SENHA=%~1"

echo ============================================
echo   YourMateDesk - instalacao (modo TECNICO)
echo ============================================
echo.

set "INSTALADOR="
for %%F in ("%~dp0YourMateDesk-*-x64.exe") do set "INSTALADOR=%%~fF"
if not defined INSTALADOR (
  echo [ERRO] Nao encontrei o YourMateDesk-1.5.1-x64.exe nesta pasta:
  echo        %~dp0
  echo Coloque o instalador junto com este arquivo e tente de novo.
  goto fim
)

if not defined SENHA (
  echo Senha para acessar ESTE computador de outro lugar.
  echo Deixe em branco e aperte Enter se nao precisar.
  set /p "SENHA=Senha: "
)

echo.
echo Instalando, aguarde cerca de 30 segundos...
start "" /wait "%INSTALADOR%" --silent-install
timeout /t 20 /nobreak >nul

if not exist "%APP%" if exist "%PASTA%\rustdesk.exe" (
  copy /Y "%PASTA%\rustdesk.exe" "%APP%" >nul
)

if not exist "%APP%" (
  echo [ERRO] A instalacao nao terminou: nao encontrei "%APP%".
  echo Espere um pouco e rode este arquivo de novo.
  goto fim
)

echo Ativando o modo Tecnico...
>"%PASTA%\ymd-mode.txt" echo tech
sc stop YourMateDesk >nul 2>&1
timeout /t 3 /nobreak >nul
taskkill /f /im YourMateDesk.exe >nul 2>&1
taskkill /f /im rustdesk.exe >nul 2>&1
sc start YourMateDesk >nul 2>&1
timeout /t 3 /nobreak >nul

if defined SENHA (
  echo Definindo a senha...
  "%APP%" --password "%SENHA%"
)

echo.
echo ===== ID deste computador =====
"%APP%" --get-id
echo.
echo ===============================
echo Pronto! Abra o YourMateDesk pelo atalho da Area de Trabalho.

:fim
echo.
pause

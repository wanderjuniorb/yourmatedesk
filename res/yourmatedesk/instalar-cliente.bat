@echo off
REM ============================================================
REM  YourMateDesk - instalacao no computador do CLIENTE
REM  (so recebe conexoes)
REM  Basta dar dois cliques. Coloque este arquivo na mesma pasta
REM  do YourMateDesk-*-x64.exe
REM  A senha de acesso e definida depois, no proprio programa
REM  (botao "Definir senha" na tela principal).
REM ============================================================
setlocal

REM --- Pede permissao de administrador automaticamente ---
net session >nul 2>&1
if errorlevel 1 (
  echo Pedindo permissao de administrador...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -WorkingDirectory '%~dp0' -Verb RunAs"
  exit /b
)

cd /d "%~dp0"
set "PASTA=%ProgramFiles%\YourMateDesk"
set "APP=%PASTA%\YourMateDesk.exe"

echo ============================================
echo   YourMateDesk - instalacao (modo CLIENTE)
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


echo.
echo Instalando, aguarde cerca de 30 segundos...
start "" /wait "%INSTALADOR%" --silent-install
timeout /t 20 /nobreak >nul

if not exist "%APP%" if exist "%PASTA%\rustdesk.exe" (
  copy /Y "%PASTA%\rustdesk.exe" "%APP%" >nul
  sc start YourMateDesk >nul 2>&1
  timeout /t 3 /nobreak >nul
)

if not exist "%APP%" (
  echo [ERRO] A instalacao nao terminou: nao encontrei "%APP%".
  echo Espere um pouco e rode este arquivo de novo.
  goto fim
)

echo.
echo ===== ID deste computador =====
"%APP%" --get-id
echo.
echo ===============================
echo Agora abra o YourMateDesk, clique em "Definir senha" e escolha
echo a senha deste cliente. Anote o ID, o nome do cliente e a senha.

:fim
echo.
pause

@echo off
REM ============================================================
REM  YourMateDesk - instalacao no computador do CLIENTE
REM  (so recebe conexoes)
REM  Basta dar dois cliques. Coloque este arquivo na mesma pasta
REM  do YourMateDesk-*-x64.exe
REM  Opcional pela linha de comando: instalar-cliente.bat SENHA
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

:pede_senha
if not defined SENHA (
  echo Defina a senha de acesso deste computador.
  echo Use uma senha forte e diferente para cada cliente.
  set /p "SENHA=Senha: "
  goto pede_senha
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

echo Definindo a senha...
"%APP%" --password "%SENHA%"

echo.
echo ===== ID deste computador =====
"%APP%" --get-id
echo.
echo ===============================
echo Anote o ID acima junto com o nome do cliente e a senha.

:fim
echo.
pause

@echo off
REM ============================================================
REM  YourMateDesk - instalacao no computador do cliente
REM  Uso (como Administrador):
REM     instalar-cliente.bat SENHA_DO_CLIENTE
REM  Coloque este arquivo na mesma pasta do YourMateDesk-*-x64.exe
REM ============================================================
setlocal
if "%~1"=="" (
  echo Informe a senha de acesso. Ex.: instalar-cliente.bat MinhaSenhaForte123
  exit /b 1
)
set "SENHA=%~1"
set "PASTA=%ProgramFiles%\YourMateDesk"
set "APP=%PASTA%\YourMateDesk.exe"

for %%F in ("%~dp0YourMateDesk-*-x64.exe") do set "INSTALADOR=%%~fF"
if not defined INSTALADOR (
  echo Instalador YourMateDesk-*-x64.exe nao encontrado nesta pasta.
  exit /b 1
)

echo Instalando o YourMateDesk...
start "" /wait "%INSTALADOR%" --silent-install
timeout /t 20 /nobreak >nul

if not exist "%APP%" if exist "%PASTA%\rustdesk.exe" (
  REM Versao com o executavel ainda chamado rustdesk.exe: cria a copia com o nome certo.
  copy /Y "%PASTA%\rustdesk.exe" "%APP%" >nul
  sc start YourMateDesk >nul 2>&1
)

if not exist "%APP%" (
  echo Nao encontrei "%APP%". Verifique se a instalacao terminou e rode de novo.
  exit /b 1
)

echo Definindo a senha de acesso...
"%APP%" --password "%SENHA%"

echo.
echo ===== ID deste computador =====
"%APP%" --get-id
echo ===============================
echo Anote o ID acima junto com o nome do cliente.
pause

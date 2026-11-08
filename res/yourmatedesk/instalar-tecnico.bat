@echo off
REM ============================================================
REM  YourMateDesk - instalacao no computador do TECNICO
REM  (conecta nos clientes e tambem pode receber conexoes)
REM  Uso (como Administrador):
REM     instalar-tecnico.bat [SENHA]
REM  A senha e opcional: so e necessaria se voce quiser acessar
REM  este computador de outro lugar.
REM  Coloque este arquivo na mesma pasta do YourMateDesk-*-x64.exe
REM ============================================================
setlocal
set "PASTA=%ProgramFiles%\YourMateDesk"
set "APP=%PASTA%\YourMateDesk.exe"

net session >nul 2>&1
if errorlevel 1 (
  echo Abra o Prompt de Comando como Administrador e rode de novo.
  exit /b 1
)

for %%F in ("%~dp0YourMateDesk-*-x64.exe") do set "INSTALADOR=%%~fF"
if not defined INSTALADOR (
  echo Instalador YourMateDesk-*-x64.exe nao encontrado nesta pasta.
  exit /b 1
)

echo Instalando o YourMateDesk (modo Tecnico)...
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

echo Ativando o modo Tecnico...
>"%PASTA%\ymd-mode.txt" echo tech
sc stop YourMateDesk >nul 2>&1
timeout /t 3 /nobreak >nul
taskkill /f /im YourMateDesk.exe >nul 2>&1
sc start YourMateDesk >nul 2>&1

if not "%~1"=="" (
  echo Definindo a senha de acesso deste computador...
  "%APP%" --password "%~1"
)

echo.
echo ===== ID deste computador =====
"%APP%" --get-id
echo ===============================
echo Pronto. Abra o YourMateDesk pelo atalho da Area de Trabalho.
pause

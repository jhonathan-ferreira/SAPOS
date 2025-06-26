@echo off
title S.A.P.O.S. -jhonathan.ferreira
mode 76, 34

::=========================================================================================================================
::ANSI
for /f %%a in ('echo prompt $E^| cmd') do set "cor=%%a"
set "branco=[97m"
set "verde=[32m"
set "vermelho=[31m"
set "amarelo=[33m"
set "azul=[34m"
set "verde_=[92m"
set "vermelho_=[91m"
set "amarelo_=[93m"
set "azul_=[94m"
set "cinza=[90m"

::=========================================================================================================================
:Menu
cls
echo %cor%%verde_%                                   _    _
echo                                   (%cor%%amarelo%o%cor%%verde_%)--(%cor%%amarelo%o%cor%%verde_%)
echo                                  /.______.\ 
echo                                  \________/
echo                                 ./        \.
echo                                ( .        , )                        
echo                                 \ \_\\//_/ /
echo                                  ^~^~  ^~^~  ^~^~

echo:                    Scripts Auxiliares de POS - S.A.P.O.S%cor%%branco%
echo:       ______________________________________________________________
echo:
echo:                       ______________________________
echo:
echo:                       [%cor%%azul_%1%cor%%branco%] Base Zero
echo:                       [%cor%%azul_%2%cor%%branco%] Testes de Rede
echo:                       [%cor%%azul_%3%cor%%branco%] Reparar WMI
echo:                       [%cor%%azul_%4%cor%%branco%] Atualizar DLL SAT
echo:                       [%cor%%azul_%5%cor%%branco%] Habilitar WebView2
echo:
echo:                       [%cor%%vermelho%0%cor%%branco%] SAIR
echo:                       ______________________________
echo:                                                                %cor%%cinza%1.0.4%cor%%branco%
echo:       ______________________________________________________________

choice /C:123450 /N
set _erl=%errorlevel%

if %_erl%==1 setlocal & call :BaseZero & endlocal
if %_erl%==2 setlocal & call :TesteRede  & endlocal
if %_erl%==3 setlocal & call :FixWMI  & endlocal
if %_erl%==4 setlocal & call :MenuSAT  & endlocal
if %_erl%==5 setlocal & call :WebView2  & endlocal
if %_erl%==6 exit /b

:voltar_menu
echo:
echo %cor%%amarelo_%Pressione qualquer tecla para voltar ao menu...%cor%%branco%
pause >nul
goto Menu

::=========================================================================================================================
::=========================================================================================================================
:BaseZero
echo %cor%%azul%BASE ZERO%cor%%branco%
echo Esse procedimento cria um backup e zera a base de dados local do POS.
echo %cor%%amarelo_%Deseja continuar? (S/N)%cor%%branco%
choice /C:SN /N
set confirmacao_basezero=%errorlevel%
if %confirmacao_basezero%==2 (
    echo:
    echo Operacao cancelada pelo usuario.
    goto :eof
)
cls
setlocal enabledelayedexpansion
echo %cor%%azul_%Realizando Base Zero...%cor%%branco%
set "pastaDocumentos=%USERPROFILE%\Documents"
set "LinxMicrovixPOS=C:\Program Files (x86)\Linx Sistemas\Linx Microvix POS"
set "backup=%LinxMicrovixPOS%\Backup.%date:~0,2%-%date:~3,2%-%date:~6,4%_%time:~0,2%.%time:~3,2%"

set "URL1=https://grupolinx-my.sharepoint.com/:u:/g/personal/jhonathan_ferreira_linx_com_br/EfyM4gar3mtDndr2Gk39VpABEQnirg8xKxZ8mu673olwRw?download=1"
set "URL2=https://files.catbox.moe/qh94an.zip"

if exist "%pastaDocumentos%\basezero.zip" (
    echo Arquivo basezero.zip encontrado. Excluindo...
    del "%pastaDocumentos%\basezero.zip")

echo Baixando a Base Zero...
powershell -Command "Invoke-WebRequest -Uri '%URL1%' -OutFile '%pastaDocumentos%\basezero.zip'"
call :tamanho_basezero
    if not exist "%pastaDocumentos%\basezero.zip" (
        echo %cor%%amarelo%ERRO AO BAIXAR A BASE ZERO DO LINK PRINCIPAL. Tentando o link reserva... %cor%%branco%
        powershell -Command "Invoke-WebRequest -Uri '%URL2%' -OutFile '%pastaDocumentos%\basezero.zip'"
        call :tamanho_basezero
        if not exist "%pastaDocumentos%\basezero.zip" (
            echo %cor%%amarelo%ERRO AO BAIXAR COM POWERSHELL. Tentando com BITSAdmin...%cor%%branco%
            bitsadmin /download /priority normal "%URL1%" "%pastaDocumentos%\basezero.zip"
            call :tamanho_basezero
        )
        if not exist "%pastaDocumentos%\basezero.zip" (
            echo %cor%%amarelo%ERRO AO BAIXAR A BASE ZERO DO LINK RESERVA com BITSAdmin...%cor%%branco%
            bitsadmin /transfer "BaseZeroDownload" /download /priority normal "%URL2%" "%pastaDocumentos%\basezero.zip"
            call :tamanho_basezero
        )
        if not exist "%pastaDocumentos%\basezero.zip" (
            echo %cor%%vermelho%ERRO AO BAIXAR A BASE ZERO DO LINK RESERVA. %cor%%branco%
            echo %cor%%vermelho%Verifique sua conexao de rede e tente novamente. Caso o problema persista, acione jhonathan.ferreira@linx.com.br %cor%%branco%
            pause
            goto :eof
        )
    )

echo Extraindo os arquivos...
powershell -Command "try {Expand-Archive -Path '%pastaDocumentos%\basezero.zip' -DestinationPath '%pastaDocumentos%' -Force} catch {Write-Host 'ERRO AO EXTRAIR A BASE ZERO'; Read-Host -Prompt 'Verifique o arquivo basezero.zip e tente novamente'}"

echo Parando servico SQL Server...
net stop "SQL Server (SQLEXPRESSPOS4)"

echo Criando pasta backup...
mkdir "!backup!" 2>nul
if exist "%LinxMicrovixPOS%\POS_data.mdf" (
    echo Movendo POS_data.mdf para backup...
    move "%LinxMicrovixPOS%\POS_data.mdf" "!backup!\POS_data.mdf"
)
if exist "%LinxMicrovixPOS%\POS_data_log.ldf" (
    echo Movendo POS_data_log.ldf para backup...
    move "%LinxMicrovixPOS%\POS_data_log.ldf" "!backup!\POS_data_log.ldf"
)
if exist "%LinxMicrovixPOS%\Logs\POS.txt" (
    echo Renomeando log antigo...
    ren "%LinxMicrovixPOS%\Logs\POS.txt" "POS.%date:~0,2%-%date:~3,2%-%date:~6,4%_%time:~0,2%.%time:~3,2%.txt"
)

echo Movendo os arquivos POS_data.mdf e POS_data_log.ldf para a pasta Linx Microvix POS...
if exist "%pastaDocumentos%\POS_data.mdf" (
    move "%pastaDocumentos%\POS_data.mdf" "%LinxMicrovixPOS%\POS_data.mdf"
)
if exist "%pastaDocumentos%\POS_data_log.ldf" (
    move "%pastaDocumentos%\POS_data_log.ldf" "%LinxMicrovixPOS%\POS_data_log.ldf"
)

echo Iniciando servico SQL Server...
net start "SQL Server (SQLEXPRESSPOS4)"
if %errorlevel% NEQ 0 (
    echo %cor%%amarelo%BASE ZERO REALIZADA, MAS O SERVICO NAO FOI INICIADO %cor%%branco%
    echo %cor%%amarelo%Verifique o servico "SQL Server (SQLEXPRESSPOS4)" %cor%%branco%
    pause
    goto :eof
)

echo:
echo %cor%%verde_%BASE ZERO REALIZADA COM SUCESSO %cor%%branco%
goto :eof

:tamanho_basezero
setlocal
for %%F in ("%pastaDocumentos%\basezero.zip") do (
    set "tamanho=%%~zF"
    if !tamanho! lss 512000 (
        del /f /q "%pastaDocumentos%\basezero.zip"
    )
)
endlocal
goto :eof

::=========================================================================================================================
::=========================================================================================================================
:FixWMI
echo %cor%%azul%FIX WMI%cor%%branco%
echo Esse procedimento tenta corrigir problemas relacionados ao WMI.
echo %cor%%amarelo_%Deseja continuar? (S/N)%cor%%branco%
choice /C:SN /N
set confirmacao_fixwmi=%errorlevel%
if %confirmacao_fixwmi%==2 (
    echo:
    echo Operacao cancelada pelo usuario.
    goto :eof
)

cls
echo %cor%%amarelo_%Verificando WMI...%cor%%branco%
call :checkwmi

:: Aplicar correção básica primeiro
if defined error_wmi (
    echo %cor%%amarelo_%Parando servico Winmgmt...%cor%%branco%
    powershell -Command "Stop-Service Winmgmt -Force" >nul 2>&1
    winmgmt /salvagerepository >nul 2>&1
    call :checkwmi
)

if not defined error_wmi (
    echo %cor%%verde_%[Funcionando]%cor%%branco%
    echo Nao e necessario aplicar esta opcao.
    goto :eof
)

echo %cor%%vermelho_%[Nao Respondendo]%cor%%branco%

:: Verificar se o serviço está corrompido
set _corrupt=
sc start Winmgmt >nul 2>&1
if %errorlevel% EQU 1060 set _corrupt=1
sc query Winmgmt >nul 2>&1 || set _corrupt=1

if defined _corrupt (
    echo:
    echo %cor%%vermelho%Servico Winmgmt esta corrompido, abortando...%cor%%branco%
    goto :eof
)

echo:
echo %cor%%amarelo_%Desabilitando servico Winmgmt...%cor%%branco%
sc config Winmgmt start= disabled >nul 2>&1
if %errorlevel% EQU 0 (
    echo %cor%%verde_%[Sucesso]%cor%%branco%
) else (
    echo %cor%%vermelho_%[Falha] Abortando...%cor%%branco%
    sc config Winmgmt start= auto >nul 2>&1
    goto :eof
)

echo:
echo %cor%%amarelo_%Parando servico Winmgmt...%cor%%branco%
powershell -Command "Stop-Service Winmgmt -Force" >nul 2>&1
powershell -Command "Stop-Service Winmgmt -Force" >nul 2>&1
powershell -Command "Stop-Service Winmgmt -Force" >nul 2>&1
sc query Winmgmt | find /i "STOPPED" >nul && (
    echo %cor%%verde_%[Sucesso]%cor%%branco%
) || (
    echo %cor%%vermelho%[Falha]%cor%%branco%
    echo:
    echo %cor%%vermelho_%Recomendado reiniciar o PC e tentar novamente.%cor%%branco%
    sc config Winmgmt start= auto >nul 2>&1
    goto :eof
)

echo:
echo %cor%%amarelo_%Deletando repositorio WMI...%cor%%branco%
rmdir /s /q "%SystemRoot%\System32\wbem\repository\" >nul 2>&1
if exist "%SystemRoot%\System32\wbem\repository\" (
    echo %cor%%vermelho_%[Falha]%cor%%branco%
) else (
    echo %cor%%verde_%[Sucesso]%cor%%branco%
)

echo:
echo %cor%%amarelo_%Habilitando servico Winmgmt...%cor%%branco%
sc config Winmgmt start= auto >nul 2>&1
if %errorlevel% EQU 0 (
    echo %cor%%verde_%[Sucesso]%cor%%branco%
) else (
    echo %cor%%vermelho_%[Falha]%cor%%branco%
)

call :checkwmi
if not defined error_wmi (
    echo:
    echo %cor%%amarelo_%Verificando WMI...%cor%%branco%
    echo %cor%%verde_%[Funcionando]%cor%%branco%
    goto :eof
)

echo:
echo %cor%%amarelo_%Registrando DLLs e compilando MOFs, MFLs...%cor%%branco%
call :registerobj_sapos

echo:
echo %cor%%amarelo_%Verificacao final do WMI...%cor%%branco%
call :checkwmi
if defined error_wmi (
    echo %cor%%vermelho_%[Nao Respondendo]%cor%%branco%
    echo:
    echo %cor%%amarelo_%Nao foi possivel reparar o WMI. Acione o TI da empresa.%cor%%branco%
) else (
    echo %cor%%verde_%[Funcionando]%cor%%branco%
    echo:
    echo %cor%%verde_%WMI corrigido com sucesso!%cor%%branco%
)

goto :eof


:registerobj_sapos
powershell -Command "Stop-Service Winmgmt -Force" >nul 2>&1
cd /d %SystemRoot%\System32\wbem\
regsvr32 /s %SystemRoot%\System32\scecli.dll
regsvr32 /s %SystemRoot%\System32\userenv.dll
mofcomp cimwin32.mof >nul 2>&1
mofcomp cimwin32.mfl >nul 2>&1
mofcomp rsop.mof >nul 2>&1
mofcomp rsop.mfl >nul 2>&1

for /f %%s in ('dir /b /s *.dll 2^>nul') do regsvr32 /s %%s >nul 2>&1
for /f %%s in ('dir /b *.mof 2^>nul') do mofcomp %%s >nul 2>&1
for /f %%s in ('dir /b *.mfl 2^>nul') do mofcomp %%s >nul 2>&1

winmgmt /salvagerepository >nul 2>&1
winmgmt /resetrepository >nul 2>&1
goto :eof


:checkwmi
set error_wmi=
powershell -Command "try { Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property CreationClassName | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
if %errorlevel% NEQ 0 ( set error_wmi=1 & goto :eof)

winmgmt /verifyrepository >nul 2>&1
if %errorlevel% NEQ 0 ( set error_wmi=1 & goto :eof)

powershell -Command "try { Get-WmiObject -Namespace 'root\cimv2' -Class __Namespace | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
if %errorlevel% NEQ 0 ( set error_wmi=1 & goto :eof)

powershell -Command "try { Get-WmiObject -Class __Win32Provider -Namespace root\cimv2 | Where-Object {$_.Name -eq 'CIMWin32'} | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
if %errorlevel% NEQ 0 ( set error_wmi=1 & goto :eof)

powershell -Command "try { $classes = @('Win32_OperatingSystem', 'Win32_LogicalDisk', 'Win32_NetworkAdapter', 'Win32_Service', 'Win32_SystemDevices'); foreach($class in $classes) { $result = Get-WmiObject -Class $class -ErrorAction Stop | Select-Object -First 1 }; exit 0 } catch { exit 1 }" >nul 2>&1
if %errorlevel% NEQ 0 ( set error_wmi=1 & goto :eof)

powershell -Command "try { $null=([WMISEARCHER]'SELECT * FROM SoftwareLicensingService').Get().Version; exit 0 } catch { exit 1 }" >nul 2>&1
if %errorlevel% NEQ 0 set error_wmi=1
goto :eof

::========================================================================================================================
::========================================================================================================================
:TesteRede
echo %cor%%azul%TESTE DE REDE%cor%%branco%
echo Este procedimento testa a conexao com os URLs do Microvix e Fiscal Flow.
echo %cor%%amarelo_%Deseja continuar? (S/N)%cor%%branco%
choice /C:SN /N
set confirmacao_teste=%errorlevel%
if %confirmacao_teste%==2 (
    echo:
    echo Operacao cancelada pelo usuario.
    goto :eof
)
cls
setlocal enabledelayedexpansion

set "config=C:\Program Files (x86)\Linx Sistemas\Linx Microvix POS\Microvix.POS.exe.Config"
set "urls=%temp%\urls_microvix.txt"
set "porta=80 8089"
set "fiscalflow=api-evo.fiscalflow.linx.com.br tecfiscal.linx.com.br"
set "sites=erp.microvix.com.br vendafacil.microvix.com.br"
set "WebRequest=Invoke-WebRequest -Uri"
set "falha=0"
set "log=%temp%\teste_urls_microvix.log.txt"

if not exist "%config%" (
    echo %cor%%vermelho%Microvix.POS.exe.Config nao encontrado. Verifique se o POS esta instalado corretamente. %cor%%branco%
    pause
    exit /B
)

if exist "%urls%" del /f /q "%urls%"
if exist "%log%" del /f /q "%log%"

:: Extrai as URLs que estejam no formato endpoint address="URL"
powershell -Command ^
    "Select-String -Path '%config%' -Pattern 'address=\""([^\""]*)\""' | ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value } | Set-Content -Encoding ASCII '%urls%'"

if exist "%urls%" (
    echo URLs extraidas. Iniciando testes...
) else (
    echo %cor%%vermelho%FALHA NA EXTRACAO DE URLS %cor%%branco%
    pause
    exit /B
)

set "repetir=0"
:testes
echo -----------------------------------------
echo %cor%%azul%TESTANDO COMUNICACAO DAS URLS %cor%%branco%
echo -----------------------------------------
::URLs do POS
for /f "usebackq delims=" %%U in ("%urls%") do (
    echo Testando: %%U
    powershell -Command ^
        "try { $r=%WebRequest% '%%U' -UseBasicParsing -TimeoutSec 3; if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 400) { exit 0 } else { exit 1 } } catch { exit 2 }"
    set "psError=!errorlevel!"
    if !psError! equ 0 (
        echo %cor%%verde_%OK %cor%%branco%
        call :log_ok %%U
    ) else (
        echo %cor%%vermelho%FALHA %cor%%branco%
        call :log_erro %%U
        set "falha=1"
    )
    echo -----------------------------------------
)
::URLs ERP e Venda Fácil
for %%S in (%sites%) do (
    echo Testando: %%S
    ping -n 1 -w 1000 %%S  >nul 2>&1
    if !errorlevel! equ 0 (
        echo %cor%%verde_%OK %cor%%branco%
        call :log_ok %%S
    ) else (
        echo %cor%%vermelho%FALHA %cor%%branco%
        call :log_erro %%S
        set "falha=1"
    )
    echo -----------------------------------------
)


echo %cor%%azul%TESTANDO COMUNICACAO COM FISCAL FLOW %cor%%branco%
echo -----------------------------------------
for %%F in (%fiscalflow%) do (
    echo Testando: %%F
    ping -n 1 -w 1000 %%F >nul 2>&1
    if !errorlevel! equ 0 (
        echo %cor%%verde_%OK %cor%%branco%
        call :log_ok %%F
    ) else (
        echo %cor%%vermelho%FALHA %cor%%branco%
        call :log_erro %%F
        set "falha=1"
    )
    echo -----------------------------------------
)


echo %cor%%azul%TESTANDO COMUNICACAO DAS PORTAS %cor%%branco%
echo -----------------------------------------
for %%P in (%porta%) do (
    echo Testando porta: %%P
    powershell -Command ^
        "$r = Test-NetConnection -ComputerName 127.0.0.1 -Port %%P; if ($r.TcpTestSucceeded) { exit 0 } else { exit 1 }"
    set "psError=!errorlevel!"
    if !psError! equ 0 (
        echo %cor%%verde_%OK %cor%%branco%
        call :log_ok "Porta %%P"
    ) else (
        echo %cor%%vermelho%FALHA %cor%%branco%
        call :log_erro "Porta %%P"
        set "falha=1"
    )
    echo -----------------------------------------
)


if !falha! equ 0 (
    echo %cor%%verde_%TODOS OS TESTES OK %cor%%branco%
) else (
    echo %cor%%vermelho%FALHA NA COMUNICACAO EM ALGUM TESTE %cor%%branco%
    echo.
    if !repetir! equ 0 (
        set /p "resposta=Deseja desativar o Firewall, alterar o DNS e tentar novamente? (S/N): "
        echo.
        if /i "!resposta!"=="S" (
            call :verificafirewall
            set "psError=!errorlevel!"
            if !psError! equ 1 (
                echo Firewall ja esta desativado.
                echo.
            ) else (
                echo Desativando Firewall...
                ::desativar firewall
                powershell -Command ^
                    "Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False"
                call :verificafirewall
                set "psError=!errorlevel!"
                if !psError! equ 1 (
                    echo Firewall desativado com sucesso.
                    echo.
                ) else (
                    echo %cor%%vermelho%FALHA AO DESATIVAR FIREWALL. TENTE ALTERAR MANUALMENTE. %cor%%branco%
                )
            )
            echo Alterando DNS para 8.8.8.8 e 8.8.4.4...
            powershell -Command ^
                "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object {Set-DnsClientServerAddress -InterfaceAlias $_.Name -ServerAddresses ('8.8.8.8','8.8.4.4')}"
            ::verifica DNS
            powershell -Command ^
                "$dns = (Get-DnsClientServerAddress -InterfaceAlias (Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object -First 1).Name).ServerAddresses; if ($dns -contains '8.8.8.8' -and $dns -contains '8.8.4.4') { exit 0 } else { exit 1 }"
            set "psError=!errorlevel!"
            if !psError! equ 0 (
                echo DNS alterado com sucesso.
                echo.
                set "repetir=1"
                goto :testes
            ) else (
                echo %cor%%vermelho%FALHA NA ALTERACAO DO DNS. TENTE ALTERAR MANUALMENTE. %cor%%branco%
            )
            echo.
        )
    )
)

>> "%log%" echo:
>> "%log%" echo Verifique todos os IPs e portas necessarias no site: https://share.linx.com.br/display/SHOPLINXMICRPUB/IPs+Microvix
del /f /q "%urls%"
echo Resultado registrado em: "%log%"
goto :eof


:verificafirewall
powershell -Command ^
    "$wf = Get-NetFirewallProfile | Select-Object -ExpandProperty Enabled; if ($wf -contains 'True') {exit 0} else {exit 1}"
goto :eof


:log_ok
setlocal
set "msg=%~1"
set "timestamp=%date:~0,2%-%date:~3,2%-%date:~6,4% %time:~0,2%:%time:~3,2%:%time:~6,2%"
>> "%log%" echo %timestamp% ^|  OK  ^| Conexão realizada com: %msg%
endlocal
goto :eof

:log_erro
setlocal
set "msg=%~1"
set "timestamp=%date:~0,2%-%date:~3,2%-%date:~6,4% %time:~0,2%:%time:~3,2%:%time:~6,2%"
>> "%log%" echo %timestamp% ^| ERRO ^| Falha de comunicação com: %msg%
endlocal
goto :eof

::========================================================================================================================
::========================================================================================================================
:MenuSAT
cls
echo %cor%%verde_%                                   _    _
echo                                   (%cor%%amarelo%o%cor%%verde_%)--(%cor%%amarelo%o%cor%%verde_%)
echo                                  /.______.\ 
echo                                  \________/
echo                                 ./        \.
echo                                ( .        , )                        
echo                                 \ \_\\//_/ /
echo                                  ^~^~  ^~^~  ^~^~

echo:                    Scripts Auxiliares de POS - S.A.P.O.S%cor%%branco%
echo:       ______________________________________________________________
echo:
echo:                      %cor%%verde_%ESCOLHA O MODELO DO APARELHO SAT%cor%%branco%
echo:                       ______________________________
echo:
echo:                       [%cor%%azul_%1%cor%%branco%] Bematech SAT-GO
echo:                       [%cor%%azul_%2%cor%%branco%] Elgin Smart
echo:                       [%cor%%azul_%3%cor%%branco%] Elgin Linker II
echo:                       [%cor%%azul_%4%cor%%branco%] Dimep D-SAT
echo:
echo:                       [%cor%%vermelho%0%cor%%branco%] VOLTAR
echo:                       ______________________________
echo:
echo:       ______________________________________________________________

choice /C:12340 /N
set _erl=%errorlevel%

if %_erl%==1 setlocal & call :dllSATGO & endlocal
if %_erl%==2 setlocal & call :dllSMART & endlocal
if %_erl%==3 setlocal & call :dllLINKERII  & endlocal
if %_erl%==4 setlocal & call :dllDIMEP  & endlocal
if %_erl%==5 goto Menu

::========================================================================================================================
::========================================================================================================================
:dllSATGO
echo %cor%%azul%ATUALIZAR DLL SAT%cor%%branco%
echo Este procedimento substitui o arquivo .dll para o aparelho SAT.
echo %cor%%amarelo_%Deseja continuar? (S/N)%cor%%branco%
choice /C:SN /N
set confirmacao_teste=%errorlevel%
if %confirmacao_teste%==2 (
    echo:
    echo Operacao cancelada pelo usuario.
    goto :eof
)
cls
setlocal enabledelayedexpansion

set "BemaSAT.dll=C:\Program Files\Bematech\ActivationSoftwarePackage\ActivationSoftware\BemaSAT.dll"
set "bemasat.xml=C:\Program Files\Bematech\ActivationSoftwarePackage\ActivationSoftware\bemasat.xml"
set "SysWOW64=C:\Windows\SysWOW64"
set "System32=C:\Windows\System32"
set "FFsatgo=C:\Program Files (x86)\Linx\Fiscal Flow Client\DLLSAT\BEMATECH_SAT GO"

if not exist "%BemaSAT.dll%" (
    echo %cor%%vermelho%DLL nao encontrada.%cor%%branco%
    echo Verifique se o ActivationSoftware esta instalado na pasta C:\Program Files\Bematech\ActivationSoftwarePackage\ActivationSoftware
    call :voltar_menu
)

if not exist "%FFsatgo%" (
    echo %cor%%vermelho%Pasta BEMATECH_SAT GO nao encontrada.%cor%%branco%
    echo Verifique se o Fiscal Flow Client esta instalado corretamente
    call :voltar_menu
)

copy /Y "%BemaSAT.dll%" "%SysWOW64%"
copy /Y "%bemasat.xml%" "%SysWOW64%"
copy /Y "%BemaSAT.dll%" "%System32%"
copy /Y "%bemasat.xml%" "%System32%"
copy /Y "%BemaSAT.dll%" "%FFsatgo%"

del "%FFsatgo%\sat_bematech.dll"

ren "%FFsatgo%\BemaSAT.dll" sat_bematech.dll

powershell -command ^
    "Stop-Service -Name 'Fiscal Flow Client' -Force"
powershell -command ^
    "Start-Service -Name 'Fiscal Flow Client'"

powershell -command "if ((Get-Service -Name 'Fiscal Flow Client').Status -ne 'Running') { exit 1 }" >nul 2>&1
if !errorlevel! neq 0 (
    echo %cor%%amarelo%DLL atualizada, porem o servico Fiscal Flow Client nao foi iniciado corretamente
    echo Tente iniciar o servico manualmente%cor%%branco%
    call :voltar_menu
)
echo %cor%%verde_%DLL atualizada.%cor%%branco%
call :voltar_menu

::========================================================================================================================
::========================================================================================================================
:dllSMART
echo %cor%%azul%ATUALIZAR DLL SAT%cor%%branco%
echo Este procedimento substitui o arquivo .dll para o aparelho SAT.
echo %cor%%amarelo_%Deseja continuar? (S/N)%cor%%branco%
choice /C:SN /N
set confirmacao_teste=%errorlevel%
if %confirmacao_teste%==2 (
    echo:
    echo Operacao cancelada pelo usuario.
    goto :eof
)
cls
setlocal enabledelayedexpansion

set "dllsat.dll=C:\Program Files\Elgin Tools\dllsat.dll"
set "SysWOW64=C:\Windows\SysWOW64"
set "System32=C:\Windows\System32"
set "FFsmart=C:\Program Files (x86)\Linx\Fiscal Flow Client\DLLSAT\ELGIN_smart"

if not exist "%dllsat.dll%" (
    echo %cor%%vermelho%DLL nao encontrada.%cor%%branco%
    echo Verifique se o Elgin Tools esta instalado na pasta C:\Program Files\Elgin Tools
    call :voltar_menu
)

if not exist "%FFsmart%" (
    echo %cor%%vermelho%Pasta BEMATECH_SAT GO nao encontrada.%cor%%branco%
    echo Verifique se o Fiscal Flow Client esta instalado corretamente
    call :voltar_menu
)

copy /Y "%dllsat.dll%" "%SysWOW64%"
copy /Y "%dllsat.dll%" "%System32%"
copy /Y "%dllsat.dll%" "%FFsmart%"

del "%FFsmart%\sat_elgin.dll"

ren "%FFsmart%\dllsat.dll" sat_elgin.dll

powershell -command ^
    "Stop-Service -Name 'Fiscal Flow Client' -Force"
powershell -command ^
    "Start-Service -Name 'Fiscal Flow Client'"

powershell -command "if ((Get-Service -Name 'Fiscal Flow Client').Status -ne 'Running') { exit 1 }" >nul 2>&1
if !errorlevel! neq 0 (
    echo %cor%%amarelo%DLL atualizada, porem o servico Fiscal Flow Client nao foi iniciado corretamente
    echo Tente iniciar o servico manualmente%cor%%branco%
    call :voltar_menu
)
echo %cor%%verde_%DLL atualizada.%cor%%branco%
call :voltar_menu

::========================================================================================================================
::========================================================================================================================
:dllLINKERII
echo %cor%%azul%ATUALIZAR DLL SAT%cor%%branco%
echo Este procedimento substitui o arquivo .dll para o aparelho SAT.
echo %cor%%amarelo_%Deseja continuar? (S/N)%cor%%branco%
choice /C:SN /N
set confirmacao_teste=%errorlevel%
if %confirmacao_teste%==2 (
    echo:
    echo Operacao cancelada pelo usuario.
    goto :eof
)
cls
setlocal enabledelayedexpansion

set "dllsat.dll=C:\Program Files\Elgin Tools\dllsat.dll"
set "SysWOW64=C:\Windows\SysWOW64"
set "System32=C:\Windows\System32"
set "FFlinker=C:\Program Files (x86)\Linx\Fiscal Flow Client\DLLSAT\ELGIN_LinkerII"

if not exist "%dllsat.dll%" (
    echo %cor%%vermelho%DLL nao encontrada.%cor%%branco%
    echo Verifique se o Elgin Tools esta instalado na pasta C:\Program Files\Elgin Tools
    call :voltar_menu
)

if not exist "%FFlinker%" (
    echo %cor%%vermelho%Pasta BEMATECH_SAT GO nao encontrada.%cor%%branco%
    echo Verifique se o Fiscal Flow Client esta instalado corretamente
    call :voltar_menu
)

copy /Y "%dllsat.dll%" "%SysWOW64%"
copy /Y "%dllsat.dll%" "%System32%"
copy /Y "%dllsat.dll%" "%FFlinker%"

del "%FFlinker%\sat_elgin.dll"

ren "%FFlinker%\dllsat.dll" sat_elgin.dll

powershell -command ^
    "Stop-Service -Name 'Fiscal Flow Client' -Force"
powershell -command ^
    "Start-Service -Name 'Fiscal Flow Client'"

powershell -command "if ((Get-Service -Name 'Fiscal Flow Client').Status -ne 'Running') { exit 1 }" >nul 2>&1
if !errorlevel! neq 0 (
    echo %cor%%amarelo%DLL atualizada, porem o servico Fiscal Flow Client nao foi iniciado corretamente
    echo Tente iniciar o servico manualmente%cor%%branco%
    call :voltar_menu
)
echo %cor%%verde_%DLL atualizada.%cor%%branco%
call :voltar_menu

::========================================================================================================================
::========================================================================================================================
:dllDIMEP
echo %cor%%azul%ATUALIZAR DLL SAT%cor%%branco%
echo Este procedimento substitui o arquivo .dll para o aparelho SAT.
echo %cor%%amarelo_%Deseja continuar? (S/N)%cor%%branco%
choice /C:SN /N
set confirmacao_teste=%errorlevel%
if %confirmacao_teste%==2 (
    echo:
    echo Operacao cancelada pelo usuario.
    goto :eof
)
cls
setlocal enabledelayedexpansion

set "satdimep.dll=%USERPROFILE%\AppData\Local\Programs\dsat-dm\satdimep.dll"
set "satdimep.ini=%USERPROFILE%\AppData\Local\Programs\dsat-dm\satdimep.ini"
set "SysWOW64=C:\Windows\SysWOW64"
set "System32=C:\Windows\System32"
set "FFdimep=C:\Program Files (x86)\Linx\Fiscal Flow Client\DLLSAT\DIMEP_D-SAT"

if not exist "%satdimep.dll%" (
    echo %cor%%vermelho%DLL nao encontrada.%cor%%branco%
    echo Verifique se o D-SAT Device Manager esta instalado na pasta:
    echo %USERPROFILE%\AppData\Local\Programs\dsat-dm
    call :voltar_menu
)

if not exist "%FFdimep%" (
    echo %cor%%vermelho%Pasta DIMEP_D-SAT nao encontrada.%cor%%branco%
    echo Verifique se o Fiscal Flow Client esta instalado corretamente
    call :voltar_menu
)

copy /Y "%satdimep.dll%" "%SysWOW64%"
copy /Y "%satdimep.ini%" "%SysWOW64%"
copy /Y "%satdimep.dll%" "%System32%"
copy /Y "%satdimep.ini%" "%System32%"
copy /Y "%satdimep.dll%" "%FFdimep%"
copy /Y "%satdimep.ini%" "%FFdimep%"

del "%FFdimep%\sat_dimep.dll"

ren "%FFdimep%\satdimep.dll" sat_dimep.dll

powershell -command ^
    "Stop-Service -Name 'Fiscal Flow Client' -Force"
powershell -command ^
    "Start-Service -Name 'Fiscal Flow Client'"

powershell -command "if ((Get-Service -Name 'Fiscal Flow Client').Status -ne 'Running') { exit 1 }" >nul 2>&1
if !errorlevel! neq 0 (
    echo %cor%%amarelo%DLL atualizada, porem o servico Fiscal Flow Client nao foi iniciado corretamente
    echo Tente iniciar o servico manualmente%cor%%branco%
    call :voltar_menu
)
echo %cor%%verde_%DLL atualizada.%cor%%branco%
call :voltar_menu

::========================================================================================================================
::========================================================================================================================
:WebView2
echo %cor%%azul%HABILITAR WEBVIEW2%cor%%branco%
echo Este procedimento altera o registro WebView2 de componente para programa do Windows.
echo %cor%%amarelo_%Deseja continuar? (S/N)%cor%%branco%
choice /C:SN /N
set confirmacao_teste=%errorlevel%
if %confirmacao_teste%==2 (
    echo:
    echo Operacao cancelada pelo usuario.
    goto :eof
)
cls

set WebView="HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView"

reg query %WebView% >nul 2>&1
if %errorlevel%==0 (
    echo Habilitando Microsoft Edge WebView2 Runtime...
    reg add %WebView% /v SystemComponent /t REG_DWORD /d 0 /f
) else (
    echo %cor%%vermelho%Edge WebView NAO esta instalado.%cor%%branco%
    echo Realize a instalacao manualmente
    goto :eof
)
echo %cor%%verde_%Microsoft Edge WebView2 Runtime habilitado com sucesso.%cor%%branco%
echo Verifique na listagem de Programas e Recursos do Painel de Controle
goto :eof

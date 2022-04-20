SET Nombre=CAI

REM Queda en RafamVer ( 2 cd ..)
CD ..\..

CALL SetParametros

SET CAI_PATH=%INSTA_PATH%\EjecutarScript

REM --- RENAME %CAI_PATH%\SCRIPTS\script.sql script.sql_old
REM --- XCOPY %CAI_PATH%\SCRIPTS\*.sql %CAI_PATH%\SCRIPTS\VIEJOS\ /R
REM --- RENAME %CAI_PATH%\SCRIPTS\*.sql script.sql

SET log=%CAI_PATH%\Logs\%Nombre%_EjecucionScript.log

 SqlPlus owner_rafam/%ACCESO%@%CAI_SID% @%CAI_PATH%\Setup\EjecutarScript.sql %CAI_SID% %CAI_PATH% %log%

CALL %INSTA_PATH%\Validar_Sistema.Bat

ECHO Resultado de la Validación del Sistema >> %log%
ECHO ---------------- >> %log%
ECHO Información de Objetos_invalidos >> %log%

DIR %INSTA_PATH%\AuxLogs\Objetos_Invalidos.log >> %log%
TYPE %INSTA_PATH%\AuxLogs\Objetos_Invalidos.log >> %log%


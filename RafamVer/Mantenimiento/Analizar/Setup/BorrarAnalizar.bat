SET Nombre=CAI

REM Queda en RafamVer ( 3 cd ..)
CD..\..\..

CALL SetParametros

SET CAI_PATH=%INSTA_PATH%\Mantenimiento\Analizar
SET log=%CAI_PATH%\SCRIPTS\%Nombre%_BorrarAnalizar.log

SqlPlus.exe owner_rafam/%ACCESO%@%CAI_SID% @%CAI_PATH%\Scripts\borrarAnalizar.sql %CAI_SID% %CAI_PATH% %log% %Nombre%

TYPE %CAI_PATH%\SCRIPTS\%NOMBRE%_Aux_analizar.log >> %log%
TYPE %CAI_PATH%\SCRIPTS\%NOMBRE%_Ejecucion_analizar.log >> %log%
DEL %CAI_PATH%\SCRIPTS\%NOMBRE%_Aux_analizar.log
DEL %CAI_PATH%\SCRIPTS\%NOMBRE%_Ejecucion_analizar.log

REM PAUSE

REM NOTEPAD %log%

EXIT


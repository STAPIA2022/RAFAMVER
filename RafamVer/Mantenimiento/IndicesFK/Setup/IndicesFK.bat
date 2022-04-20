SET Nombre=CAI

REM Queda en RafamVer ( 3 cd ..)
CD..\..\..

CALL SetParametros

SET CAI_PATH=%INSTA_PATH%\Mantenimiento\IndicesFK
SET log=%CAI_PATH%\SCRIPTS\%Nombre%_IndicesFK.log

XCOPY %CAI_PATH%\SCRIPTS\CREAR_INDICES_FK.LOG %CAI_PATH%\SCRIPTS\CREAR_INDICES_FK.OLD /A
XCOPY %CAI_PATH%\SCRIPTS\Ejecucion_CREAR_INDICES_FK.LOG %CAI_PATH%\SCRIPTS\Ejecucion_CREAR_INDICES_FK.OLD /A

PAUSE

DEL %CAI_PATH%\SCRIPTS\CREAR_INDICES_FK.LOG 
DEL %CAI_PATH%\SCRIPTS\Ejecucion_CREAR_INDICES_FK.LOG

PAUSE

  SqlPlus.exe owner_rafam/ownerdba@%CAI_SID% @%CAI_PATH%\Scripts\script.sql %CAI_SID% %CAI_PATH% %log% %Nombre%

TYPE %CAI_PATH%\SCRIPTS\CREAR_INDICES_FK.log >> %log%
TYPE %CAI_PATH%\SCRIPTS\Ejecucion_CREAR_INDICES_FK.log >> %log%

REM PAUSE

CALL %INSTA_PATH%\mantenimiento\analizar\setup\analizar.bat

NOTEPAD %log%

EXIT


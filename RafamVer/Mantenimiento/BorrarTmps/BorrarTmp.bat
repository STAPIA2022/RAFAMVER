
CD..\..\..

CALL SetParametros

SET CAI_PATH=%INSTA_PATH%\Mantenimiento\BorrarTmps
SET log=%CAI_PATH%\SCRIPTS\%Nombre%_BorrarTmps.log

SqlPlus.exe owner_rafam/%ACCESO%@%CAI_SID% @%CAI_PATH%\Script.sql %CAI_SID% %CAI_PATH% %log% %Nombre%

exit
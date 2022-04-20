CD GRANTS
REM CALL Obtener_Grants.BAT

CD ..

SET INSTA_PATH=C:\RafamVer

IF %cai_sid%==SERVER_RAFAM GOTO FIN

SET CAI_PATH=%INSTA_PATH%\Restaurar

SET PATH_LOGS=%INSTA_PATH%\Restaurar\Logs

SET PASS_SYSTEM=manager
rem ------- SET PASS_SYS=manager
SET PASS_SYS=change_on_install 

rem GOTO FIN23
PAUSE

REM ------------------------------------------------------------;
REM --- Elimina el usuario OWNER -------------------------------;
REM ------------------------------------------------------------;
    sqlplus.exe system/manager@BDRAFAM @C:\RafamVer\Restaurar\P_01_DropOwner.sql @C:\RafamVer\Restaurar\logs



REM ------------------------------------------------------------;
REM --- Creando usuario OWNER ----------------------------------;
REM ------------------------------------------------------------;
    SqlPlus system/manager@BDRAFAM @C:\RafamVer\Restaurar\P_02_CreateOwner.sql @C:\RafamVer\Restaurar\logs


REM ------------------------------------------------------------;
REM --- Restauración de Backup completo de la base -------------;
REM ------------------------------------------------------------;
    IMP.EXE system/manager@BDRAFAM FROMUSER=OWNER_RAFAM TOUSER=OWNER_RAFAM GRANTS=Y FILE=C:\RafamVer\Restaurar\DMP\BACKUP.DMP LOG=C:\RafamVer\Restaurar\logs\P_03_Backup_%CAI_SID%.LOG RECALCULATE_STATISTICS=Y


REM ------------------------------------------------------------;
REM --- Creacion de Usuarios para los Cursos -------------------;
REM ------------------------------------------------------------;
REM    SqlPlus system/manager@BDRAFAM @C:\RafamVer\Restaurar\P_04_Crear_Usuarios.sql BDRAFAM C:\RafamVer\Restaurar\logs


REM ------------------------------------------------------------;
REM --- Modificacion Parametros CONFIG -------------------------;
REM ------------------------------------------------------------;
    SqlPlus owner_rafam/ownerdba@BDRAFAM @C:\RafamVer\Restaurar\P_05_TB_Config.sql BDRAFAM C:\RafamVer\Restaurar\logs


REM ------------------------------------------------------------;
REM --- Permisos al PKG: SYS.DBMS_PIPE -------------------------;
REM ------------------------------------------------------------;
    SqlPlus "system/manager@BDRAFAM AS SYSDBA" @C:\RafamVer\Restaurar\P_06_PIPE_Grant.sql BDRAFAM C:\RafamVer\Restaurar\logs


REM ------------------------------------------------------------;
REM --- Ejecuta el ANALYZED Sobre Tablas e Indices -------------;
REM ------------------------------------------------------------;
    SQLPlus.exe OWNER_RAFAM/OWNERDBA@BDRAFAM @C:\RafamVer\Restaurar\P_07_Analizar.sql BDRAFAM C:\RafamVer\Restaurar\logs




:FIN23

CALL Validar_Sistema.bat
PAUSE


REM PAUSE
REM del %CAI_PATH%\backup.dmp
REM pause
REM EXIT
GOTO FIN2


:FIN
ECHO NO SE PUEDE ELIMINAR EL OWNER DE SERVER_RAFAM
PAUSE


CD RESTAURAR
:FIN2
REM EXIT
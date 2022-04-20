echo Validar_sistema

call SetParametros


@echo on
@echo 11 Validaciones de funciones, vistas y stored procs.
@echo off

DEL %INSTA_PATH%\AuxLogs\OBJETOS_VALIDADOS.LOG /F 
DEL %INSTA_PATH%\AuxSQL\AuxValidar.sql /F 
@echo on
@echo Analiza Menues incorrectos
@echo off
rem plus80w.exe owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\menues_incorrectos.sql 

@echo on
@echo Paso 1
@echo off
%plus80% owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\Validar_Sistema.sql 

@echo on
@echo Paso 2
@echo off
%plus80% owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\Validar_Sistema.sql 

@echo on
@echo Paso 3
@echo off
%plus80% owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\Validar_Sistema.sql 

@echo on
@echo Paso 4
@echo off
%plus80% owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\Validar_Sistema.sql 

@echo on
@echo Paso 5
@echo off
%plus80% owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\Validar_Sistema.sql 

@echo on
@echo Paso 6
@echo off
%plus80% owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\Validar_Sistema.sql 

@echo on
@echo Paso 7
@echo off
%plus80% owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\Validar_Sistema.sql 

@echo on
@echo Paso 8
@echo off
%plus80% owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\Validar_Sistema.sql 

@echo on
@echo Paso 9
@echo off
%plus80% owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\Validar_Sistema.sql 

@echo on
@echo Paso 10
@echo off
%plus80% owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\Validar_Sistema.sql 

@echo on
@echo Paso 11
@echo off
%plus80% owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\Validar_Sistema.sql 

%plus80% owner_rafam/%Acceso%@%CAI_SID% @%INSTA_PATH%\Objetos_Invalidos.sql

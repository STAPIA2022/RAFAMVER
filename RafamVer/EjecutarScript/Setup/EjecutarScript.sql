HOST CLS
SET ECHO OFF
REM SET FEEDBACK OFF
SET HEADING OFF
REM SET VERIFY OFF
REM SET TERM ON
REM SET WRAP OFF
Set linesize 120
Col p1 format a120
Col p2 format a80

SPOOL &3;
PROMPT Registro de Instalación
SELECT 'Fecha: '||TO_CHAR(sysdate,'DD/MM/YYYY HH24:MI') FROM DUAL;
SELECT 'Lugar: '||contenido FROM config WHERE nombre_parametro='MUNICIPALIDAD';
PROMPT Versión Act: [EjecutarScript];
PROMPT Instancia  : [&1];
PROMPT RafamVer   : [&2];
PROMPT -------------------------------------------;
@&2\SCRIPTS\Script.sql;
PROMPT --------------------FIN--------------------;
SPOOL OFF;
EXIT;


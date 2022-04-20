HOST CLS

set lines 80
set serveroutput on size 200000
set veri off
set feed off
set pages 0
set long 32000

SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET VERIFY OFF
SET TERM ON
SET WRAP ON

set pagesize 0
Col p1 format a120

SPOOL &3;
PROMPT Registro de Instalación
SELECT 'Fecha: '||TO_CHAR(sysdate,'DD/MM/YYYY HH24:MI') FROM DUAL;
SELECT 'Lugar: '||contenido FROM config WHERE nombre_parametro='MUNICIPALIDAD';
PROMPT Versión Act: [EjecutarScript];
PROMPT Instancia  : [&1];
PROMPT RafamVer   : [&2];
PROMPT ----------------------------------------------------------;

SPOOL off;

SPOOL &2\SCRIPTS\ejecucion_crear_indices_fk.log;
PROMPT ------------------EJECUTANDO ARCHIVO DE CREACION DE INDICES ------------------;
start &2\SCRIPTS\crear_indices_fk.log;

SPOOL OFF;

PROMPT -----------------------------FIN------------------;

SPOOL OFF;

EXIT;

HOST CLS
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET VERIFY OFF
SET TERM ON
SET WRAP ON

--Set linesize 120
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

SPOOL &2\SCRIPTS\%NOMBRE%_Aux_analizar.log;

PROMPT --------------------CREANDO ANALIZADOR--------------------;

PROMPT --------------------ANALIZADO TABLAS--------------------;

SELECT 'PROMPT ANALIZANDO '  || table_name || ';' || chr(10) || ' ANALYZE table ' || table_NAME || ' COMPUTE STATISTICS;'  as p1
FROM user_tables;

----UNION ALL

PROMPT --------------------ANALIZADO INDICES--------------------;

SELECT 'PROMPT ANALIZANDO '  || index_name || ';' || chr(10) || ' ANALYZE index ' || INDEX_NAME || ' COMPUTE STATISTICS;'  as p1
FROM USER_INDEXES;

SPOOL OFF;

PROMPT EJECUTANDO ANALIZADOR;

SPOOL &2\SCRIPTS\%NOMBRE%_Ejecucion_Analizar.log;

PROMPT --------------------EJECUTANDO ANALIZADOR--------------------;

start &2\SCRIPTS\%NOMBRE%_Aux_analizar.log;

PROMPT -------------------- FIN--------------------;

/*
--GENERA LIO HACE QUE ALGUNOS QUERYS MATEN LA BASE
--ESTUDIAR MEJOR
SPOOL OFF;

-------------------------------------------------------------------------------------
SPOOL &2\SCRIPTS\%NOMBRE%_Aux_analizar2.log;

PROMPT --------------------CREANDO ANALIZADOR--------------------;

SELECT 'PROMPT ANALIZANDO '||table_name||'.'||column_name|| ';' || chr(10) || 
 'ANALYZE table ' || table_name || chr(10) ||' COMPUTE STATISTICS FOR COLUMNS ' || chr(10) || ' ' || column_name || ';'  as p1
FROM USER_HISTOGRAMS;

SPOOL OFF;

PROMPT EJECUTANDO ANALIZADOR;

SPOOL &2\SCRIPTS\%NOMBRE%_Ejecucion_Analizar2.log;

PROMPT --------------------EJECUTANDO ANALIZADOR--------------------;

start &2\SCRIPTS\%NOMBRE%_Aux_analizar2.log;

PROMPT --------------------FIN 2 de 2 --------------------;
*/

SPOOL OFF;


EXIT;


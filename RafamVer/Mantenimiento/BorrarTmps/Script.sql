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

SPOOL &2\%NOMBRE%_BorrarTmps.log;

PROMPT -------------------- Borrar TMPs --------------------;


DECLARE nUsuario NUMBER(3);
        nSecuencia  NUMBER(8);
BEGIN
  SELECT u.cod_usuario INTO nUsuario
  FROM USUARIOS u
  WHERE u.usuario = 'ADCAI';
  
  CAS_VACIAR_TMP(nUsuario, 'B', NULL, 0, nSecuencia);
  
  COMMIT;
END;  
/

SPOOL OFF;

EXIT;
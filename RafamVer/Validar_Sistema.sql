HOST CLS

SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
REM  PARA QUE NO VISUALICE LOS VALORES DE LAS VARIABLES 
SET VERIFY OFF
REM    
SET TERM ON
SET WRAP OFF

Set linesize 120
Col p1 format a120
Col p2 format a80

Prompt ************Recompilación de objetos Invalidos********

Spool AuxSQL\AuxValidar.sql;

--PARA RECOMPILAR PROCEDIMIENTOS,FUNCIONES Y VISTAS
SELECT 'ALTER '|| object_type || ' ' || object_name || ' COMPILE;'
FROM   user_objects
WHERE  (object_type='PROCEDURE' OR object_type='FUNCTION' OR object_type='VIEW')
       AND status='INVALID';

--PARA RECOMPILAR TRIGGERS
SELECT 'ALTER TRIGGER ' || ut.trigger_name || ' COMPILE;'
FROM 
  user_OBJECTS UO,
  USER_TRIGGERS UT
WHERE 
  UO.object_type='TRIGGER' and 
  UO.object_name=UT.trigger_name and
  UT.status='ENABLED' AND
  UO.status='INVALID';

--PARA RECOMPILAR LA DEFINICION DEL PACKAGE
SELECT 'ALTER PACKAGE ' || UO.OBJECT_NAME || ' COMPILE PACKAGE;'
FROM 
  user_OBJECTS UO
WHERE 
  UO.object_type='PACKAGE' and 
  UO.status='INVALID';

--PARA RECOMPILAR EL CUERPO DEL PACKAGE
SELECT 'ALTER PACKAGE ' || UO.OBJECT_NAME || ' COMPILE BODY;'
FROM 
  user_OBJECTS UO
WHERE 
  UO.object_type='PACKAGE BODY' and 
  UO.status='INVALID';

--asigna el grant a vistas que no lo poseen;
SELECT 'GRANT SELECT ON ' || view_name || ' TO ROL_CAS;'  
FROM user_views
MINUS       
SELECT 'GRANT SELECT ON ' || TP.table_name || ' TO ROL_CAS;'  
FROM TABLE_PRIVILEGES  TP,user_OBJECTS O 
WHERE TP.TABLE_NAME=O.OBJECT_NAME AND 
      TP.OWNER='OWNER_RAFAM' AND 
      GRANTEE='ROL_CAS' AND
      (O.OBJECT_TYPE='VIEW'); 


SPOOL OFF;

Spool AuxLogs\Objetos_Validados.log;
SET ECHO ON
@AuxSQL\AuxValidar.sql;

SELECT CONSTRAINT_NAME,TABLE_NAME FROM USER_CONSTRAINTS WHERE STATUS='DISABLED';

SPOOL OFF;

Exit;

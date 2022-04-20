PROMPT ##############################################################; 
PROMPT CONFIGURACION DE LIQUIDACION DE AUTOMOTORES; 
PROMPT ##############################################################; 
 
PROMPT Nombre del Script: ; 
PROMPT Fecha de Creacion  : 10/03/2022
PROMPT Descripción : Modificar campo MOTOR_MARCA en tabla ING_RODADOS; 
PROMPT Sistema / Area : Implantación Ingresos Públicos; 
PROMPT Responsable : HRC; 
PROMPT ______________________________________________________________; 
PROMPT Script Generado con Generador de Scripts RAFAM v1.0; 
 
 
PROMPT ##############################################################; 
PROMPT CONFIGURACION; 
PROMPT ##############################################################; 
 
SET ECHO ON; 
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY'; 
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,'; 
 
SET SERVEROUTPUT ON; 
 
PROMPT ##################################################################################; 
PROMPT INICIO - CUERPO PRINCIPAL; 
PROMPT ##################################################################################; 
ALTER TABLE owner_rafam.ING_RODADOS
MODIFY MOTOR_MARCA VARCHAR2(30);

COMMIT;
SET SERVEROUTPUT OFF;
PROMPT ##################################################################################; 
PROMPT FIN - CUERPO PRINCIPAL; 
PROMPT ##################################################################################; 
EXIT;
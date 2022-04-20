SPOOL &2\P_05_TB_Config.log;


PROMPT --- Creando Sinonimo para CONFIG ----------------------------;
CREATE PUBLIC SYNONYM CONFIG FOR owner_rafam.config;

PROMPT --- Actualizando parametros DATOS PARA LA BASE -----------------------;
UPDATE CONFIG 
SET CONTENIDO='10g'
WHERE nombre_parametro = 'VERSION_ORACLE';

UPDATE CONFIG 
SET CONTENIDO='TEMP'
WHERE nombre_parametro = 'TABLESPACE_TEMPORAL';

UPDATE CONFIG 
SET CONTENIDO='USERS'
WHERE nombre_parametro = 'TABLESPACE_USUARIOS';

DELETE PARAMETROSBASE WHERE CODIGO='SQL_TRACE';

PROMPT --- Actualizando parametro RAFAM_HOME -----------------------;
UPDATE CONFIG 
SET contenido = '\\SERVIDOR\RAFAM\'
WHERE nombre_parametro = 'RAFAM_HOME';


PROMPT --- Actualizando parametro OS_ORACLE -----------------------;
UPDATE CONFIG 
SET contenido = 'WINDOWS NT'
WHERE nombre_parametro IN ('OS_ORACLE', 'OS_RAFAM');


PROMPT --- Actualizando parametro MAQUINA_MOTOR -----------------------;
UPDATE CONFIG 
SET contenido = '\\SERVIDOR'
WHERE nombre_parametro = 'MAQUINA_MOTOR';


PROMPT --- Actualizando parametros PATH% ---------------------------;
UPDATE CONFIG 
SET contenido = 'D:\RAFAM\IMPORT_EXPORT\EXPORT'
WHERE nombre_parametro ='PATH_EXP_ORACLE';

UPDATE CONFIG 
SET contenido = 'D:\RAFAM\IMPORT_EXPORT\IMPORT'
WHERE nombre_parametro ='PATH_IMP_ORACLE';

UPDATE CONFIG 
SET contenido = 'D:\RAFAM\LOGSFILES\LIQUIDACION'
WHERE nombre_parametro ='PATH_LOGS_LIQ';


UPDATE CONFIG 
SET contenido = 'D:\RAFAM\LOGSFILES\MIGRACION'
WHERE nombre_parametro ='PATH_LOGS_MIG';

UPDATE CONFIG 
SET contenido = '\\SERVIDOR\RAFAM\IMPORT_EXPORT\EXPORT\'
WHERE nombre_parametro ='PATH_EXP_RAFAM';

UPDATE CONFIG 
SET contenido = '\\SERVIDOR\RAFAM\IMPORT_EXPORT\IMPORT\'
WHERE nombre_parametro ='PATH_IMP_RAFAM';


PROMPT --- Actualizando Tabla CAS_IMPEXP_CAB - Path_Archivo --------;
UPDATE OWNER_RAFAM.CAS_IMPEXP_CAB
SET path_archivo = 'D:\RAFAM\IMPORT_EXPORT\IMPORT'
WHERE tipo='I';

UPDATE OWNER_RAFAM.CAS_IMPEXP_CAB
SET path_archivo = 'D:\RAFAM\IMPORT_EXPORT\EXPORT'
WHERE tipo='E';

COMMIT;

SPOOL OFF;

EXIT;
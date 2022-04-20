SPOOL &2\P_02_CreateOwner.log;

PROMPT --- CREANDO OWNER_RAFAM ---------------------------------------------------------;

CREATE USER OWNER_RAFAM IDENTIFIED BY VALUES 'A376AB1C19476B52'
DEFAULT TABLESPACE DATOS 
TEMPORARY TABLESPACE temp;

GRANT RESOURCE TO OWNER_RAFAM; 
GRANT ROL_CAS TO OWNER_RAFAM;
GRANT CONNECT TO OWNER_RAFAM;
GRANT CREATE VIEW TO OWNER_RAFAM;

SPOOL OFF;

EXIT;
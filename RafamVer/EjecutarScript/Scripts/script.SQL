PROMPT ##############################################################; 
PROMPT ENCABEZADO; 
PROMPT ##############################################################; 
 
PROMPT Nombre del Script: ING_M099_INSERTO_INDICE_INTERES; 
PROMPT Fecha de Creacion  : 13/04/2022;
PROMPT Descripción : INSERTO_INDICE_INTERES; 
PROMPT Sistema / Area : Ingresos Públicos; 
PROMPT Responsable : LDA; 
PROMPT ______________________________________________________________; 
PROMPT Scipt Generado con Generador de Scripts RAFAM v1.0; 
 
 
PROMPT ##############################################################; 
PROMPT CONFIGURACION; 
PROMPT ##############################################################; 
 
SET ECHO ON; 
ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY'; 
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,'; 
 
PROMPT ##################################################################################; 
PROMPT INICIO - CUERPO PRINCIPAL; 
PROMPT ##################################################################################; 
CREATE OR REPLACE FUNCTION ing_calc_int_cuota_098
  ( pImporte        NUMBER,
    pIndice         NUMBER,
    pFechaIni       DATE,
    pFechaFin       DATE,
    pMontoAct       NUMBER,
    pMontoInt       NUMBER   DEFAULT NULL,
    pTipoComprob    NUMBER   DEFAULT NULL,
    pSituacion      VARCHAR2 DEFAULT NULL,
    pEstado         VARCHAR2 DEFAULT NULL,
    pRecurso        VARCHAR2 DEFAULT NULL,
    pAnio           NUMBER   DEFAULT NULL,
    pCuota          NUMBER   DEFAULT NULL,
    pConcepto       VARCHAR2 DEFAULT NULL,
    pCodError       OUT VARCHAR2 )
RETURN  NUMBER
IS

 Coefic              NUMBER;
 DiaIni              NUMBER;
 DiaFin              NUMBER;
 DiasM               NUMBER;
 MesAnt              NUMBER;
 MesIni              NUMBER;
 MesFin              NUMBER;
 AnioAnt             NUMBER;
 AnioIni             NUMBER;
 AnioFin             NUMBER;
 PorcInd             NUMBER;
 ValInd              NUMBER;
 vMetodo             ing_indices_tipo.metodo%TYPE;--VARCHAR2(1); FTO 03/12/2014
 MarcadorBusqueda    INTEGER;
 ultimoDia           NUMBER;

 dFechaFin           DATE;
 nDiasAct            NUMBER;
 nMtoACT             NUMBER;
 dUltimoDia          DATE;
 dFOrdenanza         DATE;--Fecha de Ordenanza '31/03/2019'
 nMontoInteres       NUMBER;
 nDifFecha           NUMBER;
 DiaOrd              NUMBER;
 MesOrd              NUMBER;
 AnioOrd             NUMBER;
 PorcIndOrd           NUMBER;
 ValIndOrd           NUMBER;
 coeficOrd           NUMBER;
 PorcIndI            NUMBER;
 ValIndI             NUMBER;
 PorcIndF            NUMBER;
 ValIndF             NUMBER;
 CoefFin             NUMBER;
 nMontoInt           NUMBER;
 nMontoIA            NUMBER;
 nDFIniFOrd          DATE;
 nDifVAL             NUMBER;



--PROGRAMADOR       Versión       Bug             Fecha Creación      Fecha Modificación        Descripción
--LDA                  7.4.0       0000              24/09/2018          13/12/2019              Ajustes error en el mes 12
--FTO                  7.4.0       0000              24/09/2018          14/05/2019              Ajustes Modificación de Ordenanza en 04/2019
--FTO                  7.4.0       0000              24/09/2018          03/05/2019              Modificación de Ordenanza en 04/2019
--FTO                  7.4.0       0000              24/09/2018          24/09/2018              Creación

BEGIN
 pCodError:='*';
 Coefic := 0 ;

 dFOrdenanza:=TO_DATE('01/04/2019','DD/MM/YYYY');--Fecha de Ordenanza. Entró en vigencia a partir del 01/04/2019

 SELECT TO_CHAR(dFOrdenanza,'YYYY') INTO AnioOrd FROM DUAL;
 SELECT TO_CHAR(dFOrdenanza,'MM')   INTO MesOrd FROM DUAL;
 SELECT TO_CHAR(dFOrdenanza,'DD')   INTO DiaOrd FROM DUAL;

 nDifFecha:= dFOrdenanza-pFechaFin;--Diferencia entre la fecha de ordenanza y la fecha de pago.

 --SELECT to_char(LAST_DAY(sysdate),'DD') INTO ultimoDia FROM DUAL;
 ultimoDia:=30; --24/08/2011, Seguimos tomando como último día "30",
                --y no la cantidad de días reales del mes, tras evaluar con el Area Contable (este mismo criterio usa AFIP).
 ultimoDia:= ultimoDia*100;

 nDiasAct := CAS_GET_Parametro_Config('Ingresos Públicos','DIA_ACTUALIZACION');--10


 IF pIndice <> 0 THEN

    --FTO 13/05/2019
      SELECT porcentaje, valor_indice INTO PorcIndOrd,ValIndOrd
      FROM ING_INDICES
      WHERE indice = pIndice AND anio = AnioOrd AND mes = MesOrd-1;
    --Fin FTO 13/05/2019

    MarcadorBusqueda := 0;
    -- 1 .Obtengo anio,mes y dia de la fecha de inicio(fecha vto)
    SELECT TO_CHAR(pFechaIni,'YYYY') INTO AnioIni FROM DUAL;
    SELECT TO_CHAR(pFechaIni,'MM')   INTO MesIni FROM DUAL;
    SELECT TO_CHAR(pFechaIni,'DD')   INTO DiaIni FROM DUAL;

    SELECT porcentaje, valor_indice INTO PorcIndI,ValIndI
    FROM ING_INDICES
    WHERE indice = pIndice AND anio = AnioIni AND mes = MesIni;

    -- Selecciono método si es C (por coeficientes)
    -- Tiene distinto tratamiento
    SELECT metodo INTO vMetodo
    FROM ING_INDICES_TIPO
    WHERE codigo = pIndice;

    -- 2 . Busco el indice en la tabla ING_INDICES
    -- MarcadorBusqueda := 1;
    SELECT  porcentaje, valor_indice INTO PorcInd, ValInd
    FROM ING_INDICES
    WHERE indice = pIndice AND anio = AnioIni AND mes= MesIni;


    --  3 . Obtengo anio,mes y dia de la fecha de fin
    SELECT TO_CHAR(pFechaFin,'YYYY') INTO AnioFin FROM DUAL;
    SELECT TO_CHAR(pFechaFin,'MM') INTO MesFin FROM DUAL;
    SELECT TO_CHAR(pFechaFin,'DD') INTO DiaFin FROM DUAL;

    SELECT porcentaje, valor_indice INTO PorcIndF,ValIndF
    FROM ING_INDICES
    WHERE indice = pIndice AND anio = AnioFin AND mes = MesFin;

    IF AnioIni = AnioFin AND MesIni = MesFin THEN
        Coefic := PorcInd * ( DiaFin - DiaIni)/ultimoDia;
        --FTO 30/04/2019 Se calcula entre la fecha de vto y el ultimo dia del mes correspondiente
        IF pFechaIni > dFOrdenanza then
          IF DiaFin - DiaIni>0 THEN
             Coefic:=0.02;
          END IF;
        END IF;
        --Fin FTO 30/04/2019
    ELSE
        Coefic := - ValInd;
        IF PorcInd <> 0 THEN
            SELECT  TO_CHAR(LAST_DAY(pFechaIni),'DD') INTO DiasM FROM DUAL;

            IF vMetodo <> 'C' THEN
                Coefic := Coefic + PorcInd * ( DiasM - DiaIni)/ultimoDia;
            END IF;
        END IF;

        IF MesFin > 1 THEN
            AnioAnt := AnioFin;
            --FTO 24/09/2018
            --MesAnt := MesFin - 1;
            IF DiaFin <= nDiasAct THEN --nDiasAct:=10 ------------------------FTO 30/04/2019
                IF pFechaIni < dFOrdenanza THEN
                    MesAnt := MesFin - 1; -- CON DEUDA INFERIOR A LA FECHA DE VIGENCIA DE ORDENANZA
                ELSE
                    MesAnt := MesFin;
                END IF;
            ELSE
                IF pMontoAct=0 THEN
                    --INICIO - LDA    13/12/2019              Ajustes error en el mes 12
                    IF MesFin < 12 THEN
                        MesAnt := MesFin+1;
                    ELSE
                        MesAnt := MesFin;
                    END IF;
                    --FIN - LDA    13/12/2019              Ajustes error en el mes 12
                ELSE
                   MesAnt := MesFin;
                END IF;
            END IF;
            --Fin FTO 24/09/2018
        ELSE
            --FTO 07/05/2019 Caso: FVTO:19/12/2018. Si FPago está entre el 10/01 y 10/02 se cobra un 3%
            --AnioAnt := AnioFin -1;
            --MesAnt := 12;
            IF DiaFin >= nDiasAct THEN
                --dbms_output.put_line('DiaFin > nDiasAct ');
                AnioAnt := AnioFin;
                MesAnt := MesFin;
            ELSE
                --dbms_output.put_line('ELSE de DiaFin > nDiasAct ');
                AnioAnt := AnioFin -1;
                MesAnt := 12;
            END IF;
        END IF;

        -- 4 Busqueda de indice y porcentaje para el mes final
        MarcadorBusqueda := 2;
        IF vMetodo <> 'C' THEN
            SELECT porcentaje, valor_indice INTO PorcInd,ValInd
            FROM ING_INDICES
            WHERE indice = pIndice AND anio = AnioAnt AND mes = MesAnt;
        ELSE
            SELECT porcentaje, valor_indice INTO PorcInd, ValInd
            FROM ING_INDICES
            WHERE indice = pIndice AND anio = Aniofin AND mes = Mesfin;
        END IF;

        IF vMetodo <> 'C' THEN
            Coefic := ValInd + Coefic;
--            dbms_output.put_line('vMetodo:' || vMetodo || ' ' );
--            dbms_output.put_line('AnioAnt:' || AnioAnt || ' ' );
--            dbms_output.put_line('MesAnt:' || MesAnt || ' ' );
--            dbms_output.put_line('ValInd:' || ValInd || ' ' );
--            dbms_output.put_line('Coefic:' || Coefic || ' ' );
        ELSE
            IF MesAnt=MesIni AND AnioAnt=AnioIni THEN
                coefic := 1 + (PorcInd * ( DiasM - DiaIni)/ultimoDia);
            ELSE
                IF Coefic <> 0 then
                    Coefic := (-1 * ValInd/Coefic ) ;
                ELSE
                    Coefic := 0;
                END IF;
            END IF;
        END IF;

        MarcadorBusqueda := 3;
        SELECT porcentaje, valor_indice INTO PorcInd,ValInd
        FROM ING_INDICES
        WHERE indice = pIndice AND anio = AnioFin AND mes = MesFin;

        IF vMetodo <> 'C' THEN
            Coefic := Coefic + (PorcInd * diaFin /ultimoDia);
        ELSE
            Coefic := Coefic * (1 + (PorcInd * diaFin /ultimoDia));
        END IF;

        IF vMetodo = 'C' THEN
            Coefic := Coefic - 1;
        END IF;

    END IF;

    IF Coefic < 0 THEN
        Coefic := 0 ;
    END IF;
 END IF; --pIndice <> 0

 nDifVAL:=ValIndOrd-ValIndI;

-- RETURN (pImporte+pMontoAct) * Coefic;
    IF pFechaIni > dFOrdenanza THEN--Se cobra el 4% sobre el Monto Origen
       nMontoInteres:= (pImporte*Coefic);
    ELSE
         --nDifFecha: Diferencia entre la fecha de ordenanza y la fecha de pago.
        IF (dFOrdenanza-pFechaFin > 20) THEN --Para aquellos periodos cuya fvto se inferior al 10/03/2019
            nMontoInteres:= (PImporte+pMontoAct)* Coefic;
        ELSE
           nMontoInteres:=0;
           IF Coefic <> 0 THEN
             IF ((dFOrdenanza - pFechaIni) < 20) THEN
               nMontoInteres:=PImporte*Coefic;
             ELSE
               nMontoInteres:=PImporte*Coefic + pMontoAct*nDifVAL ;
             END IF;
           END IF;
        END IF;
    END IF;

   RETURN ROUND(NVL(nMontoInteres, 0), 2);

 -- FLO Bug Nro. 6010    22/01/2013
 /*    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 0;
    WHEN OTHERS THEN
       pCodError :='ERROR: Función ing_calc_int_cuota_nueva';
       raise_application_error(-20140, SQLCODE || SQLERRM || pCodError);
 */
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  pCodError := 'No se encontró el Índice de Interés ' ||TO_CHAR(pIndice) || ' para el Año ';
  IF    MarcadorBusqueda = 0 THEN
    pCodError :=SQLCODE || SQLERRM || '. ERROR: Función ING_CALC_INT_CUOTA_098';
  ELSIF MarcadorBusqueda = 1 THEN
    pCodError := pCodError || TO_CHAR(AnioIni) ||' Mes ' || TO_CHAR(MesIni);
  ELSIF MarcadorBusqueda = 2 THEN
    pCodError := pCodError || TO_CHAR(AnioAnt) ||' Mes ' || TO_CHAR(MesAnt);
  ELSIF MarcadorBusqueda = 3 THEN
    pCodError := pCodError ||TO_CHAR(AnioFin) || ' Mes ' || TO_CHAR(MesFin);
  END IF;
  RETURN 0;

 WHEN OTHERS THEN
    pCodError :='. ERROR: Función ING_CALC_INT_CUOTA_098';
    raise_application_error(-20140, SQLCODE || SQLERRM || pCodError);
--Fin  FLO Bug Nro. 6010    22/01/2013

END;
/
GRANT EXECUTE ON ing_calc_int_cuota_098 TO ROL_CAS
/
CREATE OR REPLACE FUNCTION ing_calc_int_cuota_080
   ( pImporte        NUMBER,
     pIndice         NUMBER,
     pFechaIni       DATE,
     pFechaFin       DATE,
     pMonto_Act      NUMBER,
     pMontoInt       NUMBER   DEFAULT NULL,
     pCodError       OUT VARCHAR2)
RETURN  NUMBER
IS
--PROGRAMADOR  Versión      Bug              Fecha Creación      Fecha Modificación    Descripción
--LDA          7.4.0     000XXXX                    23/06/2021          23/06/2021              Función creada para determinar el interés en Pehuajó

--Tomo el porcentaje de interes definido en la tabla de indices y lo divido por 30 para determinar el porcentaje de interes diario.
-- Al valor anterior lo multiplico por el monto para determinar el Interes diario.
-- Al valor anterior lo multiplico por la cantidad de días desde la fecha de vto (pFechaIni) al día de la fecha (pFechaFin).

nTotalDias         NUMBER;
nPorcInd            NUMBER;
nPorcInteresDiario NUMBER;
nMtoInteresDiario   NUMBER;
nInteres           NUMBER; --Refleja la suma de todos los porcentajes (Recargo, multas e intereses)
nMeses             NUMBER;

AnioFin             NUMBER;
MesFin             NUMBER;
DiaFin             NUMBER;

ultimoDia           NUMBER:=30;
BEGIN
    
    nTotalDias:=0;
    pCodError:='*';
    --  Obtengo anio,mes y dia de la fecha de fin
    SELECT TO_CHAR(pFechaFin,'YYYY') INTO AnioFin FROM DUAL;
    SELECT TO_CHAR(pFechaFin,'MM') INTO MesFin FROM DUAL;
    SELECT TO_CHAR(pFechaFin,'DD') INTO DiaFin FROM DUAL;

    nTotalDias:=ing_dias_entre_fechas(pFechaFin,pFechaIni);
    
    SELECT porcentaje/100 INTO nPorcInd FROM ING_INDICES  WHERE indice = pIndice AND anio = Aniofin AND mes = Mesfin;
    
    nPorcInteresDiario:= nPorcInd/ultimoDia;
    nMtoInteresDiario:= (pImporte+ NVL(pMonto_Act,0)) * nPorcInteresDiario;
    
    --INTERES
    nInteres:= nTotalDias * nMtoInteresDiario;
    RETURN nInteres;
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20140, SQLCODE || SQLERRM ||'ERROR: Función ING_CALC_INT_CUOTA_080' );
END;
/
GRANT EXECUTE ON ing_calc_int_cuota_080 TO ROL_CAS
/
CREATE OR REPLACE FUNCTION ing_calc_int_cuota_099
   ( pImporte        NUMBER,
     pIndice         NUMBER,
     pFechaIni       DATE,
     pFechaFin       DATE,
     pMonto_Act      NUMBER,
     pMontoInt       NUMBER   DEFAULT NULL,
     pCodError       OUT VARCHAR2)
RETURN  NUMBER
IS
--PROGRAMADOR  Versión      Bug              Fecha Creación      Fecha Modificación    Descripción
--LDA          7.4.0     000XXXX                    13/04/2022          13/04/2022              Función creada para determinar el interés en San Pedro

--Tomo el porcentaje de interes definido en la tabla de indices y lo divido por 30 para determinar el porcentaje de interes diario.
-- Interes a aplicar = Diferencia de dias * Interes acumulado / Días totales
nDiferenciaDias NUMBER;
nTotalDias         NUMBER;
nDesde              NUMBER;
nHasta              NUMBER;
nPorcAcumulado NUMBER;
nInteres           NUMBER; 
AnioFin             NUMBER;
MesFin             NUMBER;
DiaFin             NUMBER;
AnioIni             NUMBER;
MesIni             NUMBER;
DiaIni             NUMBER;

BEGIN
    
    nTotalDias:=0;
    pCodError:='*';
    nTotalDias:= ing_dias_entre_fechas(last_day(pFechaFin),TRUNC(pFechaini, 'MM'))+1;
--    DBMS_OUTPUT.PUT_LINE( 'LastDayFechaFin: ' || last_day(pFechaFin) || ' - ');
--    DBMS_OUTPUT.PUT_LINE( 'FirstDayFechaIni: ' || TRUNC(pFechaini, 'MM') || ' - ');
--    DBMS_OUTPUT.PUT_LINE( 'nTotalDias: ' || nTotalDias || ' - ');
    nDiferenciaDias:= ing_dias_entre_fechas(pFechaFin,pFechaIni);
    
    -- 1 .Obtengo anio,mes y dia de la fecha de inicio(fecha vto)
    SELECT TO_CHAR(pFechaIni,'YYYY') INTO AnioIni FROM DUAL;
    SELECT TO_CHAR(pFechaIni,'MM')   INTO MesIni FROM DUAL;
    SELECT TO_CHAR(pFechaIni,'DD')   INTO DiaIni FROM DUAL;
    
    --  Obtengo anio,mes y dia de la fecha de fin
    SELECT TO_CHAR(pFechaFin,'YYYY') INTO AnioFin FROM DUAL;
    SELECT TO_CHAR(pFechaFin,'MM') INTO MesFin FROM DUAL;
    SELECT TO_CHAR(pFechaFin,'DD') INTO DiaFin FROM DUAL;
    
    nDesde := AnioIni * 1000 + MesIni;
    nHasta := AnioFin * 1000 + MesFin;
        
    SELECT SUM(PORCENTAJE) INTO nPorcAcumulado FROM ING_INDICES where indice = pIndice and (anio*1000+mes >= nDesde) and (anio*1000+mes<=nHasta);
    
    --INTERES
    nInteres:= nDiferenciaDias * nPorcAcumulado/nTotalDias;
--    DBMS_OUTPUT.PUT_LINE( 'nDiferenciaDias: ' || nDiferenciaDias || ' - ');
--    DBMS_OUTPUT.PUT_LINE( 'nPorcAcumulado: ' || nPorcAcumulado || ' - ');
--    DBMS_OUTPUT.PUT_LINE( 'Interes a Aplicar: ' || nInteres || ' - ');
    
    nInteres:= nInteres * pImporte/100;
    RETURN nInteres;
EXCEPTION  WHEN OTHERS THEN
    raise_application_error(-20140, SQLCODE || SQLERRM ||'ERROR: Función ING_CALC_INT_CUOTA_080' );
END;
/
GRANT EXECUTE ON ing_calc_int_cuota_099 TO ROL_CAS
/
CREATE OR REPLACE FUNCTION ing_calc_int_cuota_135
  ( pImporte        NUMBER,
    pIndice         NUMBER,
    pFechaIni       DATE,
    pFechaFin       DATE,
    pMontoAct       NUMBER,
    pMontoInt       NUMBER   DEFAULT NULL,
    pTipoComprob    NUMBER   DEFAULT NULL,
    pSituacion      VARCHAR2 DEFAULT NULL,
    pEstado         VARCHAR2 DEFAULT NULL,
    pRecurso        VARCHAR2 DEFAULT NULL,
    pAnio           NUMBER   DEFAULT NULL,
    pCuota          NUMBER   DEFAULT NULL,
    pConcepto       VARCHAR2 DEFAULT NULL,
    pCodError       OUT VARCHAR2 )
RETURN  NUMBER
IS

nCantMeses          NUMBER;
InteresMuni         NUMBER;
 DiaIni              NUMBER;
 DiaFin              NUMBER;
 MesAnt              NUMBER;
 MesIni              NUMBER;
 MesFin              NUMBER;
 AnioAnt             NUMBER;
 AnioIni             NUMBER;
 AnioFin             NUMBER;
 nCantM              NUMBER;

--PROGRAMADOR       Versión       Bug             Fecha Creación      Fecha Modificación        Descripción
--FTO               7.4.0      0000000             12/02/2015          04/01/2022              Cada cambio de mes se suma un 4.5%

BEGIN
    pCodError:='*';
    --nCantMeses:=CEIL(MONTHS_BETWEEN(pFechaFin,pFechaIni));
    --InteresMuni:=(nCantMeses+1)*(pImporte+ NVL(pMontoAct,0))* (9/100);


    --FTO 04/01/2022
    SELECT TO_CHAR(pFechaIni,'YYYY') INTO AnioIni FROM DUAL;
    SELECT TO_CHAR(pFechaIni,'MM')   INTO MesIni FROM DUAL;
    SELECT TO_CHAR(pFechaIni,'DD')   INTO DiaIni FROM DUAL;

    SELECT TO_CHAR(pFechaFin,'YYYY') INTO AnioFin FROM DUAL;
    SELECT TO_CHAR(pFechaFin,'MM') INTO MesFin FROM DUAL;
    SELECT TO_CHAR(pFechaFin,'DD') INTO DiaFin FROM DUAL;



   nCantMeses:=CEIL(MONTHS_BETWEEN(pFechaFin,pFechaIni));

   InteresMuni:=0; --No está vencida

   IF AnioIni = AnioFin  THEN
         if  MesIni = MesFin then
            if DiaIni < DiaFin then
              nCantM:=nCantMeses;
            end if;
         ELSE --mes diferente
           if MesIni<MesFin then
               nCantM:=nCantMeses;
               if  DiaIni>DiaFin THEN
                 nCantM:=nCantMeses+1;
               end if;
           else
              InteresMuni:=0; --No vencido
           end if;
         end if;
    ELSE --Cambio de AÑO
          nCantM:=nCantMeses;
          if  DiaIni  > DiaFin THEN
             nCantM:=nCantMeses+1;
          end if;
    end if;

    InteresMuni:=(nCantM)*(pImporte+ NVL(pMontoAct,0))* (4.5/100); --Calculainteres

    RETURN ROUND(NVL(InteresMuni,0),4);


EXCEPTION WHEN OTHERS THEN
    pCodError :='. ERROR: Función ING_CALC_INT_CUOTA_135';
    raise_application_error(-20140, SQLCODE || SQLERRM || pCodError);
END;
/
GRANT EXECUTE ON ing_calc_mul_cuota_131 TO rol_cas
/
CREATE OR REPLACE 
FUNCTION ing_calc_int_cuota_115
   ( pImporte        NUMBER,
     pIndice         NUMBER,
     pFechaIni       DATE,
     pFechaFin       DATE,
     pMonto_Act      NUMBER,
     pMontoInt       NUMBER   DEFAULT NULL,
     pTipoComprob    NUMBER   DEFAULT NULL,
     pSituacion      VARCHAR2 DEFAULT NULL,
     pEstado         VARCHAR2 DEFAULT NULL,
     pRecurso         VARCHAR2 DEFAULT NULL,
     pAnio           NUMBER   DEFAULT NULL,
     pCuota          NUMBER   DEFAULT NULL,
     pConcepto       VARCHAR2 DEFAULT NULL,
     pCodError       OUT VARCHAR2)
RETURN  NUMBER
IS
--PROGRAMADOR       Versión       Bug             Fecha Creación      Fecha Modificación          Descripción
--FTO               007_004                                            28/10/2020                   Agrego NVL
--NOC               007_004                                            16/10/2020                   Se copió la de LF
--FTO                 7.3.1       0000               ********          03/12/2014                   Se modificó declaración de la Variable vMetodo.
--FLO                007_001     0005831             ********          11/03/2013                   Se agregaron los  parámetros (pMontoInt,....,pConcepto)


Coefic              NUMBER;
AnioFin             NUMBER;
MesFin              NUMBER;
DiaFin              NUMBER;
Dia_O               NUMBER;
Mes_O               NUMBER;
Anio_O              NUMBER;
Dias_Mes_FI         NUMBER;
Dias_Mes_FF         NUMBER;
Anio_Ant            NUMBER;
Mes_Ant             NUMBER;
Porc_Ind            NUMBER;
MarcadorBusqueda    INTEGER;
Val_Ind             NUMBER;
vMetodo             ing_indices_tipo.metodo%TYPE;--VARCHAR2(1); FTO 03/12/2014
CantMes             NUMBER;
Interes             NUMBER;
IntXDiasFin         NUMBER;
IntXDiasIni         NUMBER;
IntXMes             NUMBER;
pFechaAux           DATE;
CantDias            NUMBER;
CantDiasIni         NUMBER;
CantDiasfin         NUMBER;
Error               VARCHAR2(50);
BEGIN

/* AGM 28/06/2006
Función que realiza el cálculo del interés
para el monto y las fechas dadas, usando
el indice pIndice.

Fecha de Creacion: 28/06/2006
Ultima Modificacion:20/07/2007
*/

    MarcadorBusqueda := 1;
    pCodError:='*';

    -- 1 .Obtengo anio,mes y dia de la fecha de inicio(fecha vto)
    SELECT TO_CHAR(pFechaIni,'YYYY') INTO Anio_O FROM DUAL;
    SELECT TO_CHAR(pFechaIni,'MM') INTO Mes_O FROM DUAL;
    SELECT TO_CHAR(pFechaIni,'DD') INTO Dia_O FROM DUAL;



    -- 2 . Busco el indice en la tabla ING_INDICES
    MarcadorBusqueda := 1;
    SELECT  porcentaje, valor_indice
    INTO Porc_Ind, Val_Ind
    FROM ING_INDICES
    WHERE indice = pIndice
      AND anio = Anio_O
      AND mes = Mes_O;

    --  3 . Obtengo anio,mes y dia de la fecha de fin
    SELECT TO_CHAR(pFechaFin,'YYYY') INTO AnioFin FROM DUAL;
    SELECT TO_CHAR(pFechaFin,'MM') INTO MesFin FROM DUAL;
    SELECT TO_CHAR(pFechaFin,'DD') INTO DiaFin FROM DUAL;

    SELECT  TO_CHAR(LAST_DAY(pFechaIni),'DD')
    INTO Dias_Mes_FI -- Tiene la candidad de dias del mes de la fecha de vto
    FROM DUAL;

    SELECT  TO_CHAR(LAST_DAY(pFechaFin),'DD')
    INTO Dias_Mes_FF -- Tiene la candidad de dias del mes de la fecha de Actualización
    FROM DUAL;


    IF Anio_O = AnioFin AND Mes_O = MesFin THEN
         --Coefic := (DiaFin - Dia_O)*Porc_Ind/30;
        CantDiasFin:=DiaFin - Dia_O;
        Coefic := CantDiasFin *Porc_Ind/Dias_Mes_FF * pImporte/100;
        Interes:= Coefic;
    ELSE

        IF Porc_Ind <> 0 THEN
         /*   SELECT  TO_CHAR(LAST_DAY(pFechaIni),'DD')
            INTO Dias_Mes_FI -- Tiene la candidad de dias del mes de la fecha de vto
            FROM DUAL;

            SELECT  TO_CHAR(LAST_DAY(pFechaFin),'DD')
            INTO Dias_Mes_FF -- Tiene la candidad de dias del mes de la fecha de Actualización
            FROM DUAL;
        */
            CantMes:=ING_GET_CANT_DIAS_FECHAS(pFechaIni,pFechaFin,Error);
            CantDiasIni:=Dias_Mes_FI - Dia_O;
            CantDiasFin:=DiaFin;

            --calculo del interers
            IntXMes:=NVL(Porc_Ind,0) * CantMes * NVL(pImporte,0)/100;
            IntXDiasIni:=CantDiasIni * NVL(Porc_Ind,0)/Dias_Mes_FI * NVL(pImporte,0)/100;
            IntXDiasFin:=CantDiasFin * NVL(Porc_Ind,0)/Dias_Mes_FF * NVL(pImporte,0)/100;

            Interes:=NVL(IntXMes,0) + NVL(IntXDiasIni,0) + NVL(IntXDiasFin,0);
            --Interes:= Coefic * (pImporte + pMonto_Act)/ 100;

        END IF;

    End if;

    IF Coefic < 0 THEN
        Coefic := 0 ;
    END IF;

    RETURN NVL(Interes,0);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF MarcadorBusqueda=1 THEN --no se encontro un indice para la fecha inicio
       --raise_application_error(-20140,'Indice no encontrado.' || to_char(pIndice)
       --                        || ' Anio = ' || to_char(Anio_O)
       --                        || ' Mes = ' || to_char(Mes_O));
       pCodError := 'No se encontró el Ind. de Interés : ' ||TO_CHAR(pIndice) || CHR(13)||
            ' para el Año : ' || TO_CHAR(Anio_O) || CHR(13)||
            ' Mes : ' || TO_CHAR(Mes_O);

          END IF;
      RETURN 0;

    WHEN OTHERS THEN
        raise_application_error(-20140, SQLCODE || SQLERRM ||'ERROR: funcion ing_calc_int_cuota_115' );

END; -- Function ING_CALC_INT_CUOTA_LF
/
GRANT EXECUTE ON ing_calc_int_cuota_115 TO rol_cas
/
CREATE OR REPLACE FUNCTION ing_calc_int_cuota_094
   ( pImporte        NUMBER,
     pIndice         NUMBER,
     pFechaIni       DATE,
     pFechaFin       DATE,
     pMonto_Act      NUMBER,
     pMontoInt       NUMBER   DEFAULT NULL,
     pTipoComprob    NUMBER   DEFAULT NULL,
     pSituacion      VARCHAR2 DEFAULT NULL,
     pEstado         VARCHAR2 DEFAULT NULL,
     pRecurso        VARCHAR2 DEFAULT NULL,
     pAnio           NUMBER   DEFAULT NULL,
     pCuota          NUMBER   DEFAULT NULL,
     pConcepto       VARCHAR2 DEFAULT NULL,
     pCodError       OUT VARCHAR2)
RETURN  NUMBER
IS
--PROGRAMADOR  Versión      Bug              Fecha Creación      Fecha Modificación    Descripción
--FMO           7.4          0000000           28/12/2017           28/12/2017               Creación de función

nTotalDias         NUMBER;
nMultiplicador     NUMBER;
nInteres           NUMBER;

BEGIN

    nTotalDias:=0;
    pCodError:='*';

    nTotalDias:=ing_dias_entre_fechas(pFechaFin,pFechaIni);
    -- TODO: Generalizar vía estructuras de datos

    IF nTotalDias <> 0 THEN
      nMultiplicador :=(0.02 * 12 ) / 365 * nTotalDias; -- Basado en un 2% mensual
      nInteres:= pImporte * nMultiplicador;
    END IF;

    RETURN NVL(nInteres,0);

EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20140, SQLCODE || SQLERRM ||'ERROR: Función ING_CALC_INT_CUOTA_094' );

END;
/
GRANT EXECUTE ON ing_calc_int_cuota_094 TO rol_cas
/
CREATE OR REPLACE 
FUNCTION ing_calc_int_cuota_131
  ( pImporte        NUMBER,
    pIndice         NUMBER,
    pFechaIni       DATE,
    pFechaFin       DATE,
    pMontoAct       NUMBER,
    pMontoInt       NUMBER   DEFAULT NULL,
    pTipoComprob    NUMBER   DEFAULT NULL,
    pSituacion      VARCHAR2 DEFAULT NULL,
    pEstado         VARCHAR2 DEFAULT NULL,
    pRecurso        VARCHAR2 DEFAULT NULL,
    pAnio           NUMBER   DEFAULT NULL,
    pCuota          NUMBER   DEFAULT NULL,
    pConcepto       VARCHAR2 DEFAULT NULL,
    pCodError       OUT VARCHAR2 )
RETURN  NUMBER
IS

InteresMuni         NUMBER;
nCantMeses          NUMBER(5,2);
error               varchar(50);
nIntMensual         NUMBER;

--PROGRAMADOR       Versión       Bug             Fecha Creación      Fecha Modificación        Descripción
--FTO               7.4.1       0000000             09/02/2021          09/02/2021              Creación

BEGIN

        nIntMensual := TO_NUMBER(UPPER(NVL(cas_get_parametro_config('Ingresos Públicos','CTA_CTE_INT_MENSUAL_X_RECARGO_POR_MORA'),'0')))/100;

        nCantMeses:=ING_GET_CANT_DIAS_FECHAS(pFechaFin,pFechaIni,pCodError);

        nCantMeses:=nCantMeses*-1;

        if nCantMeses=0 then
            nCantMeses:=MONTHS_BETWEEN(pFechaFin,pFechaIni);
            if nCantMeses>0 then
               InteresMuni:=(pImporte+ NVL(pMontoAct,0))*nIntMensual;
            end if;
        else
            InteresMuni:=nCantMeses*(pImporte+ NVL(pMontoAct,0))*nIntMensual;
        end if;

    RETURN nvl(InteresMuni,0);

EXCEPTION WHEN NO_DATA_FOUND THEN
    pCodError := 'No se encontró el Índice de Interés ' ||TO_CHAR(pIndice) ;
    RETURN 0;
WHEN OTHERS THEN
    pCodError :='. ERROR: Función ING_CALC_INT_CUOTA_131';
    raise_application_error(-20140, SQLCODE || SQLERRM || pCodError);
END;
/
GRANT EXECUTE ON ing_calc_int_cuota_131 TO rol_cas
/
CREATE OR REPLACE 
FUNCTION ing_calc_int_cuota
( pImporte        NUMBER,
  pIndice         NUMBER,
  pFechaIni       DATE,
  pFechaFin       DATE,
  pMontoAct       NUMBER,
  pMontoInt       NUMBER   DEFAULT NULL,
  pTipoComprob    NUMBER   DEFAULT NULL,
  pNroComprob     NUMBER   DEFAULT NULL,
  pSituacion      VARCHAR2 DEFAULT NULL,
  pEstado         VARCHAR2 DEFAULT NULL,
  pRecurso        VARCHAR2 DEFAULT NULL,
  pAnio           NUMBER   DEFAULT NULL,
  pCuota          NUMBER   DEFAULT NULL,
  pConcepto       VARCHAR2 DEFAULT NULL,
  pCodError       OUT VARCHAR2)

RETURN  NUMBER
IS
--PROGRAMADOR       Versión       Bug             Fecha Creación      Fecha Modificación          Descripción
--LDA                7.4         0000000             ********          23/06/2021                 Se crea función de Cálculo para San Pedro ING_CALC_INT_CUOTA_099
--FTO                7.4         0000000             ********          04/01/2022                 Se crea función de Cálculo para Hurlingham ING_CALC_INT_CUOTA_135
--LDA                7.4         0000000             ********          23/06/2021                 Se crea función de Cálculo para Pehuajó ING_CALC_INT_CUOTA_080
--FTO                7.4         0000000             ********          17/02/2021                 Se crea función de Cálculo para San Miguel ING_CALC_INT_CUOTA_131
--NOC                7.4         0000000             ********          16/10/2020                 Se crea funcion para Ensenada ING_CALC_INT_CUOTA_115
--FTO                7.4         0000000             ********          24/09/2018                 Se crea función de Cálculo para San Nicolás ING_CALC_INT_CUOTA_098
--FMO                7.4         0000000             ********          29/12/2017                 Se crea función de Cálculo para San Andrés de Giles
--NOC                7.4         0000000             ********          04/09/2017                 Se crea función de Cálculo para Esteban Echeverria
--NOC                7.4         0000000             ********          16/06/2017                 Se crea función de Cálculo para Magdalena y se agregó el parámetro Nro.Comprobante
--LDA                7.4         0007832             12/02/2015        07/11/2016                 Se crea función de Cálculo para Pila
--NOC                7.3.2       0000000             ********          21/01/2016                 Se crea función de Cálculo para Libertador San Martin (Entre Rios)
--FTO                7.3.2       0000000             ********          14/08/2015                 Faltaba el NVL para el cálculo de Interés de SM.
--LDA                7.3.57      0005831             12/02/2015        12/02/2015                 Se crea función de Cálculo para Trenque Lauquen
--AGM                7.3.1       0000000             ********          29/01/2015                 Modificación de la forma de cálculo de Interés de SM.
--FTO                7.3.1       0000000             ********          04/12/2014                 Se agregó 'CONSTANTE_2PORCIENTO' para el cálculo de Interés de SM.
--FMO                7.3.1       0000000             ********          03/12/2014                 Se agregó el cálculo de Interés para San Miguel.
--LDA                7.3.50      0006365             ********          20/08/2014                 Se configura un nuevo interés escalonado para Ezeiza.
--LDA                7.1         0006151             ********          30/04/2013                 Se configura un nuevo interés mensual para San Miguel y se toma como genérico.
--FLO                007_001     0005831             ********          11/03/2013                 Se agregaron los  parámetros (pMontoInt,....,pConcepto)
-- ?                 6.7         0003735             ********          24/08/2011                 *****************************
-- ?                 6.6.1       0003735             ********          24/08/2011                 *****************************
-- ?                 6.6         0003735             ********          16/06/2011                 *****************************

Coefic              NUMBER;
MesAnt              NUMBER;
MesIni              NUMBER;
MesFin              NUMBER;
AnioAnt             NUMBER;
AnioIni             NUMBER;
AnioFin             NUMBER;
TipoMetodo          ing_indices_tipo.metodo%TYPE;--VARCHAR2(1); FTO 03/12/2014
MarcadorBusqueda    INTEGER;
Proc                VARCHAR2(50);
InteresMuni         NUMBER(15,2);
total               NUMBER;
nCantMeses          NUMBER(5,2);
error               varchar(50);

BEGIN
    --Se asume que la FechaFin es mayor o igual a FechaIni
    MarcadorBusqueda := 1;
    pCodError:='*';
    --AGM 29/06/2006
    /* Obtengo el metodo asociado al interes*/
    IF pIndice = 0 THEN
        Coefic := 0;
        RETURN 0;
    ELSE
        BEGIN
        SELECT UPPER(METODO) INTO TipoMetodo FROM ING_INDICES_TIPO WHERE CODIGO=pIndice;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            pCodError := 'No se encontró el Ind. de Interes : ' ||TO_CHAR(pIndice);
            RETURN 0;
        END;

        -- Obtengo el procedimiento que va utilizar
        BEGIN
        SELECT UPPER(PROCEDIMIENTO) INTO Proc FROM ING_INDICES_METODOS WHERE METODO=TipoMetodo;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            pCodError := 'No se encontró el Método para el Indice : ' ||TO_CHAR(pIndice);
            RETURN 0;
        END;

        BEGIN -- Begin 3
            -- AGM 21/02/2007
            IF TipoMetodo = 'D' THEN          --"D": Método Directo
                /*CALCULA EL INTRES DE ACUERDO A LOS PORCENTAJES DE LOS MESES*/
                InteresMuni:=ING_CALC_INT_CUOTA_D(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                RETURN InteresMuni;
            END IF;
            -- FIN AGM 21/02/2007
            --LDA 6151
            IF TipoMetodo = 'M' THEN          --"D": Cálculo de Interés Mensual
                /*CALCULA EL INTRES MENSUAL DE ACUERDO A LOS PORCENTAJES DE LOS MESES*/
                InteresMuni:= ING_CALC_INT_CUOTA_MENSUAL(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pAnio,pCuota,pRecurso,pCodError);
                RETURN InteresMuni;
            END IF;
            --FIN LDA 6151
            IF Proc = 'ING_CALC_INT_CUOTA_LF' THEN
                /*CALCULA EL INTRES PARA LAS FLORES*/
                InteresMuni:=ING_CALC_INT_CUOTA_LF( pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError );
                RETURN InteresMuni;
            --NOC 24/04/2016
            ELSIF Proc = 'ING_CALC_INT_CUOTA_MAGDA' THEN
               /*CALCULA EL INTERES PARA MAGDALENA*/
               InteresMuni:=ING_CALC_INT_CUOTA_MAGDA(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pCodError,pAnio,pCuota,pRecurso,pTipoComprob,pNroComprob);
               RETURN InteresMuni;
            --FIN NOC ------
            ELSIF Proc = 'ING_CALC_INT_CUOTA_MCH' THEN
                /*CALCULA EL INTERES PARA MAR CHIQUITA*/
                InteresMuni:=ING_CALC_INT_CUOTA_MCH(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                RETURN InteresMuni;
            --MDC 20-06-2008
            ELSIF Proc = 'ING_CALC_INT_CUOTA_LP' THEN
                /*CALCULA EL INTERES PARA LA PLATA*/
                InteresMuni:=ING_CALC_INT_CUOTA_LP(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                RETURN InteresMuni;
            --MDC 20-06-2008
            --MCV - 23-06-2011 - Bug 3735
            ELSIF Proc = 'ING_CALC_INT_CUOTA_SADA' THEN
                /*CALCULA EL INTERES PARA SAN ANTONIO DE ARECO*/
                InteresMuni:=ING_CALC_INT_CUOTA_SADA(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                RETURN InteresMuni;
            --MCV - 23-06-2011 - Bug 3735
            ELSIF Proc = 'ING_CALC_INT_CUOTA_130' THEN
                /*CALCULA EL INTERES PARA EZEIZA*/
                InteresMuni:=ING_CALC_INT_CUOTA_130(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                RETURN InteresMuni;
            --MCV - 23-06-2011 - Bug 3735
            --ELSIF Proc = 'ING_CALC_INT_CUOTA_131' THEN --FMO 03/12/2014
            ELSIF Proc = 'CONSTANTE_2PORCIENTO' THEN --San Miguel FTO 04/12/2014
                /*CALCULA EL INTERES PARA SAN MIGUEL*/
                --AGM 29/01/2015
                --InteresMuni:=Round(MONTHS_BETWEEN(pFechaFin+1,pFechaIni)+1)*(pImporte+pMontoAct)*0.02;
                --FTO 17/02/2021
                  /*  nCantMeses:=ING_GET_CANT_DIAS_FECHAS(pFechaFin,pFechaIni,Error);
                    nCantMeses:=nCantMeses*-1;

                    if nCantMeses=0 then
                        nCantMeses:=MONTHS_BETWEEN(pFechaFin,pFechaIni);
                        if nCantMeses>0 then
                           InteresMuni:=(pImporte+ NVL(pMontoAct,0))*0.02;
                        end if;
                    else
                        InteresMuni:=nCantMeses*(pImporte+ NVL(pMontoAct,0))* 0.02;
                    end if;*/
                -- FIN AGM 29/01/2015
                InteresMuni:= ING_CALC_INT_CUOTA_131(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                --Fin FTO 17/02/2021

                RETURN InteresMuni;

            --Pila LDA 07/11/2016
            ELSIF Proc = 'ING_CALC_INT_CUOTA_083' THEN
                InteresMuni:= ING_CALC_INT_CUOTA_083(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                RETURN InteresMuni;
            --Fin Pila LDA 07/11/2016

            --LDA 5831
            ELSIF Proc = 'ING_CALC_INT_CUOTA_107' THEN
                /*CALCULA EL INTERES PARA TRENQUE LAUQUEN*/
                InteresMuni:= ING_CALC_INT_CUOTA_107(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                RETURN InteresMuni;
            --FIN LDA 5831
            ELSIF Proc = 'ING_CALC_INT_CUOTA_205' THEN
                /*CALCULA EL INTERES PARA LIBERTADOR SAN MARTIN*/
                InteresMuni:= ING_CALC_INT_CUOTA_205(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                RETURN InteresMuni;
            ELSIF Proc = 'ING_CALC_INT_CUOTA_030' THEN --NOC 04/09/2017
                /*CALCULA EL INTERES PARA ESTEBAN ECHEVERRIA*/
                InteresMuni:= ING_CALC_INT_CUOTA_030(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                RETURN InteresMuni;
            ELSIF Proc = 'ING_CALC_INT_CUOTA_094' THEN
                /*FMO 29/12/2017 CALCULA EL INTERES PARA SAN ANDRES DE GILES*/
                InteresMuni:= ING_CALC_INT_CUOTA_094(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                RETURN InteresMuni;
            ELSIF Proc = 'ING_CALC_INT_CUOTA_098' THEN--FTO 24/09/2018
                 InteresMuni:=ING_CALC_INT_CUOTA_098(pImporte, pIndice, pFechaIni, pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                 RETURN InteresMuni;
            ELSIF Proc = 'ING_CALC_INT_CUOTA_115' THEN --NOC 16/10/2020
                /*CALCULA EL INTERES PARA ENSENADA*/
                InteresMuni:= ING_CALC_INT_CUOTA_115(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError );
                RETURN InteresMuni;
            ELSIF Proc = 'ING_CALC_INT_CUOTA_080' THEN --NOC 16/10/2020
                /*CALCULA EL INTERES PARA ENSENADA*/
                InteresMuni:= ING_CALC_INT_CUOTA_080(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pCodError);
                RETURN InteresMuni;
            ELSIF Proc = 'ING_CALC_INT_CUOTA_135' THEN
                /*CALCULA EL INTERES PARA HURLINGHAM*/
                InteresMuni:= ING_CALC_INT_CUOTA_135(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                RETURN InteresMuni;                
            ELSIF Proc = 'ING_CALC_INT_CUOTA_099' THEN
                /*CALCULA EL INTERES PARA SAN PEDRO*/
                InteresMuni:= ING_CALC_INT_CUOTA_099(pImporte,pIndice,pFechaIni,pFechaFin,pMontoAct,pMontoInt,pCodError);
                RETURN InteresMuni;
            ELSE
                total:=ING_CALC_INT_CUOTA_RAFAM (pImporte, pIndice, pFechaIni, pFechaFin,pMontoAct,pMontoInt,pTipoComprob,pSituacion,pEstado,pRecurso,pAnio,pCuota,pConcepto,pCodError);
                RETURN total;
            END IF; --End Proc
        EXCEPTION WHEN NO_DATA_FOUND THEN
            IF MarcadorBusqueda = 1 THEN
                pCodError := 'No se encontró el Ind. de Interes : ' ||TO_CHAR(pIndice) || CHR(13)|| ' para el Año : ' || TO_CHAR(AnioIni) || CHR(13)||
                             ' Mes : ' || TO_CHAR(MesIni);
            ELSIF MarcadorBusqueda = 2 THEN
                pCodError := 'No se encontró el Ind. de Interes : ' ||TO_CHAR(pIndice) || CHR(13)|| ' para el Año : ' || TO_CHAR(AnioAnt) || CHR(13)||
                             ' Mes : ' || TO_CHAR(MesAnt);
            ELSIF MarcadorBusqueda = 3 THEN
                pCodError := 'No se encontró el Ind. de Interes : ' ||TO_CHAR(pIndice) || CHR(13)|| ' para el Año : ' ||TO_CHAR(AnioFin)||CHR(13)||
                             ' Mes : ' || TO_CHAR(MesFin);
            END IF;
            RETURN 0;
        WHEN OTHERS THEN
            raise_application_error(-20140, SQLCODE || SQLERRM ||'ERROR: Función ing_calc_int_cuota' );
        END;--Begin 3

    END IF;

END; -- End Función ING_CALC_INT_CUOTA.
/
GRANT EXECUTE ON ing_calc_int_cuota TO rol_cas
/

COMMIT;
PROMPT ##################################################################################; 
PROMPT FIN - CUERPO PRINCIPAL; 
PROMPT ##################################################################################; 
 
EXIT;
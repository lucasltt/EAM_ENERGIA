create or replace package EAM_EPM is
  --********************
  --VERSION DE PRODUCCION
  --********************
  --No Incluye time_out como parametro
  --Incluye reporte del elemento donde se produce loop infinito en EAM_ERRORS
  --Incluye solucion de la "bobina" conectada entre elemento de corte y conductor
  --Incluye cambios parrilla (conservacion de  id, nombres de ubicaciones y correcciones relacionadas con tipo=PARRILLA en circuitos y parrilla)
  --No incluye activos lineales retirados  y consolidacion de activos

  -- Creación
  -- Version : 1.0
  -- Author  : Lucas Turchet
  -- Created : 05/05/2017
  -- Purpose : Disponibilización de Activos para Integración con EAM

  -- Modificación
  -- Version : 1.1
  -- Author  : Lucas Turchet
  -- Created : 22/05/2017
  -- Purpose : Cambios en la reglas de parrilla y circuitos sin segmentación

  -- Modificación
  -- Version : 1.1.1
  -- Author  : Lucas Turchet
  -- Created : 26/05/2017
  -- Purpose : Ajustes para no quedar en loop infinito en los traces

  -- Modificación
  -- Version : 1.2
  -- Author  : Lucas Turchet
  -- Created : 08/06/2017
  -- Purpose : Ajustes en las reglas de identificacion de activos

  -- Modificación
  -- Version : 1.3
  -- Author  : Lucas Turchet
  -- Created : 09/06/2017
  -- Purpose : Ajustes de optimización de desenpno

  -- Modificación
  -- Version : 1.4
  -- Author  : Lucas Turchet
  -- Created : 20/06/2017
  -- Purpose : Ajustes de errores y mejorias en en manejo de expciones
  -- Notas de la versión
  -- 1)  Mejoria en la descripción de los errores en la tabla eam_circuitos
  -- 2)  Creación de una excepción de circuito sin interruptor
  -- 3)  Creación de una excepción al tener mós de un interruptor en el trace del circuito
  -- 4)  Si hay excpeciones durante la ejecución de un circuito,
  --     borra los registros procesados de las tablas de trace, ubicacion y activos
  -- 5)  Opción para borrar los resultados de la tabla de eam_trace despues
  --     del flujo del circuito. El valor defecto 1 (borrar) mantene
  --     la tabla limpia y mejora el disempeno
  -- 6)  La funcion eam_flujo_cirs mira los circuitos insertados
  --     en la tabla eam_circuitos y no mas en la cred_ten_cir_cat
  -- 7)  Creación de un grupo para ejecución paralela en la tabla eam_circuitos y en la función
  --     eam_flujo_cirs
  -- 8)  Ajustes de error "No data found" por cuenta del FID padre invalido
  -- 9)  Ajustes en la identificación de los tramos
  -- 10) Ajustes en la funcion eam_conductores para que no tenga muchos cursores abiertos
  -- 11) La funcion EAM_TRACE_CIR limpia registros duplicados del trace
  -- 12) Ajustes de ubicaciones duplicadas
  -- 13) La funcion eam_flujo_cirs tiene el resultado "FIN CON ERROR"
  --     que es cuando hay registros con errores de datos o catastro,
  --     pero sigue el proceso del circuito. Los errores se quedan el la tabla eam_errors
  -- 14) La funcion eam_flujo_cirs tiene el resultado "EXCEPCION"
  --     que es cuando hube un error fatal en el circuito y NO logro a lo procesar
  -- 15) Creado ERROR 'Elemento sin nodo_ubicacion' en la función eam_trace_cir
  --     que ocure cuando un elemento de corte no tiene poblado el nodo_ubicacion
  -- 16) Ajustado las llamadas de los traces de segmento, ramales y tramos en la
  --     funcion EAM_GRUPO_CIR para que incluya los transformadores
  --     en el mismo nodo donde empeza el elemento de Corte.
  -- 17) Ajustado los registros donde en la tabla de activos el atributo ubicación
  --     (código de la ubicación padre) y fid_padre no correponden  al mismo
  --     elemento en la tabla de ubicaciones
  -- 18) La ubicacion de los activos de transformadores se identifica por nodo_tranfo
  --     y no mas por el padre del ramal/segmento/tramo

  -- Modificación
  -- Version : 1.5
  -- Author  : Lucas Turchet
  -- Created : 03/07/2017
  -- Purpose : Ajustes de errores
  -- Notas de la versión
  -- 1)  Correcicón del valor del nivel_superior en las ubicaciones de parrilla
  -- 2)  Corrección del valor de la ubicación de los activos de parrilla
  -- 3)  Correcion ubicaciones duplicads
  -- 4)  Correcion activos

  -- Modificación
  -- Version : 1.6
  -- Author  : Lucas Turchet
  -- Created : 10/07/2017
  -- Purpose : Ajustes de errores
  -- Notas de la versión
  -- 1)  Elementos de corte que no tienen ningun conductor ahora son insertador
  --     en las tablas eam_ubicacion y eam_activos. Para los elementos de corte
  --     del alimentador, se inserta un tramo, para los de segmento, se inserta un
  --     segmento y un ramal
  -- 2)  Las Luminarias no se cargan mós como activos

  -- Modificación
  -- Version : 1.7
  -- Author  : Lucas Turchet
  -- Created : 20/07/2017
  -- Purpose : Ajustes de errores
  -- Notas de la versión
  -- 1)  Correcion de elementos con el fid_padre <> codigo_ubicacion
  -- 2)  La tabla eam_errors tiene el fno
  -- 3)  Genera error de conductores sin tramo/segmento

  -- Modificación
  -- Version : 1.8
  -- Author  : Lucas Turchet
  -- Created : 01/08/2017
  -- Purpose : Ajustes de errores
  -- Notas de la versión
  -- 1)  Cambio en la función EAM_FLUJO_CIRS para que solo ejecute el flujo
  --     de los circuitos que tuvieron cambio en la tabla REG_TRANSACCION
  -- 2)  Si un circuito tiene mós de uno interruptor con el mismo circuiti_entrada,
  --     se ejecuta el trace desde lo interruptor con ESTADO OPERATIVO
  -- 3)  Los interruptores no son mós considerados activos
  -- 4)  Se consideran interruptores que tiene el circuito_salida = circuito
  --     como un elemento de transferencia
  -- 5)  No se procesa circuitos de TRASMISION
  -- 6) Funcion para poblar la tabla EAM_CIRCUITOS
  -- 7) Funcion EAM_FLUJO que hace el flujo del circuito y de la parrilla

  -- Modificación
  -- Version : 1.9
  -- Author  : Lucas Turchet
  -- Created : 26/10/2017
  -- Purpose : Loop Infinito
  -- Notas de la versión
  -- 1)  Se inseró um monitoreo de tiempo para que salga del procedimiento caso
  --     tenga un loop infinito

  -- Modificación
  -- Version : 2.0
  -- Author  : Lucas Turchet
  -- Created :01/12/2017
  -- Purpose : Mejorias
  -- Notas de la versión
  -- 1)  Corrección para mantener el mismo número secuencial de la ubiacion depues
  --     de la primer ejecución
  -- 2)  Timeout parametizable
  -- 3)  Se inseta errores con los datos de la red en caso de loop infinito
  -- 4)  Novedades más rapida
  -- 5)  Pobla la tabla eam_activos_retirados con los elementos retirados

  -- Modificación
  -- Version : 2.1
  -- Author  : Lucas Turchet y Maria E. Mora
  -- Created :05/12/2017
  -- Purpose : Mejorias
  -- Notas de la versión
  -- 1)  Cambio en el procedimiento  EAM_FLUJO_CIRS para que  ejecute el flujo
  --     de los circuitos que pertenecen al grupo indicado como parametro
  -- 2)  Cambio en el procedimiento POBLAR_TABLA_CIRCUITOS para incluir un
  --     parametro que indique si se debe truncar la tabla y para insertar nuevos circuitos
  --     despues de la carga inicial
  -- 3)  Creacion del procedimiento EAM_RESPALDAR TABLAS para hacer
  --     un backup de las tablas del EAM
  -- 4)  Creacion del procedimiento EAM_DISTRIBUIR_CIRS  para hallar los circuitos con
  --     novedades y distruibuirlos en el numero de grupos indicado
  -- 5)  Cambio en procedimiento EAM_FLUJO para que ejecute el flujo completo de taxonomia
  --     considerando los cambios en  el paquete EAM
  -- 6)  Creacion del procedimiento  EAM_FLUJO_CIRS_PARALELO para ejecutar
  --     el flujo de Circuitos para todos los circuitos en 10 grupos  paralelos

  -- Modificación
  -- Version : 3.0.0
  -- Author  : Lucas Turchet
  -- Created :06/04/2018
  -- Purpose : Nuevos Funcionalidades
  -- Notas de la versión
  -- 1)  Implementación de la taxonomia de Transmision

  -- Modificación
  -- Version : 3.0.1
  -- Author  : Lucas Turchet
  -- Created : 26/04/2018
  -- Purpose : Nuevos Funcionalidades
  -- Notas de la versión
  -- 1)  Manejo de novedades y retirados para taxonima transmision
  
  -- Modificación
  -- Version : 3.0.2
  -- Author  : Lucas Turchet
  -- Created : 27/04/2018
  -- Purpose : Nuevos Funcionalidades
  -- Notas de la versión
  -- 1)  Manejo de novedades y retirados para taxonima civil

  --Exception de circuito que no tiene un interruptor
  circuito_sin_interruptor exception;

  --Exception de cuando el trace encuentra mas de 1 interurptor.
  trace_con_varios_interruptores exception;

  --Exception de cuando se quendan conductores sin tramos/segmentos asignanados
  conductor_sin_ubicacion exception;

  --Exception de cuando se queda mucho tiempo em una funcionaliad de recursión
  timeout_loop exception;

  nodos_ali_con_bifurcacion tNodos;
  nodos_seg_con_bifurcacion tNodos;

  --Ejecuta el flujo de Circuitos para todos los circuitos
  procedure EAM_FLUJO_CIRS(pGrupo      NUMBER DEFAULT 0,
                           timeout_min NUMBER DEFAULT 15);

  -- Ejecuta el flujo de Circuitos para uno solo circuito
  procedure EAM_FLUJO_CIR(pCircuito   CRED_TEN_CIR_CAT.CIRCUITO%type,
                          borrarTrace NUMBER DEFAULT 1,
                          timeout_min NUMBER DEFAULT 15);

  -- Ejecuta el flujo de los circuitos y de la parrilla
  procedure EAM_FLUJO(pGrupo         NUMBER DEFAULT 0,
                      pLimpiarTablas NUMBER DEFAULT 0,
                      timeout_min    NUMBER DEFAULT 15);

  -- Pobla la tabla EAM_CIRCUITOS con los circuitos de la tabla de connectividad
  procedure EAM_POBLAR_TABLA_CIRCUITOS(pLimpiarTabla number default 0);

  -- Identifica el interuptor del circuito, el tipo de circuito y hace el trace de GTech
  function EAM_TRACE_CIR(pCircuito CRED_TEN_CIR_CAT.Circuito%type)
    return elementos_corte;

  --Identifica los conductores que pertenencen al alimentador principal
  --y los que pertenecen a Ramales
  procedure EAM_TOPOLOGIA_CIR(pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type,
                              pCorte    elementos_corte);

  -- Identifica los tramos, segmentos, ramales y activos
  procedure EAM_GRUPOS_CIR(pCircuito   CRED_TEN_CIR_CAT.CIRCUITO%type,
                           pCorte      elementos_corte,
                           timeout_min NUMBER DEFAULT 15);

  -- Identifica los conductores conectador a un elemento puntual
  function EAM_CONDUCTORES(PG3E_ID       IN EAM_TRACES.G3E_ID%TYPE,
                           pCircuito     IN CRED_TEN_CIR_CAT.CIRCUITO%TYPE,
                           pNodoAnterior IN NUMBER,
                           pDatos        IN EAM_NODO_TABLE DEFAULT EAM_NODO_TABLE())
    return EAM_NODO_TABLE;

  -- Hace el trace de acuerdo con las reglas de identificación de segmentos
  function EAM_TRACESEGMENTOS(PG3E_ID            IN EAM_TRACES.G3E_ID%TYPE,
                              pCircuito          IN CRED_TEN_CIR_CAT.CIRCUITO%TYPE,
                              pCorte             elementos_corte,
                              pNodoAnterior      IN NUMBER,
                              pActivo            IN NUMBER,
                              pOrdem             IN NUMBER,
                              pIncluirNodosCorte IN NUMBER DEFAULT 1,
                              pDatos             IN EAM_TRACE_TABLE DEFAULT EAM_TRACE_TABLE(),
                              tiempoInicio       IN TIMESTAMP DEFAULT current_timestamp,
                              timeout_min        IN NUMBER DEFAULT 15)
    return EAM_TRACE_TABLE;

  -- Hace el trace de acuerdo con las reglas de identificación de tramos
  function EAM_TRACETRAMOS(PG3E_ID            IN EAM_TRACES.G3E_ID%TYPE,
                           pCircuito          IN CRED_TEN_CIR_CAT.CIRCUITO%TYPE,
                           pCorte             elementos_corte,
                           pNodoAnterior      IN NUMBER,
                           pActivo            IN NUMBER,
                           pOrdem             IN NUMBER,
                           pIncluirNodosCorte IN NUMBER DEFAULT 1,
                           pDatos             IN EAM_TRACE_TABLE DEFAULT EAM_TRACE_TABLE(),
                           tiempoInicio       IN TIMESTAMP DEFAULT current_timestamp,
                           timeout_min        IN NUMBER DEFAULT 15)
    return EAM_TRACE_TABLE;

  -- Hace el trace de acuerdo con las reglas de identificación de ramales
  function EAM_TRACERAMALES(PG3E_ID       IN EAM_TRACES.G3E_ID%TYPE,
                            pCircuito     IN CRED_TEN_CIR_CAT.CIRCUITO%TYPE,
                            pNodoAnterior IN NUMBER,
                            pRamal        IN NUMBER,
                            pDatos        IN EAM_TRACE_TABLE DEFAULT EAM_TRACE_TABLE(),
                            tiempoInicio  IN TIMESTAMP DEFAULT current_timestamp,
                            timeout_min   IN NUMBER DEFAULT 15)
    return EAM_TRACE_TABLE;

  -- Hace la clasificación de las ubicaciones de un circuito y actualiza la tabla
  -- EAM_UBICACIONES
  procedure EAM_UBICACION_CIR(pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type,
                              pCorte    elementos_corte);

  -- Hace la clasificación de los activos de un circuito y actualiza la tabla
  -- EAM_ACTIVOS
  procedure EAM_ACTIVOS_CIR(pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type);

  -- Recalcula los numeros de los activos despues de la primer ejecución
  procedure EAM_MANEJO_ACTIVO(pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type);

  --Calcula la red de parrilla
  procedure EAM_CARGA_PARRILLA;

  --Retorna la cantidad de cables conectados al nodo
  function EAM_BIFURCACION(pNodo     IN NUMBER,
                           pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type,
                           pTipo     IN NUMBER DEFAULT 1,
                           pDatos    IN EAM_NODO_TABLE DEFAULT EAM_NODO_TABLE())
    return number;

  --Verifica si el elementos contiene un cangrejo conectado en los dos nodos
  function EAM_CHECK_CONDUCTOR_PARRILLA(fid in NUMBER) return integer;

  --Limpia Todas las Tablas
  procedure EAM_LIMPIAR_TABLAS;

  -- Respalda las tablas EAM
  procedure EAM_RESPALDAR_TABLAS;

  -- Detecta los circuitos que tuvieron novedades y los distribuye en el numero de grupos indicado
  procedure EAM_DISTRIBUIR_NOVEDADES_CIRS(numGrupos    number,
                                          grupoInicial number);

  --Ejecuta el flujo de Circuitos para todos los circuitos en 10 grupos  paralelos
  procedure EAM_FLUJO_CIRS_PARALELO;

  -- Carga los activos y ubicaciones por primer vez de Infraestructura Civil
  procedure EAM_ESTRUCTURA_CIVIL;

  -- Actualiza los activos de Infraestructura Civil
  procedure EAM_CALCULAR_ACTIVOS_CIVIL;

  -- Ejecuta la taxonomia de Transmisión
  procedure EAM_TAXONOMIA_TRANSMISION;

  -- Maneja las novedades 
  procedure EAM_MANEJO_NOVEDADES(pcircuito varchar2);

  -- Maneja los retirados 
  procedure EAM_MANEJO_RETIRADOS(pcircuito varchar2);

end EAM_EPM;
/
create or replace package body EAM_EPM is

  procedure EAM_FLUJO_CIRS(pGrupo      NUMBER DEFAULT 0,
                           timeout_min NUMBER DEFAULT 15) is
  
    vTotalCirc NUMBER;
    vPrcCirs   NUMBER := 0;
    vTime      TIMESTAMP;
    sqlError   VARCHAR2(100);
    vCount     NUMBER;
  
  begin
    update eam_circuitos
       set status = null, tiempo = null, avance = null
     where grupo = pGrupo;
    commit;
  
    select count(circuito)
      into vTotalCirc
      from eam_circuitos
     where grupo = pGrupo;
  
    for cir in (select circuito from eam_circuitos where grupo = pGrupo) loop
      vPrcCirs := vPrcCirs + 1;
      vTime    := CURRENT_TIMESTAMP;
    
      begin
        update eam_circuitos
           set status = 'INICIO',
               avance = vPrcCirs || ' de ' || vTotalCirc || ' del grupo ' ||
                        pGrupo
         where circuito = cir.circuito;
        commit;
        EAM_FLUJO_CIR(cir.circuito, 1, timeout_min);
        commit;
        --verificar si hay errores en la tabla eam_errors
        select count(1)
          into vCount
          from eam_errors
         where circuito = cir.circuito;
        if vCount = 0 then
          update eam_circuitos
             set status           = 'FIN',
                 tiempo           = replace(to_char(CURRENT_TIMESTAMP -
                                                    vTime),
                                            '+000000000 ',
                                            ''),
                 fecha_conclusion = sysdate
           where circuito = cir.circuito;
          commit;
        else
          update eam_circuitos
             set status           = 'FIN CON ERROR',
                 tiempo           = replace(to_char(CURRENT_TIMESTAMP -
                                                    vTime),
                                            '+000000000 ',
                                            ''),
                 fecha_conclusion = sysdate
           where circuito = cir.circuito;
          commit;
        end if;
      exception
      
        when circuito_sin_interruptor then
          update eam_circuitos
             set status           = 'EXCEPCION - Circuito sin interruptor',
                 tiempo           = replace(to_char(CURRENT_TIMESTAMP -
                                                    vTime),
                                            '+000000000 ',
                                            ''),
                 fecha_conclusion = null
           where circuito = cir.circuito;
          delete from eam_traces where circuito = cir.circuito;
          delete from eam_activos_temp where circuito = cir.circuito;
          delete from eam_ubicacion_temp where circuito = cir.circuito;
          commit;
        
        when trace_con_varios_interruptores then
          update eam_circuitos
             set status           = 'EXCEPCION - Trace con varios interruptores',
                 tiempo           = replace(to_char(CURRENT_TIMESTAMP -
                                                    vTime),
                                            '+000000000 ',
                                            ''),
                 fecha_conclusion = null
           where circuito = cir.circuito;
          delete from eam_traces where circuito = cir.circuito;
          delete from eam_activos_temp where circuito = cir.circuito;
          delete from eam_ubicacion_temp where circuito = cir.circuito;
          commit;
        when conductor_sin_ubicacion then
          update eam_circuitos
             set status           = 'EXCEPCION - Conductor sin ubiacion',
                 tiempo           = replace(to_char(CURRENT_TIMESTAMP -
                                                    vTime),
                                            '+000000000 ',
                                            ''),
                 fecha_conclusion = null
           where circuito = cir.circuito;
          delete from eam_traces where circuito = cir.circuito;
          delete from eam_activos_temp where circuito = cir.circuito;
          delete from eam_ubicacion_temp where circuito = cir.circuito;
          commit;
        when timeout_loop then
          update eam_circuitos
             set status           = 'EXCEPCION - Timeout loop',
                 tiempo           = replace(to_char(CURRENT_TIMESTAMP -
                                                    vTime),
                                            '+000000000 ',
                                            ''),
                 fecha_conclusion = null
           where circuito = cir.circuito;
          delete from eam_traces where circuito = cir.circuito;
          delete from eam_activos_temp where circuito = cir.circuito;
          delete from eam_ubicacion_temp where circuito = cir.circuito;
          commit;
        
        when others then
          sqlError := substr(SQLERRM, 1, 100);
          update eam_circuitos
             set status           = 'EXCEPCION - ' || sqlError,
                 tiempo           = replace(to_char(CURRENT_TIMESTAMP -
                                                    vTime),
                                            '+000000000 ',
                                            ''),
                 fecha_conclusion = null
           where circuito = cir.circuito;
          delete from eam_traces where circuito = cir.circuito;
          delete from eam_activos_temp where circuito = cir.circuito;
          delete from eam_ubicacion_temp where circuito = cir.circuito;
          commit;
      end;
    end loop;
  
  end;

  procedure EAM_FLUJO_CIR(pCircuito   CRED_TEN_CIR_CAT.CIRCUITO%type,
                          borrarTrace NUMBER DEFAULT 1,
                          timeout_min NUMBER DEFAULT 15) is
  
    vCorte elementos_corte;
  begin
  
    delete from eam_errors where circuito = pCircuito;
    commit;
  
    vCorte := EAM_TRACE_CIR(pcircuito);
  
    if 0 member of vCorte then
      dbms_output.put_line('Circuito no definido');
      return;
    end if;
  
    delete from eam_activos_temp where circuito = pcircuito;
    commit;
    delete from eam_ubicacion_temp where circuito = pcircuito;
    commit;
  
    EAM_TOPOLOGIA_CIR(pcircuito, vCorte);
    EAM_GRUPOS_CIR(pcircuito, vCorte, timeout_min);
    EAM_UBICACION_CIR(pcircuito, vCorte);
    EAM_ACTIVOS_CIR(pcircuito);
  
    EAM_MANEJO_ACTIVO(pcircuito);
    EAM_MANEJO_NOVEDADES(pcircuito);
    EAM_MANEJO_RETIRADOS(pcircuito);
  
    if borrarTrace = 1 then
      delete from eam_traces where circuito = pCircuito;
      commit;
    end if;
  
  end;

  function EAM_TRACE_CIR(pCircuito CRED_TEN_CIR_CAT.Circuito%type)
    return elementos_corte as
  
    fidInterruptor cconectividad_e.G3E_FID%type;
    idTrace        traceid.g3e_id%type;
    vTipoCir       EINTERRU_AT.TIPO_CIRCUITO%type;
  
    vCorteDist   elementos_corte := elementos_corte(19300,
                                                    19400,
                                                    19700,
                                                    19800); --interruptor, ailadero, cucchilla, reconectador, suiche
    vCorteCargas elementos_corte := elementos_corte(18400, 19700); --suiche subterraneo y suiche
    vCorteSub    elementos_corte := elementos_corte(18800); -- interruptor
  
    vCorteRet elementos_corte := elementos_corte(0);
    vCorte    VARCHAR2(100);
    vCount    NUMBER;
  begin
  
    select count(1)
      into vCount
      from cconectividad_e
     where circuito = pCircuito
       and g3e_fno = 18800;
  
    if vCount = 1 then
      select g3e_fid
        into fidInterruptor
        from cconectividad_e
       where circuito = pCircuito
         and g3e_fno = 18800;
    elsif vCount > 1 then
      select nvl(g3e_fid, 0)
        into fidInterruptor
        from cconectividad_e
       where circuito = pCircuito
         and g3e_fno = 18800
         and estado = 'OPERACION';
    else
      raise circuito_sin_interruptor;
    end if;
  
    --consultar el tipo de circuito
    select nvl(tipo_circuito, 'NO DEFINIDO')
      into vTipoCir
      from EINTERRU_AT
     where g3e_fid = fidInterruptor;
  
    case
      when vTipoCir = 'DISTRIBUCION' then
        vCorteRet := vCorteDist;
      when vTipoCir = 'CARGAS MAYORES' or vTipoCir = 'PARRILLA' then
        vCorteRet := vCorteCargas;
      when vTipoCir = 'SUBTRANSMISION' or vTipoCir = 'EMERGENCIA' or
           vTipoCir = 'SERVICIOS AUXILIARES' then
        vCorteRet := vCorteSub;
      when vTipoCir = 'TRANSMISION' then
        vCorteRet := vCorteSub;
      else
        return vCorteRet;
    end case;
  
    select LISTAGG(column_value, ',') within group(order by column_value)
      into vCorte
      from table(vCorteDist);
    --ejecutar el trace
    trace.delete('EAM_TD_' || pCircuito || '_' || fidInterruptor);
    commit;
    trace.define('EAM_TD_' || pCircuito || '_' || fidInterruptor,
                 1,
                 'conn_s.g3e_fno in (' || vCorte ||
                 ') and conn_s.circuito_salida <> conn_s.circuito',
                 'conn.circuito = tr.CIRCUITO or conn.circuito_salida = tr.CIRCUITO',
                 null,
                 20,
                 null);
    trace.setseed(fidInterruptor);
    trace.execute;
    commit;
  
    --poner en la tabla de eam
    select g3e_id
      into idTrace
      from traceid
     where g3e_name = 'EAM_TD_' || pCircuito || '_' || fidInterruptor;
  
    delete from eam_traces where circuito = pCircuito;
    commit;
  
    insert into eam_traces
      select pCircuito as Circuito,
             circuito as circuito_entrada,
             user_col2 as circuito_salida,
             (case
               when not g3e_fno member of vCorteRet then
                ''
               when circuito <> user_col2 and g3e_fno member of vCorteRet then
                'Transferencia'
               else
                'Corte'
             end) as tipo,
             vTipoCir as tipo_circuito,
             g3e_traceorder,
             g3e_sourceid,
             g3e_sourcefid,
             g3e_sourcenode,
             g3e_node1,
             g3e_node2,
             g3e_id,
             g3e_fid,
             g3e_fno,
             (select g3e_username
                from g3e_feature
               where g3e_fno = tr.g3e_fno) as g3e_username,
             nodo_transform,
             0 as tramo,
             0 as segmento,
             0 as ramal,
             0 as activo,
             0 as ordem,
             0 as fid_padre,
             '' as codigo_padre,
             user_col3 as nodo_ubicacion
        from traceresult tr
       where g3e_tno = idTrace;
    commit;
  
    delete from eam_traces
     where rowid not in (select max(rowid)
                           from eam_traces
                          where circuito = pCircuito
                          group by g3e_traceorder,
                                   g3e_sourcefid,
                                   g3e_sourcenode,
                                   g3e_node1,
                                   g3e_node2,
                                   g3e_id,
                                   g3e_fno)
       and circuito = pCircuito;
    commit;
    trace.delete('EAM_TD_' || pCircuito || '_' || fidInterruptor);
    commit;
  
    --limpiar registros
    delete from eam_traces
     where circuito = pCircuito
       and ((circuito_salida != pCircuito and circuito_entrada != pCircuito) or
           (circuito_entrada != pCircuito and circuito_salida is null));
    commit;
    --verificar si hay mas de un interruptor en en trace
  
    select count(1)
      into vCount
      from eam_traces
     where circuito_entrada = pCircuito
       and g3e_fno = 18800;
  
    if vCount > 1 and vTipoCir != 'TRANSMISION' then
      raise trace_con_varios_interruptores;
    end if;
  
    return vCorteRet;
  end;

  procedure EAM_TOPOLOGIA_CIR(pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type,
                              pCorte    elementos_corte) is
  
    vResult EAM_TRACE_TABLE;
    vConduc EAM_NODO_TABLE;
    vCount  NUMBER(5);
  
    cursor elementosTransferencia(NombreCircuito eam_traces.circuito%type) is
      select *
        from eam_traces
       where tipo = 'Transferencia'
         and circuito = NombreCircuito;
  
    cursor connectRoot(TransferenciaID eam_traces.g3e_id%type,
                       NombreCircuito  eam_traces.circuito%type) is
      select connect_by_root g3e_username ORIGEM,
             g3e_username    DESTINO,
             g3e_fid,
             g3e_id,
             g3e_fno,
             g3e_sourcenode,
             g3e_node1,
             g3e_node2
        from eam_traces
       where circuito = NombreCircuito
      connect by prior g3e_sourceid = g3e_id
       start with g3e_id = TransferenciaID;
  
  begin
  
    update eam_traces
       set tipo = null
     where g3e_fno = 19000
       and circuito = pCircuito;
    commit;
  
    --instanciar nodos
    nodos_ali_con_bifurcacion := tNodos();
    nodos_seg_con_bifurcacion := tNodos();
  
    for eTranferencia in elementosTransferencia(pCircuito) loop
      for eRoot in connectRoot(eTranferencia.g3e_Id, pCircuito) loop
        --si es un conductor en el camino del elementos tranferencia - interruptor entonces un alimentador
      
        if eRoot.g3e_fno = 19000 then
          vResult := eam_tracesegmentos(eRoot.G3e_Id,
                                        pCircuito,
                                        pCorte,
                                        0,
                                        0,
                                        0);
          if vResult.Count > 0 then
            for i in vResult.First .. vResult.Last loop
              update eam_traces
                 set tipo = 'Alimentador'
               where circuito = pCircuito
                 and g3e_fid = vResult(i).g3e_fid;
            
            end loop;
          end if;
          commit;
        end if;
      
        --Hacer el traces hasta el proximo elemento de cortes desde un Corte del Alimentador
        if eRoot.g3e_fno member of pCorte then
          vConduc := EAM_CONDUCTORES(eRoot.g3e_id, pCircuito, 0);
          if vConduc.COUNT > 0 then
            for i in vConduc.FIRST .. vConduc.LAST loop
            
              vResult := eam_tracesegmentos(vConduc(i).G3e_Id,
                                            pCircuito,
                                            pCorte,
                                            0,
                                            0,
                                            0);
              if vResult.Count > 0 then
                for i in vResult.First .. vResult.Last loop
                  update eam_traces
                     set tipo = 'Alimentador'
                   where circuito = pCircuito
                     and g3e_fid = vResult(i).g3e_fid;
                
                end loop;
              end if;
              commit;
            end loop;
          end if;
          commit;
        end if;
      
        if eRoot.g3e_fno member of pCorte then
          update eam_traces
             set tipo = 'Corte Alimentador'
           where circuito = pCircuito
             and g3e_fid = eRoot.g3e_Fid
             and tipo <> 'Transferencia';
        end if;
      
      end loop;
      commit;
    
    end loop;
  
    select /* parallel */
     count(1)
      into vCount
      from eam_traces
     where tipo = 'Transferencia'
       and circuito = pCircuito;
  
    if vCount = 0 then
      --No hay elementos de transferencia
      update eam_traces
         set tipo = 'Alimentador'
       where g3e_fno = 19000
         and circuito = pCircuito;
    else
      update eam_traces
         set tipo = 'Ramal'
       where g3e_fno = 19000
         and tipo is null
         and circuito = pCircuito;
    end if;
  
    commit;
  
  end;

  procedure EAM_GRUPOS_CIR(pCircuito   CRED_TEN_CIR_CAT.CIRCUITO%type,
                           pCorte      elementos_corte,
                           timeout_min NUMBER DEFAULT 15) is
  
    --hace la  clasificación de ramales, segmentos y tramos
  
    cursor elementosCorteAlimentador(NombreCircuito eam_traces.circuito%type) is
      select *
        from eam_traces
       where (tipo = 'Corte Alimentador' or g3e_fno = 18800)
         and circuito = NombreCircuito
      --and g3e_fid = 29842
       order by g3e_traceorder, g3e_fid asc;
  
    cursor elementosCorte(NombreCircuito eam_traces.circuito%type) is
      select *
        from eam_traces
       where tipo in ('Corte Alimentador', 'Corte') --or g3e_fno = 18800)
         and circuito = NombreCircuito
      --and g3e_fid = 2067529
       order by g3e_traceorder, g3e_fid asc;
  
    cursor nodos(NombreCircuito eam_traces.circuito%type) is
      select distinct g3e_node1 as node
        from eam_traces
       where circuito = NombreCircuito
         and g3e_node1 is not null
         and g3e_node1 > 0
      union
      select distinct g3e_node2 as node
        from eam_traces
       where circuito = NombreCircuito
         and g3e_node2 is not null
         and g3e_node2 > 0;
  
    cursor activos(NombreCircuito eam_traces.circuito%type) is
      select distinct g3e_fid
        from eam_traces
       where g3e_fno = 19000
         and circuito = NombreCircuito
         and activo in (select activo
                          from (select distinct g3e_fid, activo, ordem
                                  from eam_traces
                                 where g3e_fno = 19000
                                   and circuito = NombreCircuito)
                         group by activo, ordem
                        having count(ordem) > 1);
  
    iTramo  number;
    iSegme  number;
    iRamal  number;
    vRamal  number;
    iNodo   number;
    vActiv  number;
    vCount  number;
    vI      number;
    vResult EAM_TRACE_TABLE;
    vTemp   EAM_TRACE_TABLE;
    vConduc EAM_NODO_TABLE;
  
  begin
    --Limpiar los datos antiguos
    update eam_traces
       set tramo = 0, segmento = 0, fid_padre = 0, codigo = null
     where circuito = pCircuito;
    commit;
  
    iTramo := 0;
    iSegme := 0;
    iRamal := 0;
  
    --verificar nodos
    nodos_ali_con_bifurcacion := tNodos();
    nodos_seg_con_bifurcacion := tNodos();
  
    for nodo in nodos(pCircuito) loop
      if EAM_BIFURCACION(nodo.node, pCircuito, 2) > 2 then
        nodos_ali_con_bifurcacion.extend();
        nodos_ali_con_bifurcacion(nodos_ali_con_bifurcacion.count) := nodo.node;
      end if;
      if EAM_BIFURCACION(nodo.node, pCircuito, 3) > 2 then
        nodos_seg_con_bifurcacion.extend();
        nodos_seg_con_bifurcacion(nodos_seg_con_bifurcacion.count) := nodo.node;
      end if;
    end loop;
  
    --para cada elemento de corte que pertenencen al circuito
    for eCorte in elementosCorteAlimentador(pCircuito) loop
      --encontrar los conductores conectar al elemento core
      iTramo  := iTramo + 1;
      vConduc := EAM_CONDUCTORES(eCorte.G3e_Id, pCircuito, 0);
      if vConduc.COUNT > 0 then
        for i in vConduc.FIRST .. vConduc.LAST loop
          --para cada conductor conectado en el elemento de corte
          if vConduc(i).Tramo = 0 and vConduc(i).Tipo = 'Alimentador' then
          
            begin
            
              select max(activo)
                into vActiv
                from eam_traces
               where g3e_id = vConduc(i).g3e_id
                 and circuito = pCircuito;
            
              if vActiv > 0 then
                continue;
              end if;
            exception
              when others then
                continue;
            end;
          
            vResult := eam_tracetramos(vConduc           (i).g3e_id,
                                       pCircuito,
                                       pCorte,
                                       0, --vConduc           (i).g3e_sourcenode
                                       eam_activo.nextval,
                                       1,
                                       1,
                                       timeout_min        => timeout_min);
            select count(1)
              into vCount
              from table(vResult) a
             where a.g3e_fid = -1;
          
            if vCount > 0 then
            
              insert into eam_errors
              values
                (pCircuito,
                 vConduc                                              (i)
                 .g3e_fid,
                 vConduc                                              (i)
                 .g3e_fno,
                 sysdate,
                 'Loop Infinito Tramos - Posible error de conectividad');
            
              /*
              insert into eam_errors
                (select pCircuito,
                        a.g3e_fid,
                        a.g3e_fno,
                        sysdate,
                        'Loop Infinito Tramos - Posible error de conectividad'
                   from table(vResult) a
                  where a.g3e_fid != -1
                  group by a.g3e_fid, a.g3e_fno);
                  */
              commit;
              raise timeout_loop;
            end if;
          
            update eam_traces
               set tramo = iTramo
             where g3e_fid = eCorte.g3e_fid
               and circuito = pcircuito;
            commit;
          
            /*
            
            dbms_output.put_line('Conductor ' || vConduc(i).g3e_id);
            for c in (select * from table(vResult) order by grupo, ordem asc) loop
              dbms_output.put_line('FID: ' || c.g3e_fid || ', FNO: ' ||
                                   c.g3e_fno || ', GRUPO: ' || c.grupo ||
                                   ', ORDEM: ' || c.ordem);
            end loop;
            dbms_output.put_line('--------------------------------------');
            
            */
          
            if vResult.COUNT > 0 then
            
              --Mirar si hay activos con ordem duplicado
              select count(count(ordem)) duplicados
                into vCount
                from table(vResult)
               where g3e_fno = 19000
               group by grupo, ordem
              having count(ordem) > 1;
            
              vTemp := vResult;
              vI    := 1;
            
              while vCount > 0 and vI <= vTemp.Count loop
                -- hay activos con ordem duplicado
                if vTemp(vI).g3e_fno != 19000 then
                  vI := vI + 1;
                  continue;
                end if;
              
                vResult := eam_tracetramos(vTemp             (vI).g3e_id,
                                           pCircuito,
                                           pCorte,
                                           0, --vConduc           (i).g3e_sourcenode
                                           eam_activo.nextval,
                                           1,
                                           1,
                                           timeout_min        => timeout_min);
              
                select count(count(ordem)) duplicados
                  into vCount
                  from table(vResult)
                 where g3e_fno = 19000
                 group by grupo, ordem
                having count(ordem) > 1;
              
                vI := vI + 1;
              
              end loop;
            
              --
            
              for i in vResult.First .. vResult.LAST loop
              
                if vResult(i).g3e_fno member of pCorte then
                  continue;
                end if;
              
                update eam_traces
                   set tramo     = iTramo,
                       fid_padre = eCorte.G3e_fid,
                       activo    = vResult(i).Grupo,
                       ordem     = vResult(i).Ordem
                 where circuito = pCircuito
                   and g3e_id = vResult(i).g3e_id;
                commit;
              end loop;
            end if;
          
            commit;
          end if;
        end loop;
      end if;
    end loop;
  
    --hacer la identificación del segmento/ramal que estan conectados
    --con los elementos de transferencia
    --Segmentos
    for eCorte in elementosCorte(pCircuito) loop
      --encontrar los conductores conectados al elemento corte
      vConduc := EAM_CONDUCTORES(eCorte.G3e_Id, pCircuito, 0);
    
      --para los conductores conectador al nodo 1 del elemento corte
      if vConduc.COUNT > 0 then
        iNodo := 0;
        for i in vConduc.FIRST .. vConduc.LAST loop
          if vConduc(i).Tramo = 0 and vConduc(i).Segmento = 0 and vConduc(i)
             .Tipo != 'Alimentador' then
          
            if iNodo = 0 then
              iSegme := iSegme + 1;
              iNodo  := 1;
            end if;
          
            update eam_traces
               set Segmento = iSegme
             where g3e_fid = eCorte.g3e_fid
               and circuito = pcircuito;
            commit;
          
            vResult := eam_tracesegmentos(vConduc           (i).g3e_id,
                                          pCircuito,
                                          pCorte,
                                          0, --vConduc           (i).g3e_sourcenode,
                                          eam_activo.nextval,
                                          1,
                                          1,
                                          timeout_min        => timeout_min);
          
            select count(1)
              into vCount
              from table(vResult) a
             where a.g3e_fid = -1;
          
            if vCount > 0 then
            
              insert into eam_errors
              values
                (pCircuito,
                 vConduc                                                (i)
                 .g3e_fid,
                 vConduc                                                (i)
                 .g3e_fno,
                 sysdate,
                 'Loop Infinito Segmento - Posible error de conectividad');
              /* insert into eam_errors
              (select pCircuito,
                      a.g3e_fid,
                      a.g3e_fno,
                      sysdate,
                      'Loop Infinito Segmento - Posible error de conectividad'
                 from table(vResult) a
                where a.g3e_fid != -1
                group by a.g3e_fid, a.g3e_fno);
                */
              commit;
              raise timeout_loop;
            end if;
          
            if vResult.COUNT > 0 then
            
              --Mirar si hay activos con ordem duplicado
              select count(count(ordem)) duplicados
                into vCount
                from table(vResult)
               where g3e_fno = 19000
               group by grupo, ordem
              having count(ordem) > 1;
            
              vTemp := vResult;
              vI    := 1;
            
              while vCount > 0 and vI <= vTemp.Count loop
                -- hay activos con ordem duplicado
                if vTemp(vI).g3e_fno != 19000 then
                  vI := vI + 1;
                  continue;
                end if;
              
                vResult := eam_tracesegmentos(vTemp             (vI).g3e_id,
                                              pCircuito,
                                              pCorte,
                                              0, --vConduc           (i).g3e_sourcenode
                                              eam_activo.nextval,
                                              1,
                                              1,
                                              timeout_min        => timeout_min);
              
                select count(count(ordem)) duplicados
                  into vCount
                  from table(vResult)
                 where g3e_fno = 19000
                 group by grupo, ordem
                having count(ordem) > 1;
              
                vI := vI + 1;
              
              end loop;
            
              --
            
              for i in vResult.First .. vResult.LAST loop
                if vResult(i).g3e_fno member of pCorte then
                  continue;
                end if;
              
                update eam_traces
                   set segmento  = iSegme,
                       fid_padre = eCorte.G3e_fid,
                       activo    = vResult(i).Grupo,
                       ordem     = vResult(i).Ordem
                 where circuito = pCircuito
                   and g3e_id = vResult(i).g3e_id;
                commit;
              end loop;
            end if;
          
          end if;
        
        end loop;
      
      end if;
    end loop;
  
    --Ramales
    for eCorte in elementosCorte(pCircuito) loop
      --encontrar los conductores conectados al elemento corte
      vConduc := EAM_CONDUCTORES(eCorte.G3e_Id, pCircuito, 0);
    
      --para los conductores conectador al nodo 1 del elemento corte
      if vConduc.COUNT > 0 then
        iNodo := 0;
        for ramal in (select * from table(vConduc) where tipo = 'Ramal') loop
        
          select max(ramal)
            into vRamal
            from eam_traces
           where g3e_id = ramal.g3e_id
             and g3e_fid = ramal.g3e_fid
             and circuito = pcircuito;
        
          if vRamal > 0 then
            continue;
          end if;
        
          if iNodo = 0 then
            iRamal := iRamal + 1;
            iNodo  := 1;
            update eam_traces
               set tipo = 'Corte Ramal', ramal = iRamal
             where g3e_id = eCorte.g3e_id;
            commit;
          end if;
        
          vResult := eam_traceramales(ramal.g3e_id,
                                      pCircuito,
                                      0, --ramal.g3e_sourcenode,
                                      iRamal,
                                      timeout_min => timeout_min);
        
          select count(1)
            into vCount
            from table(vResult) a
           where a.g3e_fid = -1;
        
          if vCount > 0 then
          
            /*
            insert into eam_errors
              (select pCircuito,
                      a.g3e_fid,
                      a.g3e_fno,
                      sysdate,
                      'Loop Infinito Ramal - Posible error de conectividad'
                 from table(vResult) a
                where a.g3e_fid != -1
                group by a.g3e_fid, a.g3e_fno);
                */
            insert into eam_errors
            values
              (pCircuito,
               ramal.g3e_fid,
               ramal.g3e_fno,
               sysdate,
               'Loop Infinito Ramal - Posible error de conectividad');
            commit;
            raise timeout_loop;
          end if;
        
          if vResult.COUNT > 0 then
            for i in vResult.First .. vResult.LAST loop
            
              update eam_traces
                 set ramal = iRamal
               where circuito = pCircuito
                 and g3e_id = ramal.g3e_id;
              commit;
            end loop;
          end if;
        
        end loop;
      
      end if;
    end loop;
  
    for activo in activos(pCircuito) loop
      update eam_traces
         set activo = eam_activo.nextval
       where g3e_fid = activo.g3e_fid
         and circuito = pCircuito;
      commit;
    end loop;
  
    -- verificar si hay conductores sin ramal/tramo/segmento asignados
    vCount := 0;
    for cond in (select g3e_fid
                   from eam_traces
                  where ramal = 0
                    and segmento = 0
                    and tramo = 0
                    and g3e_fno = 19000
                    and circuito = pCircuito) loop
      insert into eam_errors
      values
        (pCircuito, cond.g3e_fid, 19000, sysdate, 'Conductor sin ubiacion');
      vCount := vCount + 1;
    end loop;
  
    for trafo in (select g3e_fid
                    from eam_traces
                   where ramal = 0
                     and segmento = 0
                     and tramo = 0
                     and g3e_fno = 20400
                     and circuito = pCircuito) loop
      insert into eam_errors
      values
        (pCircuito,
         trafo.g3e_fid,
         20400,
         sysdate,
         'Transformador sin ubiacion');
      vCount := vCount + 1;
    end loop;
  
    if vCount > 0 then
      delete from eam_traces
       where ramal = 0
         and segmento = 0
         and tramo = 0
         and circuito = pCircuito;
      commit;
      --raise conductor_sin_ubicacion;
    end if;
  
  end;

  function EAM_CONDUCTORES(PG3E_ID       IN EAM_TRACES.G3E_ID%TYPE,
                           pCircuito     IN CRED_TEN_CIR_CAT.CIRCUITO%TYPE,
                           pNodoAnterior IN NUMBER,
                           pDatos        IN EAM_NODO_TABLE DEFAULT EAM_NODO_TABLE())
    return EAM_NODO_TABLE as
  
    --busca los conductores conectados a un elemento de corte
    vNodo1  NUMBER(10);
    vNodo2  NUMBER(10);
    vFNO    NUMBER(5);
    vFID    NUMBER(10);
    vCount  NUMBER;
    vResult EAM_NODO_TABLE := EAM_NODO_TABLE();
    vResTem EAM_NODO_TABLE := EAM_NODO_TABLE();
    vDatos  EAM_NODO_TABLE := pDatos;
  
    cursor nodos(vId       number,
                 vCircuito CRED_TEN_CIR_CAT.CIRCUITO%type,
                 nodo      number) is
      select *
        from eam_traces
       where g3e_id <> vID
         and (g3e_node1 = nvl(nullif(nodo, 0), -1) or
             g3e_node2 = nvl(nullif(nodo, 0), -1))
         and circuito = vCircuito;
  begin
  
    --Verificar si el registro ya fue procesado y no tene run loop infinito
    select /* parallel */
     count(1)
      into vCount
      from table(vDatos)
     where g3e_id = pg3e_id;
    if vCount > 0 then
      return vResult;
    else
      vDatos.extend();
      vDatos(vDatos.COUNT) := eam_nodo(pg3e_id,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null);
    end if;
    --ALRIGHT PARTNER, FIRST WE NEED TO CHECK IF THE RECORD EXISTS
    select /* parallel */
     count(1)
      into vCount
      from eam_traces
     where g3e_id = pg3e_id
       and circuito = pcircuito;
  
    if vCount = 0 then
      return vResult;
    end if;
  
    --NOW WE NEED TO GET THE NODE1 AND NODE2 OF THE PROVIDED G3E_ID
    select g3e_node1, g3e_node2, g3e_fno, g3e_fid
      into vNodo1, vNodo2, vFNO, vFID
      from eam_traces
     where g3e_id = pg3e_id
       and circuito = pcircuito
       and rownum = 1;
  
    --NOW I HAVE TO CHECK THE NODES CONNECTING TO NODE1
    if vnodo1 <> pNodoAnterior then
      for nodo in nodos(pg3e_id, pcircuito, vnodo1) loop
        --si es un conductor, ponga en los resultados
        --si es un elemento de referencia, haga la recusrsividade
        if nodo.g3e_fno in (19000) then
          select /* parallel */
           count(1)
            into vCount
            from table(vResult)
           where g3e_fid = nodo.g3e_fid;
          if vCount = 0 then
            vResult.extend();
            vResult(vResult.COUNT) := EAM_NODO(nodo.g3e_id,
                                               nodo.g3e_fno,
                                               nodo.g3e_fid,
                                               vnodo1,
                                               nodo.tramo,
                                               nodo.segmento,
                                               nodo.tipo);
          end if;
        elsif nodo.g3e_fno in (19200, 19100, 22200) then
          vResTem := EAM_CONDUCTORES(nodo.g3e_id, pCircuito, vnodo1, vDatos);
          if vResTem.COUNT > 0 then
            for i in vResTem.FIRST .. vResTem.LAST loop
              select /* parallel */
               count(1)
                into vCount
                from table(vResult)
               where g3e_fid = vResTem(i).g3e_fid;
              if vCount = 0 then
                vResult.extend();
                vResult(vResult.COUNT) := EAM_NODO(vResTem(i).g3e_id,
                                                   vResTem(i).g3e_fno,
                                                   vResTem(i).g3e_fid,
                                                   vnodo1,
                                                   vResTem(i).tramo,
                                                   vResTem(i).segmento,
                                                   vResTem(i).tipo);
              end if;
            end loop;
          end if;
        end if;
      
      end loop;
    end if;
  
    --NOW I HAVE TO CHECK THE NODES CONNECTING TO NODE2
    if vnodo2 <> pNodoAnterior then
      for nodo in nodos(pg3e_id, pcircuito, vnodo2) loop
        --si es un conductor, ponga en los resultados
        --si es un elemento de referencia, haga la recusrsividade
        if nodo.g3e_fno in (19000) then
          select /* parallel */
           count(1)
            into vCount
            from table(vResult)
           where g3e_fid = nodo.g3e_fid;
          if vCount = 0 then
            vResult.extend();
            vResult(vResult.COUNT) := EAM_NODO(nodo.g3e_id,
                                               nodo.g3e_fno,
                                               nodo.g3e_fid,
                                               vnodo2,
                                               nodo.tramo,
                                               nodo.segmento,
                                               nodo.tipo);
          end if;
        elsif nodo.g3e_fno in (19200, 19100, 22200) then
          vResTem := EAM_CONDUCTORES(nodo.g3e_id, pCircuito, vnodo2, vDatos);
          if vResTem.COUNT > 0 then
            for i in vResTem.FIRST .. vResTem.LAST loop
              select /* parallel */
               count(1)
                into vCount
                from table(vResult)
               where g3e_fid = vResTem(i).g3e_fid;
            
              if vCount = 0 then
                vResult.extend();
                vResult(vResult.COUNT) := EAM_NODO(vResTem(i).g3e_id,
                                                   vResTem(i).g3e_fno,
                                                   vResTem(i).g3e_fid,
                                                   vnodo2,
                                                   vResTem(i).tramo,
                                                   vResTem(i).segmento,
                                                   vResTem(i).tipo);
              end if;
            end loop;
          end if;
        end if;
      
      end loop;
    end if;
  
    return vResult;
  
  end;

  function EAM_TRACESEGMENTOS(PG3E_ID            IN EAM_TRACES.G3E_ID%TYPE,
                              pCircuito          IN CRED_TEN_CIR_CAT.CIRCUITO%TYPE,
                              pCorte             elementos_corte,
                              pNodoAnterior      IN NUMBER,
                              pActivo            IN NUMBER,
                              pOrdem             IN NUMBER,
                              pIncluirNodosCorte IN NUMBER DEFAULT 1,
                              pDatos             IN EAM_TRACE_TABLE DEFAULT EAM_TRACE_TABLE(),
                              tiempoInicio       IN TIMESTAMP DEFAULT current_timestamp,
                              timeout_min        IN NUMBER DEFAULT 15)
    return EAM_TRACE_TABLE as
  
    --HACE EL TRACE DE UN ALIMENTADOR HASTA ENCONTRAR ELEMENTOS DE CORTE
    vEAM1   EAM_TRACE_TABLE := EAM_TRACE_TABLE();
    vEAM2   EAM_TRACE_TABLE := EAM_TRACE_TABLE();
    vNodo1  NUMBER(10);
    vNodo2  NUMBER(10);
    vFNO    NUMBER(5);
    vFID    NUMBER(10);
    vCount  NUMBER;
    vCount2 NUMBER;
    vActivo NUMBER;
    vOrdem  NUMBER;
    vTipo   VARCHAR2(30);
    vResult EAM_TRACE_TABLE := EAM_TRACE_TABLE();
    vResTem EAM_TRACE_TABLE := EAM_TRACE_TABLE();
    vDatos  EAM_TRACE_TABLE := pDatos;
  
    cursor nodos(vId       number,
                 vCircuito CRED_TEN_CIR_CAT.CIRCUITO%type,
                 nodo      number) is
      select *
        from eam_traces
       where g3e_id <> vID
         and (g3e_node1 = nvl(nullif(nodo, 0), -1) or
             g3e_node2 = nvl(nullif(nodo, 0), -1))
         and circuito = vCircuito;
  begin
  
    if (cast(current_timestamp as date) - cast(tiempoInicio as date)) *
       86400 > timeout_min * 60 then
      vResult.extend();
      vResult(vResult.COUNT) := eam_trace_record(-1,
                                                 -1,
                                                 -1,
                                                 -1,
                                                 -1,
                                                 -1,
                                                 -1,
                                                 '-1');
    
      return vResult;
    end if;
  
    --ALRIGHT PARTNER, FIRST WE NEED TO CHECK IF THE RECORD EXISTS
    select /* parallel */
     count(1)
      into vCount
      from eam_traces
     where g3e_id = pg3e_id
       and circuito = pcircuito;
  
    if vCount = 0 then
      return vResult;
    end if;
  
    --Verificar si el registro ya fue procesado y no tene run loop infinito
    select /* parallel */
     count(1)
      into vCount
      from table(vDatos)
     where g3e_id = pg3e_id;
    if vCount > 0 then
      return vResult;
    else
      vDatos.extend();
      vDatos(vDatos.COUNT) := eam_trace_record(pg3e_id,
                                               null,
                                               null,
                                               null,
                                               null,
                                               null,
                                               null,
                                               null);
    end if;
  
    vActivo := pActivo;
    vOrdem  := pOrdem;
  
    --NOW WE NEED TO GET THE NODE1 AND NODE2 OF THE PROVIDED G3E_ID
    select g3e_node1, g3e_node2, g3e_fno, g3e_fid, tipo
      into vNodo1, vNodo2, vFNO, vFID, vTipo
      from eam_traces
     where g3e_id = pg3e_id
       and circuito = pcircuito
       and rownum = 1;
  
    --NOW I HAVE TO CHECK THE NODES CONNECTING TO NODE1
    if vNodo1 != pNodoAnterior then
      for nodo in nodos(pg3e_id, pcircuito, vnodo1) loop
        vEAM1.extend();
        vEAM1(vEAM1.COUNT) := eam_trace_record(nodo.g3e_id,
                                               nodo.g3e_fid,
                                               nodo.g3e_fno,
                                               nodo.g3e_node1,
                                               nodo.g3e_node2,
                                               vActivo,
                                               vOrdem,
                                               vTipo);
      
      end loop;
    end if;
  
    --NOW I HAVE TO CHECK THE NODES CONNECTING TO NODE2
    if vnodo2 != pNodoAnterior then
      for nodo in nodos(pg3e_id, pcircuito, vnodo2) loop
        vEAM2.extend();
        vEAM2(vEAM2.COUNT) := eam_trace_record(nodo.g3e_id,
                                               nodo.g3e_fid,
                                               nodo.g3e_fno,
                                               nodo.g3e_node1,
                                               nodo.g3e_node2,
                                               vActivo,
                                               vOrdem,
                                               vTipo);
      
      end loop;
    end if;
  
    --GOOD, NOW I HAVE TO CHECK IF THE NODE1 HAVE ANY ELEMENTOS DE CORTE
  
    select count(1)
      into vCount
      from table(vEAM1)
     where g3e_fno member of pCorte;
    /*
    select
     count(distinct(g3e_fid))
      into vCount2
      from table(vEAM1)
     where g3e_fno <> 20400
       and g3e_fno <> 17900;
       */
    vCount2 := 0;
    if vCount = 0 and vNodo1 != pNodoAnterior and vEAM1.COUNT > 0 then
    
      select count(1)
        into vCount2
        from table(nodos_seg_con_bifurcacion) p
       where p.column_value = vNodo1;
    
      --Nodo no hay elementos de corte, hacer la recursividad
      for i in vEAM1.FIRST .. vEAM1.LAST loop
        if vCount2 > 0 then
          --hay mais de un elemento en el mesmo punto de conectividad
          vActivo := eam_activo.nextval;
          vOrdem  := 1;
        elsif vEAM1(i).g3e_fno = 19000 then
          vOrdem := vOrdem + 1;
        end if;
      
        vResTem := EAM_TRACESEGMENTOS(vEAM1(i).g3e_id,
                                      pCircuito,
                                      pCorte,
                                      vNodo1,
                                      vActivo,
                                      vOrdem,
                                      pIncluirNodosCorte,
                                      vDatos,
                                      tiempoInicio,
                                      timeout_min);
        if vResTem.COUNT > 0 then
          for i in vResTem.FIRST .. vResTem.LAST loop
            vResult.Extend();
            vResult(vResult.COUNT) := vResTem(i);
          end loop;
        end if;
      end loop;
    elsif pIncluirNodosCorte = 1 and vCount > 0 and vNodo1 != pNodoAnterior and
          vEAM1.COUNT > 0 then
      --Nodo hay elementos de corte, anandir a los resultados los elementos que
      --estan en el mismo nodo pero no son de corte (transformador, referencia, etc)
      for i in vEAM1.FIRST .. vEAM1.LAST loop
        if vEAM1(i).g3e_fno member of pCorte or VEAM1(i).g3e_fno = 19000 then
          continue;
        end if;
      
        vResult.Extend();
        vResult(vResult.COUNT) := vEAM1(i);
      
      end loop;
    end if;
  
    --GOOD, NOW I HAVE TO CHECK IF THE NODE2 HAVE ANY ELEMENTOS DE CORTE
    select count(1)
      into vCount
      from table(vEAM2)
     where g3e_fno in (select column_value from table(pCorte));
    /*
    select
     count(distinct(g3e_fid))
      into vCount2
      from table(vEAM2)
     where g3e_fno <> 20400
       and g3e_fno <> 17900;
       */
  
    vCount2 := 0;
    if vCount = 0 and vNodo2 != pNodoAnterior and vEAM2.COUNT > 0 then
      select count(1)
        into vCount2
        from table(nodos_seg_con_bifurcacion) p
       where p.column_value = vNodo2;
      for i in vEAM2.FIRST .. vEAM2.LAST loop
        if vCount2 > 0 then
          --hay mais de un elemento en el mesmo punto de conectividad
          vActivo := eam_activo.nextval;
          vOrdem  := 1;
        elsif vEAM2(i).g3e_fno = 19000 then
          vOrdem := vOrdem + 1;
        end if;
        vResTem := EAM_TRACESEGMENTOS(vEAM2(i).g3e_id,
                                      pCircuito,
                                      pCorte,
                                      vNodo2,
                                      vActivo,
                                      vOrdem,
                                      pIncluirNodosCorte,
                                      vDatos,
                                      tiempoInicio,
                                      timeout_min);
        if vResTem.COUNT > 0 then
          for i in vResTem.FIRST .. vResTem.LAST loop
            vResult.Extend();
            vResult(vResult.COUNT) := vResTem(i);
          end loop;
        end if;
      end loop;
    elsif pIncluirNodosCorte = 1 and vCount > 0 and vNodo2 != pNodoAnterior and
          vEAM2.COUNT > 0 then
      --Nodo hay elementos de corte, anandir a los resultados los elementos que
      --estan en el mismo nodo pero no son de corte (transformador, referencia, etc)
      for i in vEAM2.FIRST .. vEAM2.LAST loop
        if vEAM2(i).g3e_fno member of pCorte or vEAM2(i).g3e_fno = 19000 then
          continue;
        end if;
      
        vResult.Extend();
        vResult(vResult.COUNT) := vEAM2(i);
      
      end loop;
    end if;
  
    vResult.Extend();
    vResult(vResult.COUNT) := eam_trace_record(pg3e_id,
                                               vFID,
                                               vFNO,
                                               vNodo1,
                                               vNodo2,
                                               pActivo,
                                               pOrdem,
                                               vTipo);
  
    return vResult;
  end;

  function EAM_TRACETRAMOS(PG3E_ID            IN EAM_TRACES.G3E_ID%TYPE,
                           pCircuito          IN CRED_TEN_CIR_CAT.CIRCUITO%TYPE,
                           pCorte             elementos_corte,
                           pNodoAnterior      IN NUMBER,
                           pActivo            IN NUMBER,
                           pOrdem             IN NUMBER,
                           pIncluirNodosCorte IN NUMBER DEFAULT 1,
                           pDatos             IN EAM_TRACE_TABLE DEFAULT EAM_TRACE_TABLE(),
                           tiempoInicio       IN TIMESTAMP DEFAULT current_timestamp,
                           timeout_min        IN NUMBER DEFAULT 15)
    return EAM_TRACE_TABLE as
  
    --HACE EL TRACE PARA CREAR LOS TRAMOS
    vEAM1   EAM_TRACE_TABLE := EAM_TRACE_TABLE();
    vEAM2   EAM_TRACE_TABLE := EAM_TRACE_TABLE();
    vNodo1  NUMBER(10);
    vNodo2  NUMBER(10);
    vFNO    NUMBER(5);
    vFID    NUMBER(10);
    vCount  NUMBER;
    vCount2 NUMBER;
    vActivo NUMBER;
    vOrdem  NUMBER;
    vTipo   VARCHAR2(30);
    vResult EAM_TRACE_TABLE := EAM_TRACE_TABLE();
    vResTem EAM_TRACE_TABLE := EAM_TRACE_TABLE();
    vDatos  EAM_TRACE_TABLE := pDatos;
  
    cursor nodos(vId       number,
                 vCircuito CRED_TEN_CIR_CAT.CIRCUITO%type,
                 nodo      number) is
      select *
        from eam_traces
       where g3e_id <> vID
         and (g3e_node1 = nvl(nullif(nodo, 0), -1) or
             g3e_node2 = nvl(nullif(nodo, 0), -1))
         and circuito = vCircuito;
  begin
  
    if (cast(current_timestamp as date) - cast(tiempoInicio as date)) *
       86400 > timeout_min * 60 then
    
      vResult.extend();
      vResult(vResult.COUNT) := eam_trace_record(-1,
                                                 -1,
                                                 -1,
                                                 -1,
                                                 -1,
                                                 -1,
                                                 -1,
                                                 '-1');
    
      return vResult;
    end if;
  
    --ALRIGHT PARTNER, FIRST WE NEED TO CHECK IF THE RECORD EXISTS
    select /* parallel */
     count(1)
      into vCount
      from eam_traces
     where g3e_id = pg3e_id
       and circuito = pcircuito;
  
    if vCount = 0 then
      return vResult;
    end if;
  
    --Verificar si el registro ya fue procesado y no tene run loop infinito
    select /* parallel */
     count(1)
      into vCount
      from table(vDatos)
     where g3e_id = pg3e_id;
  
    if vCount > 0 then
      return vResult;
    else
      vDatos.extend();
      vDatos(vDatos.COUNT) := eam_trace_record(pg3e_id,
                                               null,
                                               null,
                                               null,
                                               null,
                                               null,
                                               null,
                                               null);
    end if;
  
    vActivo := pActivo;
    vOrdem  := pOrdem;
  
    --NOW WE NEED TO GET THE NODE1 AND NODE2 OF THE PROVIDED G3E_ID
    select g3e_node1, g3e_node2, g3e_fno, g3e_fid, tipo
      into vNodo1, vNodo2, vFNO, vFID, vTipo
      from eam_traces
     where g3e_id = pg3e_id
       and circuito = pcircuito
       and rownum = 1;
  
    --NOW I HAVE TO CHECK THE NODES CONNECTING TO NODE1
    if vnodo1 != pNodoAnterior then
      for nodo in nodos(pg3e_id, pcircuito, vnodo1) loop
        vEAM1.extend();
        vEAM1(vEAM1.COUNT) := eam_trace_record(nodo.g3e_id,
                                               nodo.g3e_fid,
                                               nodo.g3e_fno,
                                               nodo.g3e_node1,
                                               nodo.g3e_node2,
                                               vActivo,
                                               vOrdem,
                                               nodo.tipo);
      
      end loop;
    end if;
  
    --NOW I HAVE TO CHECK THE NODES CONNECTING TO NODE2
    if vnodo2 != pNodoAnterior then
      for nodo in nodos(pg3e_id, pcircuito, vnodo2) loop
        vEAM2.extend();
        vEAM2(vEAM2.COUNT) := eam_trace_record(nodo.g3e_id,
                                               nodo.g3e_fid,
                                               nodo.g3e_fno,
                                               nodo.g3e_node1,
                                               nodo.g3e_node2,
                                               vActivo,
                                               vOrdem,
                                               nodo.tipo);
      
      end loop;
    end if;
  
    --Nodo1
    vCount2 := 0;
  
    select count(1)
      into vCount
      from table(vEAM1)
     where tipo = 'Corte Alimentador'
       and g3e_fno member of pCorte;
  
    if vCount = 0 and vNodo1 != pNodoAnterior and vEAM1.COUNT > 0 then
      --vCount2 := eam_bifurcacion(vNodo1, pcircuito);
    
      select count(1)
        into vCount2
        from table(nodos_ali_con_bifurcacion) p
       where p.column_value = vNodo1;
    
      for i in vEAM1.FIRST .. vEAM1.LAST loop
      
        if vEAM1(i).Tipo = 'Corte Alimentador' then
          continue;
        end if;
      
        if vEAM1(i).g3e_fno = 18800 then
          continue;
        end if;
      
        if vEAM1(i).Tipo != 'Alimentador' and vEAM1(i).g3e_fno = 19000 then
          continue;
        end if;
      
        if vCount2 > 0 then
          vActivo := eam_activo.nextval;
          vOrdem  := 1;
        else
          vOrdem := vOrdem + 1;
        end if;
      
        vResTem := EAM_TRACETRAMOS(vEAM1(i).g3e_id,
                                   pCircuito,
                                   pCorte,
                                   vNodo1,
                                   vActivo,
                                   vOrdem,
                                   pIncluirNodosCorte,
                                   vDatos,
                                   tiempoInicio,
                                   timeout_min);
      
        if vResTem.COUNT > 0 then
          for i in vResTem.FIRST .. vResTem.LAST loop
            vResult.Extend();
            vResult(vResult.COUNT) := vResTem(i);
          end loop;
        end if;
      
      end loop;
    elsif vCount > 0 and vNodo1 != pNodoAnterior and vEAM1.COUNT > 0 and
          pIncluirNodosCorte = 1 then
      for i in vEAM1.FIRST .. vEAM1.LAST loop
        if vEAM1(i).g3e_fno member of pCorte or VEAM1(i).g3e_fno = 19000 then
          continue;
        end if;
      
        vResult.Extend();
        vResult(vResult.COUNT) := vEAM1(i);
      end loop;
    end if;
  
    --Nodo2
    select count(1)
      into vCount
      from table(vEAM2)
     where tipo = 'Corte Alimentador'
       and g3e_fno member of pCorte;
    vCount2 := 0;
    if vCount = 0 and vNodo2 != pNodoAnterior and vEAM2.COUNT > 0 then
    
      select count(1)
        into vCount2
        from table(nodos_ali_con_bifurcacion) p
       where p.column_value = vNodo2;
      for i in vEAM2.FIRST .. vEAM2.LAST loop
      
        if vEAM2(i).Tipo = 'Corte Alimentador' then
          continue;
        end if;
      
        if vEAM2(i).g3e_fno = 18800 then
          continue;
        end if;
      
        if vEAM2(i).Tipo != 'Alimentador' and vEAM2(i).g3e_fno = 19000 then
          continue;
        end if;
      
        if vCount2 > 0 then
          vActivo := eam_activo.nextval;
          vOrdem  := 1;
        else
          vOrdem := vOrdem + 1;
        end if;
      
        vResTem := EAM_TRACETRAMOS(vEAM2(i).g3e_id,
                                   pCircuito,
                                   pCorte,
                                   vNodo2,
                                   vActivo,
                                   vOrdem,
                                   pIncluirNodosCorte,
                                   vDatos,
                                   tiempoInicio,
                                   timeout_min);
      
        if vResTem.COUNT > 0 then
          for i in vResTem.FIRST .. vResTem.LAST loop
            vResult.Extend();
            vResult(vResult.COUNT) := vResTem(i);
          end loop;
        end if;
      
      end loop;
    elsif vCount > 0 and vNodo2 != pNodoAnterior and vEAM2.COUNT > 0 and
          pIncluirNodosCorte = 1 then
      for i in vEAM2.FIRST .. vEAM2.LAST loop
      
        if vEAM2(i).g3e_fno member of pCorte or vEAM2(i).g3e_fno = 19000 then
          continue;
        end if;
      
        vResult.Extend();
        vResult(vResult.COUNT) := vEAM2(i);
      end loop;
    end if;
  
    vResult.Extend();
    vResult(vResult.COUNT) := eam_trace_record(pg3e_id,
                                               vFID,
                                               vFNO,
                                               vNodo1,
                                               vNodo2,
                                               pActivo,
                                               pOrdem,
                                               vTipo);
  
    return vResult;
  end;

  function EAM_TRACERAMALES(PG3E_ID       IN EAM_TRACES.G3E_ID%TYPE,
                            pCircuito     IN CRED_TEN_CIR_CAT.CIRCUITO%TYPE,
                            pNodoAnterior IN NUMBER,
                            pRamal        IN NUMBER,
                            pDatos        IN EAM_TRACE_TABLE DEFAULT EAM_TRACE_TABLE(),
                            tiempoInicio  IN TIMESTAMP DEFAULT current_timestamp,
                            timeout_min   IN NUMBER DEFAULT 15)
    return EAM_TRACE_TABLE as
  
    --HACE EL TRACE PARA CREAR LOS TRAMOS
    vEAM1   EAM_TRACE_TABLE := EAM_TRACE_TABLE();
    vEAM2   EAM_TRACE_TABLE := EAM_TRACE_TABLE();
    vNodo1  NUMBER(10);
    vNodo2  NUMBER(10);
    vFNO    NUMBER(5);
    vFID    NUMBER(10);
    vCount  NUMBER;
    vCount2 NUMBER;
    vRamal  NUMBER;
    vTipo   VARCHAR2(30);
    vResult EAM_TRACE_TABLE := EAM_TRACE_TABLE();
    vResTem EAM_TRACE_TABLE := EAM_TRACE_TABLE();
    vDatos  EAM_TRACE_TABLE := pDatos;
  
    cursor nodos(vId       number,
                 vCircuito CRED_TEN_CIR_CAT.CIRCUITO%type,
                 nodo      number) is
      select *
        from eam_traces
       where g3e_id <> vID
         and (g3e_node1 = nvl(nullif(nodo, 0), -1) or
             g3e_node2 = nvl(nullif(nodo, 0), -1))
         and circuito = vCircuito;
  begin
  
    if (cast(current_timestamp as date) - cast(tiempoInicio as date)) *
       86400 > timeout_min * 60 then
      vResult.extend();
      vResult(vResult.COUNT) := eam_trace_record(-1,
                                                 -1,
                                                 -1,
                                                 -1,
                                                 -1,
                                                 -1,
                                                 -1,
                                                 '-1');
    
      return vResult;
    end if;
  
    --ALRIGHT PARTNER, FIRST WE NEED TO CHECK IF THE RECORD EXISTS
    select /* parallel */
     count(1)
      into vCount
      from eam_traces
     where g3e_id = pg3e_id
       and circuito = pcircuito;
  
    if vCount = 0 then
      return vResult;
    end if;
  
    --Verificar si el registro ya fue procesado y no tene run loop infinito
    select /* parallel */
     count(1)
      into vCount
      from table(vDatos)
     where g3e_id = pg3e_id;
    if vCount > 0 then
      return vResult;
    else
      vDatos.extend();
      vDatos(vDatos.COUNT) := eam_trace_record(pg3e_id,
                                               null,
                                               null,
                                               null,
                                               null,
                                               null,
                                               null,
                                               null);
    end if;
  
    --NOW WE NEED TO GET THE NODE1 AND NODE2 OF THE PROVIDED G3E_ID
    select g3e_node1, g3e_node2, g3e_fno, g3e_fid, tipo, ramal
      into vNodo1, vNodo2, vFNO, vFID, vTipo, vRamal
      from eam_traces
     where g3e_id = pg3e_id
       and circuito = pcircuito
       and rownum = 1;
  
    if vRamal > 0 then
      return vResult;
    end if;
  
    update eam_traces set ramal = pRamal where g3e_id = pg3e_id;
    commit;
  
    --NOW I HAVE TO CHECK THE NODES CONNECTING TO NODE1
    if vnodo1 != pNodoAnterior then
      for nodo in nodos(pg3e_id, pcircuito, vnodo1) loop
        vEAM1.extend();
        vEAM1(vEAM1.COUNT) := eam_trace_record(nodo.g3e_id,
                                               nodo.g3e_fid,
                                               nodo.g3e_fno,
                                               nodo.g3e_node1,
                                               nodo.g3e_node2,
                                               0,
                                               0,
                                               nodo.tipo);
      
      end loop;
    end if;
    --NOW I HAVE TO CHECK THE NODES CONNECTING TO NODE2
    if vnodo2 != pNodoAnterior then
      for nodo in nodos(pg3e_id, pcircuito, vnodo2) loop
        vEAM2.extend();
        vEAM2(vEAM2.COUNT) := eam_trace_record(nodo.g3e_id,
                                               nodo.g3e_fid,
                                               nodo.g3e_fno,
                                               nodo.g3e_node1,
                                               nodo.g3e_node2,
                                               0,
                                               0,
                                               nodo.tipo);
      
      end loop;
    end if;
  
    select /* parallel */
     count(1)
      into vCount2
      from table(vEAM1)
     where Tipo = 'Alimentador'
       and g3e_fno = 19000;
  
    --Nodo1
    if vNodo1 != pNodoAnterior and vEAM1.COUNT > 0 then
      for i in vEAM1.FIRST .. vEAM1.LAST loop
      
        if vEAM1(i).Tipo = 'Alimentador' and vEAM1(i).g3e_fno = 19000 then
          continue;
        end if;
      
        vResTem := EAM_TRACERAMALES(vEAM1(i).g3e_id,
                                    pCircuito,
                                    vNodo1,
                                    pRamal,
                                    vDatos,
                                    tiempoInicio,
                                    timeout_min);
      
        if vResTem.COUNT > 0 then
          for i in vResTem.FIRST .. vResTem.LAST loop
            vResult.Extend();
            vResult(vResult.COUNT) := vResTem(i);
          end loop;
        end if;
      
      end loop;
    end if;
  
    --Nodo2
    select /* parallel */
     count(1)
      into vCount2
      from table(vEAM2)
     where Tipo = 'Alimentador'
       and g3e_fno = 19000;
  
    if vNodo2 != pNodoAnterior and vEAM2.COUNT > 0 then
      for i in vEAM2.FIRST .. vEAM2.LAST loop
      
        if vEAM2(i).Tipo = 'Alimentador' and vEAM2(i).g3e_fno = 19000 then
          continue;
        end if;
      
        vResTem := EAM_TRACERAMALES(vEAM2(i).g3e_id,
                                    pCircuito,
                                    vNodo2,
                                    pRamal,
                                    vDatos,
                                    tiempoInicio,
                                    timeout_min);
      
        if vResTem.COUNT > 0 then
          for i in vResTem.FIRST .. vResTem.LAST loop
            vResult.Extend();
            vResult(vResult.COUNT) := vResTem(i);
          end loop;
        end if;
      
      end loop;
    end if;
  
    vResult.Extend();
    vResult(vResult.COUNT) := eam_trace_record(pg3e_id,
                                               vFID,
                                               vFNO,
                                               vNodo1,
                                               vNodo2,
                                               0,
                                               0,
                                               vTipo);
  
    return vResult;
  end;

  procedure EAM_UBICACION_CIR(pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type,
                              pCorte    elementos_corte) is
  
    cursor elementosCircuito(pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type) is
      select * from eam_traces where circuito = pCircuito;
  
    vCodigo  VARCHAR2(30);
    vCodigo2 VARCHAR2(30);
    vNvlSup  VARCHAR2(80);
    vNodoUb  VARCHAR2(30);
    vFNOP    NUMBER(5);
    vFPadre  NUMBER;
    vACT     DATE;
  
  begin
    vACT := sysdate;
    --Processar los codigos de los elementos
    for elementoCircuito in elementosCircuito(pCircuito) loop
    
      vCodigo := '';
      case
        when elementoCircuito.g3e_fno = 19800 then
          select codigo
            into vCodigo
            from ERECONEC_AT
           where g3e_fid = elementoCircuito.g3e_fid
             and g3e_cid = 1;
        when elementoCircuito.g3e_fno = 19300 then
          select codigo
            into vCodigo
            from EAISLADE_AT
           where g3e_fid = elementoCircuito.g3e_fid
             and g3e_cid = 1;
        when elementoCircuito.g3e_fno = 19400 then
          select codigo
            into vCodigo
            from ECUCHILL_AT
           where g3e_fid = elementoCircuito.g3e_fid
             and g3e_cid = 1;
        when elementoCircuito.g3e_fno = 19700 then
          select codigo
            into vCodigo
            from ESUICHE_AT
           where g3e_fid = elementoCircuito.g3e_fid
             and g3e_cid = 1;
        when elementoCircuito.g3e_fno = 18800 then
        
          select nodo_ubicacion
            into vCodigo
            from Cconectividad_e
           where g3e_fid = elementoCircuito.g3e_fid
             and g3e_cid = 1;
        
          update eam_traces
             set nodo_ubicacion = vCodigo
           where g3e_fid = elementoCircuito.g3e_fid
             and circuito = pCircuito;
          commit;
        
          select codigo
            into vCodigo
            from EINTERRU_AT
           where g3e_fid = elementoCircuito.g3e_fid
             and g3e_cid = 1;
        
        when elementoCircuito.g3e_fno = 18400 then
          select codigo
            into vCodigo
            from ESUI_SUB_AT
           where g3e_fid = elementoCircuito.g3e_fid
             and g3e_cid = 1;
        when elementoCircuito.g3e_fno = 20400 then
          select codigo
            into vCodigo
            from ETRANSFO_AT
           where g3e_fid = elementoCircuito.g3e_fid
             and g3e_cid = 1;
        else
          continue;
      end case;
    
      update eam_traces
         set codigo = vCodigo
       where g3e_fid = elementoCircuito.g3e_fid;
      commit;
    end loop;
  
    --verificar si hay elementos de corte sin nodo_ubicacion
    for c in (select *
                from eam_traces
               where circuito = pCircuito
                 and nodo_ubicacion is null
                 and g3e_fno member of pCorte) loop
      insert into eam_errors
      values
        (pcircuito,
         c.g3e_fid,
         c.g3e_fno,
         sysdate,
         'Elemento sin nodo_ubicacion');
    end loop;
    commit;
  
    delete from eam_ubicacion_temp where circuito = pCircuito;
    commit;
  
    --Circuito, mirar el codigo_ubicacion
    insert into eam_ubicacion_temp
      select circuito,
             g3e_fid,
             g3e_fno,
             nvl(codigo, circuito),
             'CIRCUITO' as UBICACION,
             3 as Nivel,
             'DISTRIBUCION' as NIVEL_SUPERIOR,
             circuito,
             'CIRCUITO ' || circuito as Descripcion,
             vACT
        from eam_traces
       where g3e_fno = 18800
         and circuito = pCircuito
         and circuito_entrada = pCircuito;
    commit;
  
    --Alimentador Principal
    select codigo_ubicacion
      into vNvlSup
      from eam_ubicacion_temp
     where ubicacion = 'CIRCUITO'
       and circuito = pcircuito;
  
    insert into eam_ubicacion_temp
      select circuito,
             g3e_fid,
             g3e_fno,
             nvl(codigo, circuito),
             'ALIMENTADOR PRINCIPAL' as UBICACION,
             4 as Nivel,
             vNvlSup,
             NODO_UBICACION || '-4',
             'CIRCUITO ' || circuito || ' ALIMENTADOR PRINCIPAL ' || codigo as Descripcion,
             vACT
        from eam_traces
       where g3e_fno = 18800
         and circuito = pCircuito
         and circuito_entrada = pCircuito;
    commit;
  
    --Tramos
    select codigo_ubicacion
      into vNvlSup
      from eam_ubicacion_temp
     where ubicacion = 'ALIMENTADOR PRINCIPAL'
       and circuito = pcircuito;
  
    for c in (select distinct (fid_padre)
                from eam_traces
               where tramo <> 0
                 and circuito = pCircuito
                 and g3e_fno = 19000) loop
    
      select nvl(codigo, circuito), nvl(nodo_ubicacion, '')
        into vCodigo, vNodoUb
        from eam_traces
       where g3e_fid = c.fid_padre
         and circuito = pCircuito
         and rownum = 1;
    
      select g3e_fno
        into vFNOP
        from eam_traces
       where g3e_fid = c.fid_padre
         and circuito = pCircuito
         and rownum = 1;
    
      insert into eam_ubicacion_temp
      values
        (pCircuito,
         c.fid_padre,
         vFNOP,
         vCodigo,
         'TRAMO',
         5,
         vNvlSup,
         vNodoUb || '-5',
         'CIRCUITO ' || pCircuito || ' TRAMO ' || vCodigo,
         vACT);
      commit;
    end loop;
  
    --ramales
    select codigo_ubicacion
      into vNvlSup
      from eam_ubicacion_temp
     where ubicacion = 'CIRCUITO'
       and circuito = pcircuito;
  
    insert into eam_ubicacion_temp
      select circuito,
             g3e_fid,
             g3e_fno,
             codigo,
             'RAMAL' as ubicacion,
             4 as nivel,
             vNvlSup as nivel_superior,
             NODO_UBICACION || '-4',
             'CIRCUITO ' || circuito || ' RAMAL ' || CODIGO as descripcion,
             vACT
        from eam_traces
       where tipo = 'Corte Ramal'
         and circuito = pCircuito
       group by circuito, g3e_fid, g3e_fno, codigo, nodo_ubicacion;
    commit;
  
    --segmentos
    for seg in (select segmento, ramal, fid_padre
                  from eam_traces
                 where segmento <> 0
                   and g3e_fno = 19000
                   and circuito = pCircuito
                 group by segmento, ramal, fid_padre
                 order by segmento asc) loop
    
      --Código del padre del segmento
      select nvl(codigo, circuito), nvl(nodo_ubicacion, '')
        into vCodigo, vNodoUb
        from eam_traces
       where g3e_fid = seg.fid_padre
         and circuito = pCircuito
         and rownum = 1;
    
      --Codigo del padre del ramal
      select nvl(codigo, circuito)
        into vCodigo2
        from eam_traces
       where ramal = seg.ramal
         and tipo = 'Corte Ramal'
         and circuito = pCircuito
         and rownum = 1;
    
      --codigo_ubicacion del ramal
      select codigo_ubicacion
        into vNvlSup
        from eam_ubicacion_temp
       where ubicacion = 'RAMAL'
         and codigo = vCodigo2
         and circuito = pCircuito
         and rownum = 1;
    
      select g3e_fno
        into vFNOP
        from eam_traces
       where g3e_fid = seg.fid_padre
         and circuito = pCircuito
         and rownum = 1;
    
      insert into eam_ubicacion_temp
      values
        (pCircuito,
         seg.fid_padre,
         vFNOP,
         vCodigo,
         'SEGMENTO',
         5,
         vNvlSup,
         vNodoUb || '-5',
         'CIRCUITO ' || pCircuito || ' SEGMENTO ' || vCodigo,
         vACT);
      commit;
    end loop;
  
    --elementos de Corte que no tienen Segmento/Ramal/Tramo
    for seg in (select g3e_fid, g3e_fno, codigo, nodo_ubicacion
                  from eam_traces
                 where segmento = 0
                   and tramo = 0
                   and ramal = 0
                   and tipo = 'Corte'
                   and circuito = pCircuito
                   and g3e_fno != 18800
                 group by g3e_fid, g3e_fno, codigo, nodo_ubicacion) loop
    
      --codigo_ubicacion del ramal
      select codigo_ubicacion
        into vNvlSup
        from eam_ubicacion_temp
       where ubicacion = 'CIRCUITO'
         and circuito = pCircuito
         and rownum = 1;
    
      insert into eam_ubicacion_temp
      values
        (pCircuito,
         seg.g3e_fid,
         seg.g3e_fno,
         seg.codigo,
         'SEGMENTO',
         5,
         seg.nodo_ubicacion || '-4',
         seg.nodo_ubicacion || '-5',
         'CIRCUITO ' || pCircuito || ' SEGMENTO ' || seg.codigo,
         vACT);
    
      insert into eam_ubicacion_temp
      values
        (pCircuito,
         seg.g3e_fid,
         seg.g3e_fno,
         seg.codigo,
         'RAMAL',
         4,
         vNvlSup,
         seg.nodo_ubicacion || '-4',
         'CIRCUITO ' || pCircuito || ' RAMAL ' || seg.codigo,
         vACT);
      commit;
    
    end loop;
  
    --elementos de Corte Alimentador que no tienen Tramo
    for seg in (select g3e_fid, g3e_fno, codigo, nodo_ubicacion
                  from eam_traces
                 where segmento = 0
                   and tramo = 0
                   and ramal = 0
                   and g3e_fno != 18800
                   and tipo = 'Corte Alimentador'
                   and circuito = pCircuito
                 group by g3e_fid, g3e_fno, codigo, nodo_ubicacion) loop
    
      --codigo_ubicacion del ramal
      select codigo_ubicacion
        into vNvlSup
        from eam_ubicacion_temp
       where ubicacion = 'ALIMENTADOR PRINCIPAL'
         and circuito = pCircuito
         and rownum = 1;
    
      insert into eam_ubicacion_temp
      values
        (pCircuito,
         seg.g3e_fid,
         seg.g3e_fno,
         seg.codigo,
         'TRAMO',
         5,
         vNvlSup,
         seg.nodo_ubicacion || '-5',
         'CIRCUITO ' || pCircuito || ' TRAMO ' || seg.codigo,
         vACT);
    
      commit;
    
    end loop;
  
    --Elementos de Corte que solo tiene ramal pero no generan un segmento
    for seg in (select g3e_fid, g3e_fno, codigo, nodo_ubicacion, ramal
                  from eam_traces
                 where segmento = 0
                   and tramo = 0
                   and ramal <> 0
                   and g3e_fno != 18800
                   and tipo = 'Corte'
                   and circuito = pCircuito
                 group by g3e_fid, g3e_fno, codigo, nodo_ubicacion, ramal) loop
    
      --Codigo del padre del ramal
      select nvl(codigo, circuito)
        into vCodigo2
        from eam_traces
       where ramal = seg.ramal
         and tipo = 'Corte Ramal'
         and circuito = pCircuito
         and rownum = 1;
    
      --codigo_ubicacion del ramal
      select codigo_ubicacion
        into vNvlSup
        from eam_ubicacion_temp
       where ubicacion = 'RAMAL'
         and codigo = vCodigo2
         and circuito = pCircuito
         and rownum = 1;
    
      insert into eam_ubicacion_temp
      values
        (pCircuito,
         seg.g3e_fid,
         seg.g3e_fno,
         seg.codigo,
         'SEGMENTO',
         5,
         vNvlSup,
         seg.nodo_ubicacion || '-5',
         'CIRCUITO ' || pCircuito || ' SEGMENTO ' || seg.codigo,
         vACT);
    
    end loop;
  
    --elementos de Transferencia
    for seg in (select g3e_fid, g3e_fno, codigo, nodo_ubicacion
                  from eam_traces
                 where segmento = 0
                   and tramo = 0
                   and ramal = 0
                   and g3e_fno != 18800
                   and tipo = 'Transferencia'
                   and circuito = pCircuito
                   and circuito_entrada = pCircuito
                 group by g3e_fid, g3e_fno, codigo, nodo_ubicacion) loop
    
      --codigo_ubicacion del ramal
      select codigo_ubicacion
        into vNvlSup
        from eam_ubicacion_temp
       where ubicacion = 'ALIMENTADOR PRINCIPAL'
         and circuito = pCircuito
         and rownum = 1;
    
      insert into eam_ubicacion_temp
      values
        (pCircuito,
         seg.g3e_fid,
         seg.g3e_fno,
         seg.codigo,
         'TRAMO',
         5,
         vNvlSup,
         seg.nodo_ubicacion || '-5',
         'CIRCUITO ' || pCircuito || ' TRAMO ' || seg.codigo,
         vACT);
    
      commit;
    
    end loop;
  
    --Nodos Transformadores -- ok
    for nodo in (select t.circuito,
                        t.g3e_fid,
                        t.g3e_fno,
                        t.fid_padre,
                        t.nodo_transform,
                        t.segmento,
                        t.tramo,
                        t.ramal,
                        t.codigo
                   from eam_traces t
                  where t.g3e_fno = 20400
                    and t.circuito = pCircuito
                  group by t.circuito,
                           t.g3e_fid,
                           t.g3e_fno,
                           t.fid_padre,
                           t.nodo_transform,
                           t.segmento,
                           t.tramo,
                           t.ramal,
                           t.codigo) loop
    
      if nodo.ramal > 0 then
      
        select g3e_fid
          into vFPadre
          from eam_traces
         where ramal = nodo.ramal
           and tipo = 'Corte Ramal'
           and circuito = pCircuito
           and rownum = 1;
      
        select codigo_ubicacion
          into vNvlSup
          from eam_ubicacion_temp
         where g3e_fid = vFPadre
           and circuito = pcircuito
           and ubicacion = 'RAMAL';
      elsif nodo.tramo > 0 then
        select codigo_ubicacion
          into vNvlSup
          from eam_ubicacion_temp
         where circuito = pcircuito
           and ubicacion = 'ALIMENTADOR PRINCIPAL';
      else
        --el elemento no esta associado a un segmento
        continue;
      end if;
    
      insert into eam_ubicacion_temp
      values
        (pCircuito,
         nodo.g3e_fid,
         nodo.g3e_fno,
         nodo.codigo,
         'NODO',
         5,
         vNvlSup,
         nodo.NODO_TRANSFORM,
         'CIRCUITO ' || pcircuito || ' NODO ' || nodo.NODO_TRANSFORM,
         vACT);
      commit;
    
    end loop;
  
  end;

  procedure EAM_ACTIVOS_CIR(pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type) is
  
    cursor elementosCircuito(pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type) is
      select circuito,
             g3e_fid,
             G3e_Username,
             g3e_fno,
             max(g3e_sourcefid) as g3e_sourcefid,
             g3e_node1,
             g3e_node2,
             tramo,
             segmento,
             ramal,
             activo,
             ordem,
             tipo,
             fid_padre,
             Nodo_Transform,
             codigo
        from eam_traces
       where circuito = pCircuito
         and circuito_entrada = pCircuito
       group by circuito,
                g3e_fid,
                G3e_Username,
                g3e_fno,
                g3e_node1,
                g3e_node2,
                tramo,
                segmento,
                ramal,
                activo,
                ordem,
                tipo,
                fid_padre,
                Nodo_Transform,
                codigo
       order by decode(g3e_fno, 20400, 1, 2);
  
    cursor redSecundaria(nodo NUMBER) is
      select c.*
        from cconectividad_e c, econ_ses_at a
       where c.g3e_fno = 21200
         and c.g3e_fid = a.g3e_fid
         and a.tipo <> 'PARRILLA'
         and c.nodo_Transform = nodo;
  
    vCount VARCHAR2(30);
    vPadre NUMBER(10);
    vNivel VARCHAR2(80);
    vACT   DATE;
  
  begin
    vACT := sysdate;
  
    delete from eam_activos_temp where circuito = pCircuito;
    commit;
  
    --Processar los codigos de los elementos
    for elementoCircuito in elementosCircuito(pCircuito) loop
    
      case
        when elementoCircuito.g3e_fno = 18800 then
          --circuito no es activo
          continue;
        when elementoCircuito.g3e_fno = 21400 then
          -- luminaria no hace nada
          continue;
        when elementoCircuito.g3e_fno = 19200 then
          -- referencia no hace nada
          continue;
        when elementoCircuito.g3e_fno = 21200 then
          -- conductor secundario -> dejar solo el procesamiento desde el transformador? Si se hace aqui se deben filtrar que sean TIPO<>PARRILLA
          /* select
           count(1)
            into vCount
            from eam_activos_temp
           where g3e_fid = elementoCircuito.g3e_fid
             and circuito = pCircuito;
          begin
            if vCount = 0 then
              --Mirar el fid del transformador travós del nodo_trasformador
          
              select g3e_fid
                into vPadre
                from eam_traces
               where nodo_transform = elementoCircuito.Nodo_Transform
                 and circuito = pCircuito
                 and g3e_fno = 20400;
          
              insert into eam_activos_temp
              values
                (pCircuito,
                 elementoCircuito.g3e_fid,
                 21200,
                 'RED SECUNDARIA',
                 elementoCircuito.Nodo_Transform,
                 6,
                 vPadre,
                 0,
                 0);
              commit;
            end if;
          exception
            when others then
              insert into eam_errors
              values
                (pCircuito,
                 elementoCircuito.g3e_fid,
                 elementoCircuito.g3e_fno,
                 sysdate,
                 'No se pudo encontrar el transformador con el mismo nodo_trans');
              commit;
          end;*/
          continue;
        when elementoCircuito.g3e_fno = 19100 then
          -- nodo cunductor no hace nada
          continue;
        when elementoCircuito.g3e_fno = 20100 then
          -- Pararayos
          select count(1)
            into vCount
            from epararra_at
           where g3e_fid = elementoCircuito.g3e_fid
             and tension_operacion >= 110;
        
          if vCount = 0 then
            continue;
          end if;
        
        when elementoCircuito.g3e_fno = 19000 then
          --conductor
          if elementoCircuito.Fid_Padre = 0 then
            continue;
          end if;
        
          if elementoCircuito.Segmento > 0 then
            select codigo_ubicacion
              into vNivel
              from eam_ubicacion_temp
             where circuito = pCircuito
               and ubicacion = 'SEGMENTO'
               and g3e_fid = elementoCircuito.Fid_Padre;
          elsif elementoCircuito.Tramo > 0 then
            select codigo_ubicacion
              into vNivel
              from eam_ubicacion_temp
             where circuito = pCircuito
               and ubicacion = 'TRAMO'
               and g3e_fid = elementoCircuito.Fid_Padre;
          end if;
        
          insert into eam_activos_temp
          values
            (pCircuito,
             elementoCircuito.g3e_fid,
             19000,
             'CONDUCTOR',
             vNivel,
             6,
             elementoCircuito.Fid_Padre,
             elementoCircuito.Activo,
             elementoCircuito.Ordem,
             null,
             vACT);
          commit;
        
        when elementoCircuito.g3e_fno = 20400 then
          --transformador
        
          select codigo_ubicacion
            into vNivel
            from eam_ubicacion_temp
           where circuito = pCircuito
             and ubicacion = 'NODO'
             and g3e_fid = elementoCircuito.G3e_Fid;
        
          insert into eam_activos_temp
          values
            (pCircuito,
             elementoCircuito.g3e_fid,
             20400,
             'TRANSFORMADOR',
             vNivel,
             6,
             elementoCircuito.G3e_Fid,
             0,
             0,
             null,
             vACT);
          commit;
        
          --conductores secundarios
          for condSec in redSecundaria(elementoCircuito.nodo_Transform) loop
          
            select /* parallel */
             count(1)
              into vCount
              from eam_activos_temp
             where g3e_fid = condSec.g3e_fid
               and circuito = pCircuito;
          
            if vCount = 0 then
              insert into eam_activos_temp
              values
                (pCircuito,
                 condSec.g3e_fid,
                 21200,
                 'RED SECUNDARIA',
                 elementoCircuito.Nodo_Transform,
                 6,
                 elementoCircuito.G3e_Fid,
                 0,
                 0,
                 null,
                 vACT);
              commit;
            end if;
          end loop;
        
        else
          -- todos los otros elementos
        
          begin
            if elementoCircuito.Fid_Padre is null or
               elementoCircuito.Fid_Padre = 0 then
            
              --pegar fid padre
              if elementoCircuito.Segmento > 0 then
                select max(fid_padre)
                  into vPadre
                  from eam_traces
                 where segmento = elementoCircuito.Segmento
                   and circuito = pcircuito
                   and fid_padre != 0
                   and g3e_fno not in (19100, 19200)
                   and rownum = 1;
              elsif elementoCircuito.Tramo > 0 then
                select fid_padre
                  into vPadre
                  from eam_traces
                 where tramo = elementoCircuito.Tramo
                   and segmento = 0
                   and ramal = 0
                   and circuito = pcircuito
                   and fid_padre != 0
                   and g3e_fno not in (19100, 19200)
                   and rownum = 1;
              elsif elementoCircuito.G3e_Fno in (17900, 20100) then
                --puesta a tierra y pararrayo
                vPadre := elementoCircuito.g3e_sourcefid;
              elsif elementoCircuito.Tipo = 'Corte' then
                vPadre := elementoCircuito.g3e_fid;
              elsif elementoCircuito.Tipo = 'Corte Alimentador' then
                vPadre := elementoCircuito.g3e_fid;
              elsif elementoCircuito.Tipo = 'Transferencia' then
                vPadre := elementoCircuito.g3e_fid;
              end if;
            
            else
              vPadre := elementoCircuito.Fid_Padre;
            end if;
          
          exception
            when others then
              insert into eam_errors
              values
                (pcircuito,
                 elementoCircuito.G3e_Fid,
                 elementoCircuito.G3e_Fno,
                 sysdate,
                 'Elementos sin FID Padre');
              commit;
              continue;
            
          end;
        
          if vPadre is null or vPadre = 0 then
            continue;
          end if;
        
          begin
            if elementoCircuito.Segmento > 0 then
              select codigo_ubicacion
                into vNivel
                from eam_ubicacion_temp
               where circuito = pCircuito
                 and ubicacion = 'SEGMENTO'
                 and g3e_fid = vPadre;
            elsif elementoCircuito.Tramo > 0 then
              select codigo_ubicacion
                into vNivel
                from eam_ubicacion_temp
               where circuito = pCircuito
                 and ubicacion = 'TRAMO'
                 and g3e_fid = vPadre;
            elsif elementoCircuito.G3e_Fno in (17900, 20100) then
              select codigo_ubicacion
                into vNivel
                from eam_ubicacion_temp
               where circuito = pCircuito
                 and g3e_fid = vPadre;
            elsif elementoCircuito.Tipo = 'Corte' then
              select codigo_ubicacion
                into vNivel
                from eam_ubicacion_temp
               where circuito = pCircuito
                 and ubicacion = 'SEGMENTO'
                 and g3e_fid = vPadre;
            elsif elementoCircuito.Tipo = 'Corte Alimentador' or
                  elementoCircuito.Tipo = 'Transferencia' then
              select codigo_ubicacion
                into vNivel
                from eam_ubicacion_temp
               where circuito = pCircuito
                 and ubicacion = 'TRAMO'
                 and g3e_fid = vPadre;
            end if;
          exception
            when others then
              continue;
              --ATENCION: Un activo no tiene padre asociado. Hay que renerar un error!
          end;
        
          insert into eam_activos_temp
          values
            (pCircuito,
             elementoCircuito.g3e_fid,
             elementoCircuito.g3e_fno,
             upper(elementoCircuito.G3e_Username),
             vNivel,
             6,
             vPadre,
             0,
             0,
             null,
             vACT);
          commit;
        
      end case;
    
    end loop;
  
  end;

  procedure EAM_MANEJO_ACTIVO(pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type) is
  
    --esta funcion calcula recalcula los numeros de los activos despues de la primer ejecución
    --ATENCION:  los elementos que no hacem parte de un tamos/segmento no tendrón sus activos recalculados
    --y se quedaran con un nuevo numero de activo depues de toda ejecución del flujo
  
    cursor fidsPadre(pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type) is
      select t.fid_padre, u.codigo_ubicacion
        from eam_activos_temp t
       inner join eam_ubicacion_temp u
          on u.g3e_fid = t.fid_padre
       where t.circuito = pCircuito
         and t.fid_padre is not null
         and t.fid_padre > 0
       group by t.fid_padre, u.codigo_ubicacion;
  
    cursor activosPadre(pCircuito  CRED_TEN_CIR_CAT.CIRCUITO%TYPE,
                        fidPadre   NUMBER,
                        pUbicacion VARCHAR2) is
      select t.activo activo_new, a.activo activo_old, t.fid_padre padre
        from eam_activos_temp t
       inner join eam_activos_all a
          on a.g3e_fid = t.g3e_fid
       where t.fid_padre = fidPadre
         and t.g3e_fno = 19000
            --and t.fid_padre = a.fid_padre
         and a.ubicacion = pUbicacion
         and t.circuito = pCircuito
       group by t.activo, a.activo, t.fid_padre;
  
    vCount NUMBER;
  
  begin
  
    --Mirar si ya tiene los activos calculados para este circuito
    select /* parallel */
     count(1)
      into vCount
      from eam_activos_temp
     where circuito = pCircuito;
    if vCount = 0 then
      return;
    end if;
  
    --Processar los codigos de los elementos
    for fidPadre in fidsPadre(pCircuito) loop
      for activoPadre in activosPadre(pcircuito,
                                      fidPadre.fid_padre,
                                      fidPadre.codigo_ubicacion) loop
        --Mirar la cantidad anterior de conductores que pertencecen al mimo fid_padre
      
        update eam_activos_temp
           set activo = activoPadre.activo_old
         where activo = activoPadre.activo_new
           and fid_padre = fidPadre.fid_padre
           and circuito = pCircuito;
        commit;
      
      end loop;
    
    end loop;
  
  end;

  procedure EAM_CARGA_PARRILLA is
  
    contador        integer := 0;
    contador_loop   integer := 0;
    geometria_punto SDO_GEOMETRY;
    geom_x          float;
    geom_y          float;
    num_seq         number;
    vACT            date;
  
  begin
    vACT := sysdate;
  
    --limpia la tabla
    delete from eam_ubicacion_temp where circuito = 'PARRILLA';
    commit;
    update eam_activos_temp
       set circuito = 'PARRILLA_O'
     where circuito = 'PARRILLA';
    commit;
  
    --*****************************************************************************************
    --******************                  INSERTA NIVEL 4            **************************
    --*****************************************************************************************
  
    --Malla Oriental
    insert into eam_ubicacion_temp
      select 'PARRILLA',
             a.g3e_fid,
             a.g3e_fno,
             null,
             'MALLA PARRILLA' as ubicacion,
             '4' as nivel,
             'PARRILLA' as nivel_superior,
             'MALLAORIEN' as codigo_ubicacion,
             'MALLA ORIENTAL' as descripcion,
             vACT
        from eare_fun_at a
       where nombre_area = 'PARRILLA ORIENTAL';
  
    commit;
  
    --Malla Ocidental
    insert into eam_ubicacion_temp
      select 'PARRILLA',
             a.g3e_fid,
             a.g3e_fno,
             null,
             'MALLA PARRILLA' as ubicacion,
             '4' as nivel,
             'PARRILLA' as nivel_superior,
             'MALLAOCCIDEN' as codigo_ubicacion,
             'MALLA OCCIDENTAL' as descripcion,
             vACT
        from eare_fun_at a
       where nombre_area = 'PARRILLA OCCIDENTAL';
  
    commit;
  
    --*****************************************************************************************
    --******************                  INSERTA NIVEL 5            **************************
    --*****************************************************************************************
  
    --Cangrejo Oriental
    insert into eam_ubicacion_temp
      select 'PARRILLA',
             a.g3e_fid,
             a.g3e_fno,
             null,
             'CANGREJOS' as ubicacion,
             '5' as nivel,
             'MALLAORIEN' as nivel_superior,
             'CANGRORIE' as codigo_ubicacion,
             'CANGREJOS ORIENTAL' as descripcion,
             vACT
        from eare_fun_at a
       where nombre_area = 'PARRILLA ORIENTAL';
  
    commit;
  
    --Cangrejo Ocidental
    insert into eam_ubicacion_temp
      select 'PARRILLA',
             a.g3e_fid,
             a.g3e_fno,
             null,
             'CANGREJOS' as ubicacion,
             '5' as nivel,
             'MALLAOCCIDEN' as nivel_superior,
             'CANGROCCI' as codigo_ubicacion,
             'CANGREJOS OCCIDENTAL' as descripcion,
             vACT
        from eare_fun_at a
       where nombre_area = 'PARRILLA OCCIDENTAL';
  
    commit;
  
    --Tramos
  
    --*****************************************************************************************
    --******************           INSERTA CANGREJOS NIVEL 6 - ACTIVOS           **************************
    --*****************************************************************************************
  
    --Cangrejo Oriental
    insert into eam_activos_temp
      select 'PARRILLA',
             c.g3e_fid,
             c.g3e_fno,
             'CANGREJO',
             'CANGRORIE',
             '6' as nivel,
             c.g3e_fid,
             0,
             0,
             null,
             vACT
        from eare_fun_at a, eare_fun_ar ar, ecangrej_pt c
       where a.g3e_fid = ar.g3e_fid
         and sdo_contains(ar.g3e_geometry, c.g3e_geometry) = 'TRUE'
         and a.nombre_area = 'PARRILLA ORIENTAL';
  
    commit;
  
    --Cangrejo Occidental
    insert into eam_activos_temp
      select 'PARRILLA',
             c.g3e_fid,
             c.g3e_fno,
             'CANGREJO',
             'CANGROCCI',
             '6' as nivel,
             c.g3e_fid,
             0,
             0,
             null,
             vACT
        from eare_fun_at a, eare_fun_ar ar, ecangrej_pt c
       where a.g3e_fid = ar.g3e_fid
         and sdo_contains(ar.g3e_geometry, c.g3e_geometry) = 'TRUE'
         and a.nombre_area = 'PARRILLA OCCIDENTAL';
  
    commit;
  
    --*****************************************************************************************
    --******************                  INSERTA NIVEL 5 Y 6        **************************
    --*****************************************************************************************
  
    --Tramos y Conductores Secundarios
  
    --Pega todos los nodos duplicados que estan conectados a cangrejos en los dos lados
    for i in (select A.NODO1_ID, A.NODO2_ID
                from (select nodo1_id, nodo2_id
                        from cconectividad_e e, ECON_SES_AT a
                       where e.g3e_fno = 21200
                         and e.g3e_fid = a.g3e_fid
                         and a.tipo = 'PARRILLA'
                         and eam_check_conductor_parrilla(e.g3e_fid) = 1
                      union all
                      select nodo2_id as nodo1_id, nodo1_id as nodo2_id
                        from cconectividad_e e, ECON_SES_AT a
                       where e.g3e_fno = 21200
                         and e.g3e_fid = a.g3e_fid
                         and a.tipo = 'PARRILLA'
                         and eam_check_conductor_parrilla(e.g3e_fid) = 1) A
               group by (NODO1_ID, NODO2_ID)
              having count(1) > 1)
    
     loop
      for j in (select cond.g3e_fid, cond.g3e_geometry
                  from cconectividad_e c,
                       econ_ses_ln     cond,
                       ccomun          com,
                       econ_ses_at     cond_at
                 where c.g3e_fid = cond.g3e_fid
                   and cond.g3e_fid = com.g3e_fid
                   and com.g3e_fid = cond_at.g3e_fid
                   and cond_at.calibre in ('500', '4/0')
                   and com.estado != 'RETIRADO'
                   and cond_at.tipo = 'PARRILLA'
                   and ((c.nodo1_id = i.nodo1_id and c.nodo2_id = i.nodo2_id) or
                       (c.nodo1_id = i.nodo2_id and c.nodo2_id = i.nodo1_id))
                   and cond.g3e_fid not in
                       (select g3e_fid
                          from eam_activos_temp
                         where circuito IN ('PARRILLA'))) loop
        contador_loop := contador_loop + 1;
      
        select avg(x)
          into geom_x
          from (SELECT t.x
                  FROM TABLE(SDO_UTIL.GetVertices(j.g3e_geometry)) t
                 where t.ID = 1
                union all
                SELECT t.x
                  FROM TABLE(SDO_UTIL.GetVertices(j.g3e_geometry)) t
                 where t.ID = SDO_UTIL.GetNumVertices(j.g3e_geometry));
      
        select avg(y)
          into geom_y
          from (SELECT t.y
                  FROM TABLE(SDO_UTIL.GetVertices(j.g3e_geometry)) t
                 where t.ID = 1
                union all
                SELECT t.y
                  FROM TABLE(SDO_UTIL.GetVertices(j.g3e_geometry)) t
                 where t.ID = SDO_UTIL.GetNumVertices(j.g3e_geometry));
      
        geometria_punto := SDO_GEOMETRY(3001,
                                        4326,
                                        NULL,
                                        sdo_elem_info_array(1, 1, 1, 4, 1, 0),
                                        SDO_ORDINATE_ARRAY(geom_x,
                                                           geom_y,
                                                           0,
                                                           0,
                                                           0,
                                                           0));
      
        select /* parallel */
         count(1)
          into contador
          FROM EARE_FUN_AR EARE, EARE_FUN_AT EARE_AT
         WHERE SDO_CONTAINS(EARE.G3E_GEOMETRY, geometria_punto) = 'TRUE'
           AND EARE.G3E_FID = EARE_AT.G3E_FID
           AND EARE_AT.nombre_area = 'PARRILLA ORIENTAL';
        --si es parte de parrilla oriental
        dbms_output.put_line('Parrilla Oriental');
        if contador > 0 then
          --si es el primero conductor del grupo inserta el tramo
          if contador_loop = 1 then
          
            begin
              select nvl(to_number(replace(ubicacion, 'TSP', '')), 0)
                into num_seq
                from eam_activos_temp
               where circuito = 'PARRILLA_O'
                 and g3e_fid = j.g3e_fid;
            
              dbms_output.put_line('FOUND: ' || num_seq);
            
              if num_seq is null or num_seq = 0 then
                dbms_output.put_line('NVAL');
                num_seq := eam_parrilla_seq.nextval;
              end if;
            
            exception
              when others then
                dbms_output.put_line('NVAL');
                num_seq := eam_parrilla_seq.nextval;
            end;
            dbms_output.put_line('USED:' || num_seq);
            insert into eam_ubicacion_temp
            values
              ('PARRILLA',
               j.g3e_fid,
               21200,
               null,
               'TRAMO PARRILLA',
               5,
               'MALLAORIEN',
               'TSP' || num_seq,
               'TRAMO PARRILLA ' || num_seq,
               vACT);
            commit;
            insert into eam_activos_temp
            values
              ('PARRILLA',
               j.g3e_fid,
               21200,
               'CONDUCTOR',
               'TSP' || num_seq,
               6,
               null,
               0,
               0,
               null,
               vACT);
            commit;
          else
            insert into eam_activos_temp
            values
              ('PARRILLA',
               j.g3e_fid,
               21200,
               'CONDUCTOR',
               'TSP' || num_seq,
               6,
               null,
               0,
               0,
               null,
               vACT);
            commit;
          end if;
        end if;
      
        select /* parallel */
         count(1)
          into contador
          FROM EARE_FUN_AR EARE, EARE_FUN_AT EARE_AT
         WHERE SDO_CONTAINS(EARE.G3E_GEOMETRY, geometria_punto) = 'TRUE'
           AND EARE.G3E_FID = EARE_AT.G3E_FID
           AND EARE_AT.nombre_area = 'PARRILLA OCCIDENTAL';
        --si es parte de parrilla occidental
      
        if contador > 0 then
          --si es el primero conductor del grupo inserta el tramo
          if contador_loop = 1 then
            begin
              select nvl(to_number(replace(ubicacion, 'TSP', '')), 0)
                into num_seq
                from eam_activos_temp
               where circuito = 'PARRILLA_O'
                 and g3e_fid = j.g3e_fid;
            
              dbms_output.put_line('FOUND: ' || num_seq);
            
              if num_seq is null or num_seq = 0 then
                dbms_output.put_line('NVAL');
                num_seq := eam_parrilla_seq.nextval;
              end if;
            exception
              when others then
                dbms_output.put_line('NVAL');
                num_seq := eam_parrilla_seq.nextval;
            end;
            dbms_output.put_line('USED:' || num_seq);
            insert into eam_ubicacion_temp
            values
              ('PARRILLA',
               j.g3e_fid,
               21200,
               null,
               'TRAMO PARRILLA',
               5,
               'MALLAOCCIDEN',
               'TSP' || num_seq,
               'TRAMO PARRILLA ' || num_seq,
               vACT);
            commit;
            insert into eam_activos_temp
            values
              ('PARRILLA',
               j.g3e_fid,
               21200,
               'CONDUCTOR',
               'TSP' || num_seq,
               6,
               null,
               0,
               0,
               null,
               vACT);
            commit;
          else
            insert into eam_activos_temp
            values
              ('PARRILLA',
               j.g3e_fid,
               21200,
               'CONDUCTOR',
               'TSP' || num_seq,
               6,
               null,
               0,
               0,
               null,
               vACT);
            commit;
          end if;
        end if;
      end loop;
      contador_loop := 0;
    end loop;
  
    --Inserta los conductores de los tramos que contienen solo un elemento
  
    for j in (select cond.g3e_fid, cond.g3e_geometry
                from econ_ses_ln cond, ccomun com, econ_ses_at cond_at
               where cond.g3e_fid = com.g3e_fid
                 and com.g3e_fid = cond_at.g3e_fid
                 and com.estado != 'RETIRADO'
                 and cond_at.calibre in ('500', '4/0')
                 and cond_at.tipo = 'PARRILLA'
                 and cond.g3e_fid not in
                     (select g3e_fid
                        from eam_activos_temp
                       where CIRCUITO = 'PARRILLA')
                 and eam_check_conductor_parrilla(cond.g3e_fid) = 1) loop
    
      select avg(x)
        into geom_x
        from (SELECT t.x
                FROM TABLE(SDO_UTIL.GetVertices(j.g3e_geometry)) t
               where t.ID = 1
              union all
              SELECT t.x
                FROM TABLE(SDO_UTIL.GetVertices(j.g3e_geometry)) t
               where t.ID = SDO_UTIL.GetNumVertices(j.g3e_geometry));
    
      select avg(y)
        into geom_y
        from (SELECT t.y
                FROM TABLE(SDO_UTIL.GetVertices(j.g3e_geometry)) t
               where t.ID = 1
              union all
              SELECT t.y
                FROM TABLE(SDO_UTIL.GetVertices(j.g3e_geometry)) t
               where t.ID = SDO_UTIL.GetNumVertices(j.g3e_geometry));
    
      geometria_punto := SDO_GEOMETRY(3001,
                                      4326,
                                      NULL,
                                      sdo_elem_info_array(1, 1, 1, 4, 1, 0),
                                      SDO_ORDINATE_ARRAY(geom_x,
                                                         geom_y,
                                                         0,
                                                         0,
                                                         0,
                                                         0));
    
      select /* parallel */
       count(1)
        into contador
        FROM EARE_FUN_AR EARE, EARE_FUN_AT EARE_AT
       WHERE SDO_CONTAINS(EARE.G3E_GEOMETRY, geometria_punto) = 'TRUE'
         AND EARE.G3E_FID = EARE_AT.G3E_FID
         AND EARE_AT.nombre_area = 'PARRILLA ORIENTAL';
      --si es parte de parrilla oriental
      if contador > 0 then
      
        begin
          select nvl(to_number(replace(ubicacion, 'TSP', '')), 0)
            into num_seq
            from eam_activos_temp
           where circuito = 'PARRILLA_O'
             and g3e_fid = j.g3e_fid;
          dbms_output.put_line(num_seq);
          if num_seq is null or num_seq = 0 then
            num_seq := eam_parrilla_seq.nextval;
          end if;
        exception
          when others then
            num_seq := eam_parrilla_seq.nextval;
        end;
      
        insert into eam_ubicacion_temp
        values
          ('PARRILLA',
           j.g3e_fid,
           21200,
           null,
           'TRAMO PARRILLA',
           5,
           'MALLAORIEN',
           'TSP' || num_seq,
           'TRAMO PARRILLA ' || num_seq,
           vACT);
        commit;
        insert into eam_activos_temp
        values
          ('PARRILLA',
           j.g3e_fid,
           21200,
           'CONDUCTOR',
           'TSP' || num_seq,
           6,
           null,
           0,
           0,
           null,
           vACT);
        commit;
      end if;
    
      select /* parallel */
       count(1)
        into contador
        FROM EARE_FUN_AR EARE, EARE_FUN_AT EARE_AT
       WHERE SDO_CONTAINS(EARE.G3E_GEOMETRY, geometria_punto) = 'TRUE'
         AND EARE.G3E_FID = EARE_AT.G3E_FID
         AND EARE_AT.nombre_area = 'PARRILLA OCCIDENTAL';
      --si es parte de parrilla occidental
    
      if contador > 0 then
        begin
          select nvl(to_number(replace(ubicacion, 'TSP', '')), 0)
            into num_seq
            from eam_activos_temp
           where circuito = 'PARRILLA_O'
             and g3e_fid = j.g3e_fid;
          dbms_output.put_line(num_seq);
          if num_seq is null or num_seq = 0 then
            num_seq := eam_parrilla_seq.nextval;
          end if;
        exception
          when others then
            num_seq := eam_parrilla_seq.nextval;
        end;
      
        insert into eam_ubicacion_temp
        values
          ('PARRILLA',
           j.g3e_fid,
           21200,
           null,
           'TRAMO PARRILLA',
           5,
           'MALLAOCCIDEN',
           'TSP' || num_seq,
           'TRAMO PARRILLA ' || num_seq,
           vACT);
        commit;
        insert into eam_activos_temp
        values
          ('PARRILLA',
           j.g3e_fid,
           21200,
           'CONDUCTOR',
           'TSP' || num_seq,
           6,
           null,
           0,
           0,
           null,
           vACT);
        commit;
      end if;
    end loop;
  
    delete from eam_activos_temp where circuito = 'PARRILLA_O';
    commit;
  
    EAM_MANEJO_NOVEDADES('PARRILLA');
    EAM_MANEJO_RETIRADOS('PARRILLA');
  
  end;

  function EAM_CHECK_CONDUCTOR_PARRILLA(fid in number) return integer is
    node1            cconectividad_e.nodo1_id%type;
    node2            cconectividad_e.nodo2_id%type;
    countNode1       number(3) := 0;
    countNode2       number(3) := 0;
    countNode1_Trafo number(3) := 0;
    countNode2_Trafo number(3) := 0;
  
  begin
  
    select nodo1_id
      into node1
      from cconectividad_e c
     where c.g3e_fid = fid;
    select nodo2_id
      into node2
      from cconectividad_e c
     where c.g3e_fid = fid;
  
    if (node1 = 0 or node2 = 0) then
      return 0;
    end if;
  
    select /* parallel */
     count(1)
      into countNode1
      from cconectividad_e
     where nodo1_id in (node1, node2)
       and g3e_fno = 21700;
  
    select /* parallel */
     count(1)
      into countNode2
      from cconectividad_e
     where nodo2_id in (node1, node2)
       and g3e_fno = 21700;
  
    select /* parallel */
     count(1)
      into countNode1_Trafo
      from cconectividad_e
     where nodo1_id in (node1, node2)
       and g3e_fno = 20400;
    select /* parallel */
     count(1)
      into countNode2_Trafo
      from cconectividad_e
     where nodo2_id in (node1, node2)
       and g3e_fno = 20400;
  
    --if (countNode1 > 0 and countNode2 > 0) then
    if ((countNode1 > 0 and countNode2 > 0) or
       (countNode1 > 0 and (countNode1_Trafo > 0 or countNode2_Trafo > 0)) or
       (countNode2 > 0 and (countNode1_Trafo > 0 or countNode2_Trafo > 0))) then
      return 1;
    else
      return 0;
    end if;
  
  end;

  function EAM_BIFURCACION(pNodo     IN NUMBER,
                           pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type,
                           pTipo     IN NUMBER DEFAULT 1,
                           pDatos    IN EAM_NODO_TABLE DEFAULT EAM_NODO_TABLE())
    return number is
  
    vNodo  NUMBER(10);
    vCondu NUMBER := 0;
    vCount NUMBER;
    vDatos EAM_NODO_TABLE := pDatos;
  
    cursor nodos(vCircuito CRED_TEN_CIR_CAT.CIRCUITO%type, vNodo number) is
      select *
        from eam_traces
       where (g3e_node1 = nvl(nullif(vNodo, 0), -1) or
             g3e_node2 = nvl(nullif(vNodo, 0), -1))
         and circuito = vCircuito;
  begin
    --Verificar si el registro ya fue procesado y no tene run loop infinito
    select /* parallel */
     count(1)
      into vCount
      from table(vDatos)
     where g3e_sourcenode = pNodo;
    if vCount > 0 then
      return 0;
    else
      vDatos.extend();
      vDatos(vDatos.COUNT) := eam_nodo(null,
                                       null,
                                       null,
                                       pNodo,
                                       null,
                                       null,
                                       null);
    end if;
  
    for elemento in nodos(pCircuito, pNodo) loop
      if elemento.g3e_fno = 19000 then
        if pTipo = 2 and elemento.Tipo = 'Alimentador' then
          vCondu := vCondu + 1;
        elsif pTipo = 3 and elemento.Tipo = 'Ramal' then
          vCondu := vCondu + 1;
        elsif pTipo = 1 then
          vCondu := vCondu + 1;
        end if;
      else
        vNodo := 0;
        if elemento.g3e_node1 != pNodo then
          vNodo := elemento.g3e_node1;
        elsif elemento.g3e_node2 != pNodo then
          vNodo := elemento.g3e_node2;
        end if;
      
        if vNodo != 0 then
          vCondu := vCondu +
                    EAM_BIFURCACION(vNodo, pCircuito, pTipo, vDatos);
        end if;
      end if;
    
    end loop;
  
    return vCondu;
  end;

  procedure EAM_LIMPIAR_TABLAS is
  
  begin
    --execute immediate 'truncate table eam_circuitos';
    execute immediate 'truncate table eam_errors';
    execute immediate 'truncate table eam_ubicacion_ret';
    execute immediate 'truncate table eam_ubicacion';
    execute immediate 'truncate table eam_ubicacion_temp';
    execute immediate 'truncate table eam_activos_temp';
    execute immediate 'truncate table eam_activos_ret';
    execute immediate 'truncate table eam_activos_all';
    execute immediate 'truncate table eam_traces';
    commit;
  
  end;

  procedure EAM_POBLAR_TABLA_CIRCUITOS(pLimpiarTabla NUMBER DEFAULT 0) is
  
  begin
    if (pLimpiarTabla = 1) Then
      execute immediate 'truncate table eam_circuitos';
    end if;
    insert into eam_circuitos
      (circuito, status, avance, tiempo, grupo, fecha_conclusion)
      select circuito, '', '', '', 0, ''
        from (select distinct circuito
                from cconectividad_e
               where g3e_fno = 18800
                 and tipo_red != 'TRANSMISION'
              minus
              select circuito
                from eam_circuitos);
    commit;
  end;

  procedure EAM_FLUJO(pGrupo         NUMBER DEFAULT 0,
                      pLimpiarTablas NUMBER DEFAULT 0,
                      timeout_min    NUMBER DEFAULT 15) is
  
  begin
  
    if pLimpiarTablas = 1 then
      EAM_LIMPIAR_TABLAS;
    end if;
  
    EAM_RESPALDAR_TABLAS;
    EAM_POBLAR_TABLA_CIRCUITOS;
    EAM_DISTRIBUIR_NOVEDADES_CIRS(1, pGrupo);
    EAM_TAXONOMIA_TRANSMISION;
    EAM_ESTRUCTURA_CIVIL;
    EAM_CALCULAR_ACTIVOS_CIVIL;
    EAM_CARGA_PARRILLA;
    EAM_FLUJO_CIRS(pGrupo, timeout_min);
  
  end;

  procedure EAM_DISTRIBUIR_NOVEDADES_CIRS(numGrupos    number,
                                          grupoInicial number) is
    cursor cur_circuitos_novedades is
      select circuito,
             extract(HOUR from TO_TIMESTAMP(TIEMPO, 'HH24:MI:SS.FF')) * 3600 +
             extract(MINUTE from TO_TIMESTAMP(TIEMPO, 'HH24:MI:SS.FF')) * 60 +
             extract(SECOND from TO_TIMESTAMP(TIEMPO, 'HH24:MI:SS.FF')) tiempo
        from (select circuito, nvl(tiempo, '00:01:00.000000000') tiempo
                from eam_circuitos
               where fecha_conclusion is null
              union
              select distinct c.circuito,
                              nvl(tiempo, '00:01:00.000000000') tiempo
                from cconectividad_e c, reg_transacciones r, eam_circuitos e
               where r.fid = c.g3e_fid
                 and c.circuito = e.circuito
                 and r.fecha_movimiento > e.fecha_conclusion
                 and c.circuito is not null
              union
              select distinct c.circuito,
                              nvl(tiempo, '00:01:00.000000000') tiempo
                from reg_transacciones  r,
                     eam_circuitos      c,
                     eam_activos_temp   a,
                     eam_ubicacion_temp u
               where r.atributo like '%CIRCUITO%'
                 and r.fid = a.g3e_fid(+)
                 and u.g3e_fid(+) = r.fid
                 and a.circuito = c.circuito
                 and r.fecha_movimiento > c.fecha_conclusion)
       order by tiempo desc;
  
    tiempoTotal number;
    tiempoGrupo number;
    grupo_i     number;
    idGrupo     number;
    tiempoAcum  number;
  
  begin
    tiempoTotal := 0;
    for reg_cir_nov in cur_circuitos_novedades loop
      tiempoTotal := tiempoTotal + reg_cir_nov.tiempo;
    end loop;
    tiempoGrupo := tiempoTotal / numGrupos;
    grupo_i     := 1;
    idGrupo     := grupoInicial;
    tiempoAcum  := 0;
  
    update eam_circuitos set grupo = null;
    commit;
    --dbms_output.put_line ('Tiempo total: '||tiempoTotal);
    --dbms_output.put_line ('Tiempo por job: '||tiempoGrupo);
  
    for reg_cir_nov in cur_circuitos_novedades loop
    
      update eam_circuitos
         set grupo = idGrupo
       where circuito = reg_cir_nov.circuito;
      commit;
    
      tiempoAcum := tiempoAcum + reg_cir_nov.tiempo;
    
      if tiempoAcum >= tiempoGrupo and grupo_i < numGrupos then
        grupo_i    := grupo_i + 1;
        idGrupo    := idGrupo + 1;
        tiempoAcum := 0;
      end if;
    
    end loop;
  end;

  procedure EAM_RESPALDAR_TABLAS is
  begin
    begin
      execute immediate 'drop table eam_ubicacion_bk';
    end;
  
    begin
      execute immediate 'create table eam_ubicacion_bk as select * from eam_ubicacion_temp';
    end;
  
    begin
      execute immediate 'drop table eam_ubicacion_retirados_bk';
    end;
  
    begin
      execute immediate 'create table eam_ubicacion_retirados_bk as select * from eam_ubicacion_retirados';
    end;
  
    begin
      execute immediate 'drop table eam_activos_bk';
    end;
  
    begin
      execute immediate 'create table eam_activos_bk as select * from eam_activos_temp';
    end;
  
    begin
      execute immediate 'drop table eam_activos_retirados_bk';
    end;
  
    begin
      execute immediate 'create table eam_activos_retirados_bk as select * from eam_activos_retirados';
    end;
  
    begin
      execute immediate 'drop table eam_circuitos_bk';
    end;
  
    begin
      execute immediate 'create table eam_circuitos_bk as select * from eam_circuitos';
    end;
  
  end;

  procedure EAM_ESTRUCTURA_CIVIL is
  
    vCodRegion varchar(20);
  
    cursor SUBREGIONES is
      select *
        from eare_fun_at
       where tipo_area = 'SUBREGION'
         and g3e_Fno = 22600;
  
    cursor REGIONES is
      select * from eare_fun_at where tipo_area = 'REGION';
  
  begin
  
    delete from eam_ubicacion_temp where circuito = 'ESTRUCTURA';
    commit;
  
    /* Carga la ubicacion de nivel 4: Region */
  
    for region in regiones loop
      insert into eam_ubicacion_temp
        (circuito,
         g3e_fid,
         g3e_fno,
         codigo,
         ubicacion,
         nivel,
         nivel_superior,
         codigo_ubicacion,
         descripcion)
      values
        ('ESTRUCTURA',
         region.g3e_fid,
         region.g3e_fno,
         null,
         'REGION',
         4,
         'INFRAECIVIL',
         'RGN' || region.g3e_fid,
         'REGION ' || region.nombre_area);
      commit;
    end loop;
  
    /* Carga la ubicacion de nivel 5: Subregion */
  
    for subregion in subregiones loop
      select codigo_ubicacion
        into vCodRegion
        from eam_ubicacion_temp
       where g3e_fid = subregion.fid_padre;
      insert into eam_ubicacion_temp
        (circuito,
         g3e_fid,
         g3e_fno,
         codigo,
         ubicacion,
         nivel,
         nivel_superior,
         codigo_ubicacion,
         descripcion)
      values
        ('ESTRUCTURA',
         subregion.g3e_fid,
         subregion.g3e_fno,
         NULL,
         'SUBREGION',
         5,
         vCodRegion,
         'SRG' || subregion.g3e_fid,
         'SUBREGION ' || subregion.nombre_area);
      commit;
    end loop;
  
  end;

  procedure EAM_CALCULAR_ACTIVOS_CIVIL is
    vCount number(2);
  begin
    for q in (select COM.G3E_FID,
                     COM.G3E_FNO,
                     UBICA.CODIGO_UBICACION,
                     AREA.G3E_FID FIDSUBREGION
                from CCOMUN COM
               inner join EARE_FUN_AT AREA
                  on COM.SUBREGION = AREA.NOMBRE_AREA
               inner join eam_ubicacion_temp UBICA
                  on UBICA.G3E_FID = AREA.G3E_FID
               where COM.G3E_FNO in (22800, 17400, 17300, 17100)
                 and UBICA.CODIGO_UBICACION is not null
                 and SUBREGION is not null
                 and AREA.TIPO_AREA = 'SUBREGION') loop
    
      if q.g3e_fno = 17100 then
        select count(1)
          into vCount
          from eposte_at
         where g3e_fid = q.g3e_fid
           and uso = 'TRANSMISION ENERGIA';
      
        if vCount = 0 then
          continue;
        end if;
      end if;
    
      if q.g3e_fno = 17400 then
        select count(1)
          into vCount
          from ecamara_at
         where g3e_fid = q.g3e_fid
           and uso = 'TRANSMISION';
      
        if vCount = 0 then
          continue;
        end if;
      end if;
    
      if q.g3e_fno = 17300 then
        select count(1)
          into vCount
          from ECANALIZ_AT
         where g3e_fid = q.g3e_fid
           and uso = 'TRANSMISION';
      
        if vCount = 0 then
          continue;
        end if;
      end if;
    
      insert into eam_activos_temp
        (CIRCUITO,
         G3E_FID,
         G3E_FNO,
         ACTIVO_NOMBRE,
         UBICACION,
         NIVEL,
         FID_PADRE,
         ACTIVO,
         ORDEM)
      values
        ('ESTRUCTURA',
         Q.G3E_FID,
         Q.G3E_FNO,
         case when Q.G3E_FNO = 17400 then 'CAMARA' when Q.G3E_FNO = 17100 then
         'POSTE' when Q.G3E_FNO = 22800 then 'BANCO DE DUCTOS' when
         Q.G3E_FNO = 17300 then 'CANALIZACION' end,
         Q.CODIGO_UBICACION,
         6,
         Q.FIDSUBREGION,
         null,
         null);
    end loop;
    commit;
  
    EAM_MANEJO_ACTIVO('ESTRUCTURA');
    EAM_MANEJO_NOVEDADES('ESTRUCTURA');
    EAM_MANEJO_RETIRADOS('ESTRUCTURA');
  
  end;

  procedure EAM_TAXONOMIA_TRANSMISION is
  
    cursor cInterruptorLineas(corredor VARCHAR2) is
      select con.g3e_fno, con.g3e_fid, k.circuito, k.cod_linea
        from cconectividad_e con
       inner join (select conn.circuito, corr.cod_linea
                     from cconectividad_e conn
                    inner join (select distinct codigo as cod_linea
                                 from econ_tra_at
                                where corredor_nro = corredor) corr
                       on corr.cod_linea = conn.codigo
                    where conn.tipo_red = 'TRANSMISION'
                      and circuito is not null
                    group by conn.circuito, corr.cod_linea) k
          on k.circuito = con.circuito
       where con.g3e_fno = 18800
       order by k.cod_linea asc;
  
    vLinea  number(2);
    vActivo number(10);
    vOrdem  number(5);
    vCount  number(3);
    vCorte  elementos_corte;
    vACT    date;
  
    type arrLinea is table of varchar2(100);
    lineas arrLinea := arrLinea();
  
  begin
    vACT := sysdate;
    --Corredores
    for corredor in (select distinct corredor_nro
                       from econ_tra_at
                      where corredor_nro is not null) loop
    
      vLinea := 0;
      for linea in cInterruptorLineas(corredor.corredor_nro) loop
        vLinea := vLinea + 1;
      
        --Ubicaciones
        if vLinea = 1 then
          insert into eam_ubicacion_temp
          values
            (linea.circuito,
             linea.g3e_fid,
             linea.g3e_fno,
             corredor.corredor_nro,
             'CORREDOR',
             4,
             'CORREDORES',
             'COR-' || corredor.corredor_nro,
             'CORREDOR ' || corredor.corredor_nro,
             vACT);
        
          insert into eam_ubicacion_temp
          values
            (linea.circuito,
             linea.g3e_fid,
             linea.g3e_fno,
             corredor.corredor_nro,
             'ESTRUCTURAS',
             5,
             'COR-' || corredor.corredor_nro,
             'EST-' || corredor.corredor_nro,
             'ESTRUCTURAS CORREDOR ' || corredor.corredor_nro,
             vACT);
          commit;
        end if;
      
        insert into eam_ubicacion_temp
        values
          (linea.circuito,
           linea.g3e_fid,
           linea.g3e_fno,
           linea.cod_linea,
           'LINEA',
           5,
           'COR-' || corredor.corredor_nro,
           'LIN-' || linea.cod_linea,
           'LINEA ' || linea.cod_linea || ' CORREDOR ' ||
           corredor.corredor_nro,
           vACT);
        commit;
      
        --Activos
        vCount := 0;
        for i in 1 .. lineas.count loop
          if lineas(i) = linea.circuito then
            vCount := 1;
          end if;
        end loop;
      
        if vCount = 1 then
          continue;
        else
          lineas.extend();
          lineas(lineas.count) := linea.circuito;
        end if;
      
        delete from eam_traces where circuito = linea.circuito;
        commit;
        vCorte  := eam_trace_cir(linea.circuito);
        vActivo := eam_activo.nextval;
        vOrdem  := 0;
      
        --Conductores Transmision
        for conducTrans in (select circuito, G3e_Fid, g3e_fno
                              from eam_traces
                             where circuito = linea.circuito
                               and g3e_fno = 18900
                             order by g3e_traceorder asc) loop
        
          vOrdem := vOrdem + 1;
          insert into eam_activos_temp
          values
            (conducTrans.circuito,
             conducTrans.G3e_Fid,
             conducTrans.g3e_fno,
             'LINEA',
             'LIN-' || linea.cod_linea,
             6,
             linea.g3e_fid,
             vActivo,
             vOrdem,
             null,
             vACT);
          commit;
        
        end loop; --Conductores de Trasmision
      
        --Camaras
        for camara in (select cam.g3e_fid, cam.g3e_fno
                         from ecamara_at cam
                        inner join ccontenedor con
                           on con.g3e_fid = cam.g3e_fid
                          and con.g3e_fno = cam.g3e_fno
                        where cam.uso = 'TRANSMISION'
                          and con.g3e_ownerfno = 18900
                          and con.g3e_ownerfid in
                              (select g3e_fid
                                 from eam_traces
                                where circuito = linea.circuito)
                        group by cam.g3e_fid, cam.g3e_fno) loop
        
          insert into eam_activos_temp
          values
            (linea.circuito,
             camara.G3e_Fid,
             camara.g3e_fno,
             'CAMARA',
             'EST-' || corredor.corredor_nro,
             6,
             linea.g3e_fid,
             null,
             null,
             null,
             vACT);
          commit;
        
        end loop; --Camara
      
        --Ducto
        for ducto in (select duc.g3e_fid, duc.g3e_fno
                        from educto_at duc
                       inner join ccontenedor con
                          on con.g3e_fid = duc.g3e_fid
                         and con.g3e_fno = duc.g3e_fno
                       where duc.uso = 'TRANSMISION'
                         and con.g3e_ownerfno = 18900
                         and con.g3e_ownerfid in
                             (select g3e_fid
                                from eam_traces
                               where circuito = linea.circuito)
                       group by duc.g3e_fid, duc.g3e_fno) loop
        
          insert into eam_activos_temp
          values
            (linea.circuito,
             ducto.G3e_Fid,
             ducto.g3e_fno,
             'DUCTO',
             'EST-' || corredor.corredor_nro,
             7,
             linea.g3e_fid,
             null,
             null,
             null,
             vACT);
          commit;
        
        end loop; --Ductos
      
        --Canalización
        for canalizacion in (select can.g3e_fid, can.g3e_fno
                               from ecanaliz_at can
                              inner join ccontenedor con
                                 on con.g3e_fid = can.g3e_fid
                                and con.g3e_fno = can.g3e_fno
                              where can.uso = 'TRANSMISION'
                                and con.g3e_ownerfno = 18900
                                and con.g3e_ownerfid in
                                    (select g3e_fid
                                       from eam_traces
                                      where circuito = linea.circuito)
                              group by can.g3e_fid, can.g3e_fno) loop
        
          insert into eam_activos_temp
          values
            (linea.circuito,
             canalizacion.G3e_Fid,
             canalizacion.g3e_fno,
             'CANALIZACION',
             'EST-' || corredor.corredor_nro,
             7,
             linea.g3e_fid,
             null,
             null,
             null,
             vACT);
          commit;
        
        end loop; --Canalizacion
      
        --Poste
        for poste in (select pos.g3e_fid, pos.g3e_fno
                        from eposte_at pos
                       inner join ccontenedor con
                          on con.g3e_ownerfid = pos.g3e_fid
                         and con.g3e_ownerfno = pos.g3e_fno
                       where pos.uso = 'TRANSMISION ENERGIA'
                         and con.g3e_fno = 18900
                         and con.g3e_fid in
                             (select g3e_fid
                                from eam_traces
                               where circuito = linea.circuito)
                       group by pos.g3e_fid, pos.g3e_fno) loop
        
          insert into eam_activos_temp
          values
            (linea.circuito,
             poste.G3e_Fid,
             poste.g3e_fno,
             'POSTE',
             'EST-' || corredor.corredor_nro,
             6,
             linea.g3e_fid,
             null,
             null,
             null,
             vACT);
          commit;
        
        end loop; --Poste
      
        --Torre
        for torre in (select tor.g3e_fid, tor.g3e_fno
                        from etor_trm_at tor
                       inner join ccontenedor con
                          on con.g3e_ownerfid = tor.g3e_fid
                         and con.g3e_ownerfno = tor.g3e_fno
                       where tor.clase_torre != 'PORTICO'
                         and con.g3e_fno = 18900
                         and con.g3e_fid in
                             (select g3e_fid
                                from eam_traces
                               where circuito = linea.circuito)
                       group by tor.g3e_fid, tor.g3e_fno) loop
        
          insert into eam_activos_temp
          values
            (linea.circuito,
             torre.G3e_Fid,
             torre.g3e_fno,
             'TORRE',
             'EST-' || corredor.corredor_nro,
             7,
             linea.g3e_fid,
             null,
             null,
             null,
             vACT);
          commit;
        
        end loop; --Torre
      
        --Portico
        for torre in (select tor.g3e_fid, tor.g3e_fno
                        from etor_trm_at tor
                       inner join ccontenedor con
                          on con.g3e_ownerfid = tor.g3e_fid
                         and con.g3e_ownerfno = tor.g3e_fno
                       where tor.clase_torre = 'PORTICO'
                         and con.g3e_fno = 18900
                         and con.g3e_fid in
                             (select g3e_fid
                                from eam_traces
                               where circuito = linea.circuito)
                       group by tor.g3e_fid, tor.g3e_fno) loop
        
          insert into eam_activos_temp
          values
            (linea.circuito,
             torre.G3e_Fid,
             torre.g3e_fno,
             'PORTICO',
             'EST-' || corredor.corredor_nro,
             7,
             linea.g3e_fid,
             null,
             null,
             null,
             vACT);
          commit;
        
        end loop; --Portico
      
        --Pararrayos
        for para in (select g3e_fid, g3e_fno
                       from cconectividad_e
                      where circuito = linea.circuito
                        and g3e_fno = 20100
                        and tension > 110
                      group by g3e_fid, g3e_fno) loop
        
          insert into eam_activos_temp
          values
            (linea.circuito,
             para.G3e_Fid,
             para.g3e_fno,
             'PARARRAYOS',
             'LIN-' || linea.cod_linea,
             7,
             linea.g3e_fid,
             null,
             null,
             null,
             vACT);
          commit;
        
        end loop; --Pararrayos
      
        if vLinea = 1 then
          EAM_MANEJO_ACTIVO(linea.circuito);
          EAM_MANEJO_NOVEDADES(linea.circuito);
          EAM_MANEJO_RETIRADOS(linea.circuito);
        end if;
      
      end loop; --Linea
    
    end loop; --Corredores
  
  end;

  procedure EAM_MANEJO_RETIRADOS(pCircuito in VARCHAR2) is
    vFechaEjec date;
  begin
    vFechaEjec := sysdate;
  
    insert into eam_activos_ret
      (activo,
       activo_nombre,
       circuito,
       descripcion,
       fecha_act,
       fid_padre,
       g3e_fid,
       g3e_fno,
       nivel,
       ordem,
       ubicacion)
      select ea.activo,
             ea.activo_nombre,
             ea.circuito,
             ea.descripcion,
             vFechaEjec,
             ea.fid_padre,
             ea.g3e_fid,
             ea.g3e_fno,
             ea.nivel,
             ea.ordem,
             ea.ubicacion
        from eam_activos_all ea
       inner join ccomun c
          on (c.g3e_fid = ea.g3e_fid and c.g3e_fno = ea.g3e_fno)
       where c.estado = 'RETIRADO'
         and ea.circuito = pCircuito
         and not exists (select g3e_fid
                from eam_activos_ret
               where g3e_fid = ea.g3e_fid
                 and g3e_fno = ea.g3e_fno);
  
    commit;
  
    --Actualizar tabla eam_activos_all = elementos en operacion + retirados - returados parciales
    delete from eam_activos_all where circuito = pCircuito;
    commit;
  
    -- los que no fueron retirados
    insert into eam_activos_all
      select ea.*
        from eam_activos_temp ea
       where not exists
       (select g3e_fid from eam_activos_ret where g3e_fid = ea.g3e_fid)
         and ea.circuito = pCircuito;
  
    commit;
  
    -- los que no son retiros lineares agrupados
    insert into eam_activos_all
      select *
        from eam_activos_ret
       where nvl(activo, 0) = 0
         and circuito = pCircuito;
  
    commit;
  
    -- los que son retiros lineares completos
    insert into eam_activos_all
      select *
        from eam_activos_ret
       where activo not in
             (select distinct activo
                from eam_activos_all
               where activo in (select distinct activo
                                  from eam_activos_ret
                                 where nvl(activo, 0) != 0))
         and nvl(activo, 0) != 0
         and circuito = pCircuito;
    commit;
  
  end;

  procedure EAM_MANEJO_NOVEDADES(pCircuito in VARCHAR2) is
    vFechaEjec date;
  begin
  
    select sysdate into vFechaEjec from dual;
    update eam_activos_temp
       set fecha_act = vFechaEjec
     where circuito = pCircuito;
    commit;
    update eam_ubicacion_temp
       set fecha_act = vFechaEjec
     where circuito = pCircuito;
    commit;
  
    --Manejo de la fecha de actualizacion
    merge into eam_activos_temp nuevo
    using eam_activos_all viejo
    on (viejo.g3e_fid = nuevo.g3e_fid)
    when matched then
      update
         set nuevo.fecha_act = viejo.fecha_act
       where (nvl(nuevo.activo_nombre, 0) = nvl(viejo.activo_nombre, 0) and
             nvl(nuevo.ubicacion, 0) = nvl(viejo.ubicacion, 0) and
             nvl(nuevo.fid_padre, 0) = nvl(viejo.fid_padre, 0))
         and nuevo.g3e_fno = viejo.g3e_fno
         and nuevo.circuito = pCircuito;
    commit;
  
    merge into eam_ubicacion_temp nuevo
    using eam_ubicacion viejo
    on (viejo.g3e_fid = nuevo.g3e_fid)
    when matched then
      update
         set nuevo.fecha_act = viejo.fecha_act
       where (nvl(nuevo.codigo, 0) = nvl(viejo.codigo, 0) and
             nvl(nuevo.codigo_ubicacion, 0) =
             nvl(viejo.codigo_ubicacion, 0) and
             nvl(nuevo.nivel_superior, 0) = nvl(viejo.nivel_superior, 0))
         and nuevo.g3e_fno = viejo.g3e_fno
         and nuevo.circuito = pCircuito;
    commit;
  
    delete from eam_ubicacion where circuito = pCircuito;
    commit;
    insert into eam_ubicacion
      select * from eam_ubicacion_temp where circuito = pCircuito;
    commit;
  
  end;

  procedure EAM_FLUJO_CIRS_PARALELO is
  begin
    eam_epm.EAM_RESPALDAR_TABLAS;
    eam_epm.EAM_POBLAR_TABLA_CIRCUITOS;
    eam_epm.EAM_DISTRIBUIR_NOVEDADES_CIRS(10, 1);
    for cont in 1 .. 10 LOOP
      DBMS_SCHEDULER.RUN_JOB(JOB_NAME            => 'GENERGIA.EAM_TAX_CIRCUITOS_G' ||
                                                    to_char(cont) || '_JOB',
                             USE_CURRENT_SESSION => FALSE);
    end loop;
  end;

end EAM_EPM;
/
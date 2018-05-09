create or replace package EAM_ENERGIA is

  -- Author  : Lucas Turchet
  -- Created : 08/05/2018 14:59:30
  -- Purpose : Metodos comunes a las taxonomias de Energia

  -- Modificación
  -- Version : 3.1.0
  -- Author  : Lucas Turchet
  -- Created : 09/05/2018
  -- Purpose : Nuevos Funcionalidades
  -- Notas de la versión
  -- 1)  Mejor manejo de las novedads y retirados

  --Exception de circuito que no tiene un interruptor
  circuito_sin_interruptor exception;

  --Exception de cuando el trace encuentra mas de 1 interurptor.
  trace_con_varios_interruptores exception;

  -- Identifica el interuptor del circuito, el tipo de circuito y hace el trace de GTech
  function EAM_TRACE_CIR(pCircuito CRED_TEN_CIR_CAT.Circuito%type)
    return elementos_corte;

  -- Maneja las novedades 
  procedure EAM_MANEJO_NOVEDADES(pcircuito varchar2);

  -- Maneja los retirados 
  procedure EAM_MANEJO_RETIRADOS(pcircuito varchar2);

  -- Recalcula los numeros de los activos despues de la primer ejecución
  procedure EAM_MANEJO_ACTIVO(pCircuito CRED_TEN_CIR_CAT.CIRCUITO%type);

  --Limpia Todas las Tablas
  procedure EAM_LIMPIAR_TABLAS;

  -- Respalda las tablas EAM
  procedure EAM_RESPALDAR_TABLAS;

end EAM_ENERGIA;
/
create or replace package body EAM_ENERGIA is

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

  procedure EAM_MANEJO_RETIRADOS(pCircuito in VARCHAR2) is
    vFechaEjec date;
  begin
    vFechaEjec := sysdate;
  
    insert into eam_activos_ret
      (activo,
       activo_nombre,
       circuito,
       descripcion,
       fecha_actualizacion,
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
  
    --Actualizar tabla eam_activos_all = elementos en operacion + retirados - retirados parciales
    -- borrar los que son retiros lineares completos
    delete from eam_activos_all
     where activo in
           (select distinct activo
              from eam_activos_temp
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
       set fecha_actualizacion = vFechaEjec
     where circuito = pCircuito;
    commit;
  
    update eam_ubicacion_temp
       set fecha_actualizacion = vFechaEjec
     where circuito = pCircuito;
    commit;
  
    --Manejo de la fecha de actualizacion
    merge into eam_activos_all viejo
    using eam_activos_temp nuevo
    on (viejo.g3e_fid = nuevo.g3e_fid)
    when matched then
      update
         set viejo.activo_nombre       = nuevo.activo_nombre,
             viejo.ubicacion           = nuevo.ubicacion,
             viejo.fid_padre           = nuevo.fid_padre,
             viejo.activo              = nuevo.activo,
             viejo.ordem               = nuevo.ordem,
             viejo.fecha_actualizacion = nuevo.fecha_actualizacion
       where (nvl(nuevo.activo_nombre, 0) != nvl(viejo.activo_nombre, 0) or
             nvl(nuevo.ubicacion, 0) != nvl(viejo.ubicacion, 0) or
             nvl(nuevo.fid_padre, 0) != nvl(viejo.fid_padre, 0) or
             nvl(nuevo.activo, 0) != nvl(viejo.activo, 0))
         and nuevo.g3e_fno = viejo.g3e_fno
         and nuevo.circuito = pCircuito
    when not matched then
      insert
      values
        (nuevo.circuito,
         nuevo.g3e_fid,
         nuevo.g3e_fno,
         nuevo.activo_nombre,
         nuevo.ubicacion,
         nuevo.nivel,
         nuevo.fid_padre,
         nuevo.activo,
         nuevo.ordem,
         nuevo.descripcion,
         nuevo.fecha_actualizacion);
    commit;
  
    merge into eam_activos_all viejo
    using eam_activos_ret nuevo
    on (viejo.g3e_fid = nuevo.g3e_fid)
    when matched then
      update
         set viejo.fecha_actualizacion = nuevo.fecha_actualizacion
       where viejo.fecha_actualizacion < nuevo.fecha_actualizacion;
    commit;
  
    merge into eam_ubicacion viejo
    using eam_ubicacion_temp nuevo
    on (viejo.g3e_fid = nuevo.g3e_fid and viejo.ubicacion = nuevo.ubicacion)
    when matched then
      update
         set viejo.codigo_ubicacion    = nuevo.codigo_ubicacion,
             viejo.nivel_superior      = nuevo.nivel_superior,
             viejo.fecha_actualizacion = nuevo.fecha_actualizacion
       where (nvl(nuevo.codigo, 0) != nvl(viejo.codigo, 0) or
             nvl(nuevo.codigo_ubicacion, 0) !=
             nvl(viejo.codigo_ubicacion, 0) or
             nvl(nuevo.nivel_superior, 0) != nvl(viejo.nivel_superior, 0))
         and nuevo.g3e_fno = viejo.g3e_fno
         and nuevo.circuito = pCircuito
    when not matched then
      insert
      values
        (nuevo.circuito,
         nuevo.g3e_fid,
         nuevo.g3e_fno,
         nuevo.codigo,
         nuevo.ubicacion,
         nuevo.nivel,
         nuevo.nivel_superior,
         nuevo.codigo_ubicacion,
         nuevo.descripcion,
         nuevo.fecha_actualizacion);
    commit;
  
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

end EAM_ENERGIA;
/

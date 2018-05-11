create or replace package EAM_TRANSMISION is

  -- Modificación
  -- Version : 3.1.0
  -- Author  : Lucas Turchet
  -- Created : 09/05/2018
  -- Purpose : Nuevos Funcionalidades
  -- Notas de la versión
  -- 1)  Taxonomia de Tranismision

  -- Modificación
  -- Version : 3.1.1
  -- Author  : Lucas Turchet
  -- Created : 11/05/2018
  -- Purpose : Ajustes
  -- Notas de la versión
  -- 1) Ajuste del Código de línea en join incorrecto.  
  -- 2) Ajuste de la Relación entre torres y corredores.
  -- 3) Ajuste de la Descripción nula en torres

  -- Ejecuta la taxonomia de Transmisión
  procedure EAM_TAXONOMIA_TRANSMISION;

end EAM_TRANSMISION;
/
create or replace package body EAM_TRANSMISION is
  procedure EAM_TAXONOMIA_TRANSMISION is
  
    cursor cInterruptorLineas(corredor VARCHAR2) is
      select con.g3e_fno, con.g3e_fid, k.circuito, k.cod_linea
        from cconectividad_e con,
             (select distinct c.circuito, t.codigo cod_linea
                from econ_tra_at t,
                     cconectividad_e c,
                     (select cod_linea
                        from (select distinct t.codigo cod_linea, c.circuito
                                from econ_tra_at t, cconectividad_e c
                               where t.g3e_fid = c.g3e_fid
                                 and corredor_nro = corredor)
                      having count(cod_linea) = 1
                       group by cod_linea) lin
               where t.g3e_fid = c.g3e_fid
                 and lin.cod_linea = t.codigo) k, --codigos de linea consistentes con circuitos
             (select codigo cod_linea
                from (select distinct t.codigo, t.corredor_nro
                        from econ_tra_at t)
              having count(codigo) = 1
               group by codigo) m --Codigos de linea en solo un corredor
       where con.circuito = k.circuito
         and k.cod_linea = m.cod_linea
         and con.g3e_fno = 18800
       order by k.cod_linea asc;
  
    /*
    cursor cInterruptorLineas(corredor VARCHAR2) is
      select con.g3e_fno, con.g3e_fid, k.circuito, k.cod_linea
        from cconectividad_e con
       inner join (select conn.circuito, corr.cod_linea
                     from cconectividad_e conn
                    inner join (select g3e_fid, codigo as cod_linea
                                 from econ_tra_at
                                where corredor_nro = corredor
                                group by g3e_fid, codigo) corr
                       on corr.g3e_fid = conn.g3e_fid
                    where conn.tipo_red = 'TRANSMISION'
                      and circuito is not null
                    group by conn.circuito, corr.cod_linea) k
          on k.circuito = con.circuito
       where con.g3e_fno = 18800
       order by k.cod_linea asc;
       */
  
    vLinea  number(2);
    vActivo number(10);
    vOrdem  number(5);
    vCount  number(3);
    vCorte  elementos_corte;
    vACT    date;
    vDesc   varchar2(100);
  
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
        vCorte  := eam_energia.eam_trace_cir(linea.circuito);
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
             6,
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
             6,
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
                       where tor.clase_torre != 'PORTICO'
                         and tor.corredor_nro = corredor.corredor_nro
                       group by tor.g3e_fid, tor.g3e_fno) loop
        
          select LISTAGG(nro_torre_linea || '-LINEA ' || codigo_linea, ';') within group(order by codigo_linea)
            into vDesc
            from etor_trm_nro_at
           where g3e_fid = torre.g3e_fid;
        
          insert into eam_activos_temp
          values
            (linea.circuito,
             torre.G3e_Fid,
             torre.g3e_fno,
             'TORRE',
             'EST-' || corredor.corredor_nro,
             6,
             linea.g3e_fid,
             null,
             null,
             vDESC,
             vACT);
          commit;
        
        end loop; --Torre
      
        --Portico
        for torre in (select tor.g3e_fid, tor.g3e_fno
                        from etor_trm_at tor
                       where tor.clase_torre = 'PORTICO'
                         and tor.corredor_nro = corredor.corredor_nro
                       group by tor.g3e_fid, tor.g3e_fno) loop
        
          insert into eam_activos_temp
          values
            (linea.circuito,
             torre.G3e_Fid,
             torre.g3e_fno,
             'PORTICO',
             'EST-' || corredor.corredor_nro,
             6,
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
             6,
             linea.g3e_fid,
             null,
             null,
             null,
             vACT);
          commit;
        
        end loop; --Pararrayos
      
        if vLinea = 1 then
          EAM_ENERGIA.EAM_MANEJO_ACTIVO(linea.circuito);
          EAM_ENERGIA.EAM_MANEJO_RETIRADOS(linea.circuito);
          EAM_ENERGIA.EAM_MANEJO_NOVEDADES(linea.circuito);
        end if;
      
      end loop; --Linea
    
    end loop; --Corredores
  
  end;
end EAM_TRANSMISION;
/

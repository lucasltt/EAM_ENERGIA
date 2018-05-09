

--Parametros de trace

-- Created on 17/05/2017 by LTTURCHE 
declare
  traceSeq number(10);
begin

  traceSeq := g3e_trace_seq.nextval;

  insert into g3e_trace
    (G3E_ID,
     G3E_USERNAME,
     G3E_DESCRIPTION,
     G3E_RNO,
     G3E_TRACETYPE,
     G3E_EDITDATE,
     G3E_PROMPTFORGOAL,
     G3E_PROMPTFORHINT,
     G3E_STOPCRITERIA,
     G3E_FILTERCRITERIA,
     G3E_PATHCOST,
     G3E_GOALFNO,
     G3E_REVERSE,
     G3E_IMPLIEDORDER,
     G3E_HINTIDENTIFIESFEATURE,
     G3E_GRAPHICRNO,
     G3E_LOCALECOMMENT,
     G3E_ITERATIONPROC,
     G3E_PARTIALVALUERINO,
     G3E_PARTIALVALUEARGGROUPNO,
     G3E_PRETRACEPROC,
     G3E_USEPICKLISTKEY)
  values
    (traceSeq,
     'Trace para el EAM',
     'Trace que se utiliza en los paquetes de EAM',
     1,
     1,
     sysdate,
     0,
     'N',
     null,
     null,
     null,
     null,
     0,
     0,
     'Y',
     null,
     null,
     null,
     null,
     null,
     null,
     1);
  commit;

  insert into g3e_tracemapping
    (G3E_TMNO,
     G3E_ID,
     G3E_TYPE,
     G3E_EDITDATE,
     G3E_ROLE,
     G3E_USERNAME,
     G3E_AOI,
     G3E_WINDOW,
     G3E_PRIMARYGRAPHICONLY,
     G3E_DATATABLE,
     G3E_HIERARCHICALTREE,
     G3E_SONO,
     G3E_RPMNO,
     G3E_PPMNO,
     G3E_LOCALECOMMENT)
  values
    (traceSeq,
     traceSeq,
     1,
     sysdate,
     'EVERYONE',
     'Trace para el EAM',
     0,
     1,
     1,
     null,
     null,
     null,
     null,
     null,
     null);
  commit;

  insert into g3e_tracefeature
    (G3E_TFNO, G3E_TNO, G3E_FNO, G3E_EDITDATE)
  values
    (g3e_tracefeature_seq.nextval, traceSeq, 18800, sysdate);
  commit;

  insert into g3e_traceaddcolumns
    (G3E_TRACNO, G3E_ADDITIONALCOLUMN, G3E_SOURCEEXPR, G3E_EDITDATE)
  values
    (1604, 'USER_COL2', 'conn.CIRCUITO_SALIDA', sysdate);
  commit;

    insert into g3e_traceaddcolumns
    (G3E_TRACNO, G3E_ADDITIONALCOLUMN, G3E_SOURCEEXPR, G3E_EDITDATE)
  values
    (1605, 'USER_COL3', 'conn.NODO_UBICACION', sysdate);
  commit;

  insert into g3e_traceaddcolspertrace
    (G3E_ID, G3E_TRACNO, G3E_ADDCOLUMNTYPE, G3E_EDITDATE, G3E_TACPTROWNO)
  values
    (traceSeq, 1406, 1, sysdate, g3e_traceaddcolspertrace_seq.nextval);

  insert into g3e_traceaddcolspertrace
    (G3E_ID, G3E_TRACNO, G3E_ADDCOLUMNTYPE, G3E_EDITDATE, G3E_TACPTROWNO)
  values
    (traceSeq, 1406, 2, sysdate, g3e_traceaddcolspertrace_seq.nextval);

  insert into g3e_traceaddcolspertrace
    (G3E_ID, G3E_TRACNO, G3E_ADDCOLUMNTYPE, G3E_EDITDATE, G3E_TACPTROWNO)
  values
    (traceSeq, 1509, 1, sysdate, g3e_traceaddcolspertrace_seq.nextval);

  insert into g3e_traceaddcolspertrace
    (G3E_ID, G3E_TRACNO, G3E_ADDCOLUMNTYPE, G3E_EDITDATE, G3E_TACPTROWNO)
  values
    (traceSeq, 1509, 2, sysdate, g3e_traceaddcolspertrace_seq.nextval);

  insert into g3e_traceaddcolspertrace
    (G3E_ID, G3E_TRACNO, G3E_ADDCOLUMNTYPE, G3E_EDITDATE, G3E_TACPTROWNO)
  values
    (traceSeq, 1501, 1, sysdate, g3e_traceaddcolspertrace_seq.nextval);

  insert into g3e_traceaddcolspertrace
    (G3E_ID, G3E_TRACNO, G3E_ADDCOLUMNTYPE, G3E_EDITDATE, G3E_TACPTROWNO)
  values
    (traceSeq, 1501, 2, sysdate, g3e_traceaddcolspertrace_seq.nextval);

  insert into g3e_traceaddcolspertrace
    (G3E_ID, G3E_TRACNO, G3E_ADDCOLUMNTYPE, G3E_EDITDATE, G3E_TACPTROWNO)
  values
    (traceSeq, 1605, 2, sysdate, g3e_traceaddcolspertrace_seq.nextval);

  insert into g3e_traceaddcolspertrace
    (G3E_ID, G3E_TRACNO, G3E_ADDCOLUMNTYPE, G3E_EDITDATE, G3E_TACPTROWNO)
  values
    (traceSeq, 1604, 2, sysdate, g3e_traceaddcolspertrace_seq.nextval);

  commit;

end;
/


--tablas
drop table EAM_ERRORS;
create table EAM_ERRORS
(
  circuito    VARCHAR2(50),
  g3e_fid     NUMBER(10),
  g3e_fno     NUMBER(10),
  fecha       DATE,
  descripcion VARCHAR2(300)
);

drop table EAM_TRACES;
create table EAM_TRACES
(
  circuito         VARCHAR2(50),
  circuito_entrada VARCHAR2(50),
  circuito_salida  VARCHAR2(50),
  tipo             VARCHAR2(25),
  tipo_circuito    VARCHAR2(50),
  g3e_traceorder   NUMBER(10) not null,
  g3e_sourceid     NUMBER(10) not null,
  g3e_sourcefid    NUMBER(10) not null,
  g3e_sourcenode   NUMBER(10) not null,
  g3e_node1        NUMBER(10) not null,
  g3e_node2        NUMBER(10) not null,
  g3e_id           NUMBER(10) not null,
  g3e_fid          NUMBER(10) not null,
  g3e_fno          NUMBER(5) not null,
  g3e_username     VARCHAR2(80),
  nodo_transform   NUMBER(10),
  tramo            NUMBER,
  segmento         NUMBER,
  ramal            NUMBER,
  activo           NUMBER,
  ordem            NUMBER,
  fid_padre        NUMBER(10),
  codigo           VARCHAR2(80),
  nodo_ubicacion   VARCHAR2(30)
);

drop table EAM_ACTIVOS_ALL;
create table EAM_ACTIVOS_ALL
(
  circuito            VARCHAR2(50),
  g3e_fid             NUMBER(10),
  g3e_fno             NUMBER(10),
  activo_nombre       VARCHAR2(50),
  ubicacion           VARCHAR2(100),
  nivel               NUMBER,
  fid_padre           NUMBER,
  activo              NUMBER,
  ordem               NUMBER,
  descripcion         VARCHAR2(100),
  fecha_actualizacion DATE
);

drop table EAM_ACTIVOS_RET;
create table EAM_ACTIVOS_RET
(
  circuito            VARCHAR2(50),
  g3e_fid             NUMBER(10),
  g3e_fno             NUMBER(10),
  activo_nombre       VARCHAR2(50),
  ubicacion           VARCHAR2(100),
  nivel               NUMBER,
  fid_padre           NUMBER,
  activo              NUMBER,
  ordem               NUMBER,
  descripcion         VARCHAR2(100),
  fecha_actualizacion DATE
);

drop table EAM_ACTIVOS_TEMP;
create table EAM_ACTIVOS_TEMP
(
  circuito            VARCHAR2(50),
  g3e_fid             NUMBER(10),
  g3e_fno             NUMBER(10),
  activo_nombre       VARCHAR2(50),
  ubicacion           VARCHAR2(100),
  nivel               NUMBER,
  fid_padre           NUMBER,
  activo              NUMBER,
  ordem               NUMBER,
  descripcion         VARCHAR2(100),
  fecha_actualizacion DATE
);

drop table EAM_UBICACION;
create table EAM_UBICACION
(
  circuito            VARCHAR2(50),
  g3e_fid             NUMBER(10),
  g3e_fno             NUMBER(5),
  codigo              VARCHAR2(100),
  ubicacion           VARCHAR2(100),
  nivel               NUMBER,
  nivel_superior      VARCHAR2(100),
  codigo_ubicacion    VARCHAR2(30),
  descripcion         VARCHAR2(100),
  fecha_actualizacion DATE
);

drop table EAM_UBICACION_RET;
create table EAM_UBICACION_RET
(
  circuito            VARCHAR2(50),
  g3e_fid             NUMBER(10),
  g3e_fno             NUMBER(5),
  codigo              VARCHAR2(100),
  ubicacion           VARCHAR2(100),
  nivel               NUMBER,
  nivel_superior      VARCHAR2(100),
  codigo_ubicacion    VARCHAR2(30),
  descripcion         VARCHAR2(100),
  fecha_actualizacion DATE
);

drop table EAM_UBICACION_TEMP;
create table EAM_UBICACION_TEMP
(
  circuito            VARCHAR2(50),
  g3e_fid             NUMBER(10),
  g3e_fno             NUMBER(5),
  codigo              VARCHAR2(100),
  ubicacion           VARCHAR2(100),
  nivel               NUMBER,
  nivel_superior      VARCHAR2(100),
  codigo_ubicacion    VARCHAR2(30),
  descripcion         VARCHAR2(100),
  fecha_actualizacion DATE
);

drop table  EAM_CIRCUITOS;
create table EAM_CIRCUITOS
(
  circuito          VARCHAR2(50),
  status            VARCHAR2(150),      
  avance            VARCHAR2(50),       
  tiempo            VARCHAR2(50),
  grupo             NUMBER(2) default 0,
  fecha_conclusion  DATE
);


alter table traceresult
modify USER_COL2 VARCHAR2(30);

alter table traceresult
modify USER_COL3 VARCHAR2(30);

alter table traceresult
modify circuito VARCHAR2(50);


--tipos
create or replace type eam_trace_record as object
(
g3e_id NUMBER(10),
g3e_fid NUMBER(10),
g3e_fno NUMBER(5),
g3e_node1 NUMBER(10),
g3e_node2 NUMBER(10),
grupo number(10),
ordem number(10),
tipo varchar2(30)
);
/


create or replace type eam_nodo as object
(
g3e_id number(10),
g3e_fno number(5),
g3e_fid number(10),
g3e_sourcenode number(10),
tramo number(10),
segmento number(10),
tipo varchar2(13)
);
/


create or replace type eam_trace_table as table of eam_trace_record;
/

create or replace type eam_nodo_table as table of eam_nodo;
/

create or replace type elementos_corte as table of number;
/

create or replace type tNodos as table of number;
/
-- Create sequence 
create sequence EAM_ACTIVO
minvalue 1
maxvalue 99999999
start with 1
increment by 1
cache 20;

create sequence EAM_parrilla_seq
minvalue 1
maxvalue 99999999
start with 1000
increment by 1
cache 20;


--parrila

GRANT SHORTTERMTRANSACTIONS TO GENERGIA;
DROP INDEX IDX_ECANGREJ_PT_GEOM;
  
--UPDATE EL SDO_SRID DEL CANGREJO
UPDATE B$ECANGREJ_PT C SET C.G3E_GEOMETRY.SDO_SRID = '4326' WHERE C.G3E_GEOMETRY.SDO_SRID IS NULL;
COMMIT; 
  
--CREATE NUEVAMENTE EL SPATIAL INDEX PARA EL CANGREJO
CREATE INDEX IDX_ECANGREJ_PT_GEOM ON B$ECANGREJ_PT(G3E_GEOMETRY) INDEXTYPE IS MDSYS.SPATIAL_INDEX;
REVOKE SHORTTERMTRANSACTIONS FROM GENERGIA;

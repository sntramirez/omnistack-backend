-- Create table
CREATE TABLE TUKUNAFUNC.IN_LOGS_WS_EXT (
  codigo             NUMBER NOT NULL,
  request            CLOB,
  response           CLOB,
  usuario            VARCHAR2(100),
  fecha_registro     DATE,
  mensaje            VARCHAR2(2000),
  origen             VARCHAR2(100),
  pais               VARCHAR2(100),
  canal              VARCHAR2(100),
  codigo_prov_pago   VARCHAR2(50),
  nombre_farmacia    VARCHAR2(100),
  folio              VARCHAR2(100),
  farmacia           NUMBER,
  cadena             NUMBER,
  pos                NUMBER,
  url                VARCHAR2(300),
  metodo             VARCHAR2(20),
  cp_var1            VARCHAR2(1500),
  cp_var2            VARCHAR2(1500),
  cp_var3            VARCHAR2(1500),
  cp_number1         NUMBER,
  cp_number2         NUMBER,
  cp_number3         NUMBER,
  cp_date1           DATE,
  cp_date2           DATE,
  cp_date3           DATE,
  CONSTRAINT PK_IN_LOGS_WS_EXT PRIMARY KEY (codigo)
);

CREATE SEQUENCE TUKUNAFUNC.SEQ_IN_LOGS_WS_EXT
START WITH 1
INCREMENT BY 1
CACHE 500
NOCYCLE;

CREATE OR REPLACE TRIGGER TUKUNAFUNC.TR_BI_IN_LOGS_WS_EXT
BEFORE INSERT ON TUKUNAFUNC.IN_LOGS_WS_EXT
FOR EACH ROW
BEGIN
   IF :NEW.CODIGO IS NULL THEN
      SELECT TUKUNAFUNC.SEQ_IN_LOGS_WS_EXT.NEXTVAL
      INTO :NEW.CODIGO
      FROM DUAL;
   END IF;
END;
/

COMMENT ON TABLE TUKUNAFUNC.IN_LOGS_WS_EXT IS 
'Tabla de auditoría y trazabilidad del sistema de Pagos Digitales. 
Almacena request, response y metadatos operativos de cada transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CODIGO IS 
'Identificador único autogenerado del registro de log. Clave primaria.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.REQUEST IS 
'Contenido completo del request enviado al proveedor o servicio externo.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.RESPONSE IS 
'Contenido completo del response recibido del proveedor o servicio externo.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.USUARIO IS 
'Usuario o sistema que generó la transacción o invocación.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.FECHA_REGISTRO IS 
'Fecha y hora en la que se registró el evento en el sistema.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.MENSAJE IS 
'Mensaje descriptivo del resultado o estado de la transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.ORIGEN IS 
'Sistema o aplicación de origen desde donde se generó la solicitud.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.PAIS IS 
'País asociado a la transacción o punto de operación.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CANAL IS 
'Canal por el cual se ejecutó la transacción (APP, WEB, POS, etc.).';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CODIGO_PROV_PAGO IS 
'Código identificador del proveedor de pago digital utilizado en la transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.NOMBRE_FARMACIA IS 
'Nombre descriptivo de la farmacia donde se originó la transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.FOLIO IS 
'Identificador único de la transacción generado por el sistema o proveedor.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.FARMACIA IS 
'Código numérico de la farmacia donde se ejecutó la operación.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CADENA IS 
'Código identificador de la cadena comercial a la que pertenece la farmacia.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.POS IS 
'Identificador del punto de venta (terminal) donde se realizó la transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.URL IS 
'Endpoint o URL invocada durante la transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.METODO IS 
'Método de Ejecución del Endpoint o URL invocada durante la transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CP_VAR1 IS 
'Variable de texto configurable adicional 1 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CP_VAR2 IS 
'Variable de texto configurable adicional 2 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CP_VAR3 IS 
'Variable de texto configurable adicional 3 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CP_NUMBER1 IS 
'Variable numérica configurable adicional 1 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CP_NUMBER2 IS 
'Variable numérica configurable adicional 2 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CP_NUMBER3 IS 
'Variable numérica configurable adicional 3 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CP_DATE1 IS 
'Variable de fecha configurable adicional 1 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CP_DATE2 IS 
'Variable de fecha configurable adicional 2 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_WS_EXT.CP_DATE3 IS 
'Variable de fecha configurable adicional 3 para almacenamiento complementario.';

/* Rango de fechas (lo más común) */
CREATE INDEX IDX_ILWE_FECHA_REG
  ON TUKUNAFUNC.IN_LOGS_WS_EXT (fecha_registro);

/* Folio (trazabilidad de transacción) */
CREATE INDEX IDX_ILWE_FOLIO
  ON TUKUNAFUNC.IN_LOGS_WS_EXT (folio);

CREATE INDEX IDX_ILWE_FOLIO_FECHA
  ON TUKUNAFUNC.IN_LOGS_WS_EXT (folio, fecha_registro);

/* Por punto de venta / farmacia / cadena + fecha */
CREATE INDEX IDX_ILWE_CAD_FAR_POS_FECHA
  ON TUKUNAFUNC.IN_LOGS_WS_EXT (cadena, farmacia, pos, fecha_registro);

/* Proveedor + fecha */
CREATE INDEX IDX_ILWE_PROV_FECHA
  ON TUKUNAFUNC.IN_LOGS_WS_EXT (codigo_prov_pago, fecha_registro);

/* Canal / origen / país + fecha */
CREATE INDEX IDX_ILWE_CANAL_FECHA
  ON TUKUNAFUNC.IN_LOGS_WS_EXT (canal, fecha_registro);

CREATE INDEX IDX_ILWE_ORIGEN_FECHA
  ON TUKUNAFUNC.IN_LOGS_WS_EXT (origen, fecha_registro);

CREATE INDEX IDX_ILWE_PAIS_FECHA
  ON TUKUNAFUNC.IN_LOGS_WS_EXT (pais, fecha_registro);

/* Usuario + fecha */
CREATE INDEX IDX_ILWE_USUARIO_FECHA
  ON TUKUNAFUNC.IN_LOGS_WS_EXT (usuario, fecha_registro);

--ELIMINAR TABLA
--DROP TABLE TUKUNAFUNC.IN_LOGS_WS_EXT;
--DROP TABLE TUKUNAFUNC.IN_LOGS_WS_EXT CASCADE CONSTRAINTS;
--DROP SEQUENCE TUKUNAFUNC.SEQ_IN_LOGS_WS_EXT;



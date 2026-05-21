-- Create table
CREATE TABLE TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT (
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
  CONSTRAINT PK_IN_LOGS_APP_PAG_DIGIT PRIMARY KEY (codigo)
);

CREATE SEQUENCE TUKUNAFUNC.SEQ_IN_LOGS_APP_PAG_DIGIT
START WITH 1
INCREMENT BY 1
CACHE 500
NOCYCLE;


COMMENT ON TABLE TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT IS 
'Tabla de auditoría y trazabilidad del sistema de Pagos Digitales. 
Almacena request, response y metadatos operativos de cada transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CODIGO IS 
'Identificador único autogenerado del registro de log. Clave primaria.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.REQUEST IS 
'Contenido completo del request enviado al proveedor o servicio externo.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.RESPONSE IS 
'Contenido completo del response recibido del proveedor o servicio externo.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.USUARIO IS 
'Usuario o sistema que generó la transacción o invocación.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.FECHA_REGISTRO IS 
'Fecha y hora en la que se registró el evento en el sistema.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.MENSAJE IS 
'Mensaje descriptivo del resultado o estado de la transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.ORIGEN IS 
'Sistema o aplicación de origen desde donde se generó la solicitud.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.PAIS IS 
'País asociado a la transacción o punto de operación.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CANAL IS 
'Canal por el cual se ejecutó la transacción (APP, WEB, POS, etc.).';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CODIGO_PROV_PAGO IS 
'Código identificador del proveedor de pago digital utilizado en la transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.NOMBRE_FARMACIA IS 
'Nombre descriptivo de la farmacia donde se originó la transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.FOLIO IS 
'Identificador único de la transacción generado por el sistema o proveedor.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.FARMACIA IS 
'Código numérico de la farmacia donde se ejecutó la operación.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CADENA IS 
'Código identificador de la cadena comercial a la que pertenece la farmacia.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.POS IS 
'Identificador del punto de venta (terminal) donde se realizó la transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.URL IS 
'Endpoint o URL invocada durante la transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.METODO IS 
'Método de Ejecución del Endpoint o URL invocada durante la transacción.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CP_VAR1 IS 
'Variable de texto configurable adicional 1 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CP_VAR2 IS 
'Variable de texto configurable adicional 2 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CP_VAR3 IS 
'Variable de texto configurable adicional 3 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CP_NUMBER1 IS 
'Variable numérica configurable adicional 1 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CP_NUMBER2 IS 
'Variable numérica configurable adicional 2 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CP_NUMBER3 IS 
'Variable numérica configurable adicional 3 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CP_DATE1 IS 
'Variable de fecha configurable adicional 1 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CP_DATE2 IS 
'Variable de fecha configurable adicional 2 para almacenamiento complementario.';

COMMENT ON COLUMN TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT.CP_DATE3 IS 
'Variable de fecha configurable adicional 3 para almacenamiento complementario.';

/* Rango de fechas (lo más común) */
CREATE INDEX IDX_ILAPD_FECHA_REG
  ON TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT (fecha_registro);

/* Folio (trazabilidad de transacción) */
CREATE INDEX IDX_ILAPD_FOLIO
  ON TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT (folio);

CREATE INDEX IDX_ILAPD_FOLIO_FECHA
  ON TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT (folio, fecha_registro);

/* Por punto de venta / farmacia / cadena + fecha */
CREATE INDEX IDX_ILAPD_CAD_FAR_POS_FECHA
  ON TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT (cadena, farmacia, pos, fecha_registro);

/* Proveedor + fecha */
CREATE INDEX IDX_ILAPD_PROV_FECHA
  ON TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT (codigo_prov_pago, fecha_registro);

/* Canal / origen / país + fecha */
CREATE INDEX IDX_ILAPD_CANAL_FECHA
  ON TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT (canal, fecha_registro);

CREATE INDEX IDX_ILAPD_ORIGEN_FECHA
  ON TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT (origen, fecha_registro);

CREATE INDEX IDX_ILAPD_PAIS_FECHA
  ON TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT (pais, fecha_registro);

/* Usuario + fecha */
CREATE INDEX IDX_ILAPD_USUARIO_FECHA
  ON TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT (usuario, fecha_registro);

--ELIMINAR TABLA
--DROP TABLE TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT;
--DROP TABLE TUKUNAFUNC.IN_LOGS_APP_PAG_DIGIT CASCADE CONSTRAINTS;
--DROP SEQUENCE TUKUNAFUNC.SEQ_IN_LOGS_APP_PAG_DIGIT;



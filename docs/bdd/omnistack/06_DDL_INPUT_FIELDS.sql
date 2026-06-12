-- ============================================================
-- Ejecutar como: TUKUNAFUNC
-- Crea la tabla IN_OMNI_INPUT_FIELDS para almacenar los campos
-- de entrada que el POS debe recolectar por servicio/operación.
-- Estos campos son responsabilidad del equipo OmniStack,
-- NO del negocio (por eso vive en TUKUNAFUNC, no en AD_*).
-- ============================================================

CREATE TABLE IN_OMNI_INPUT_FIELDS (
    ID_FIELD              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CATEGORY_CODE         VARCHAR2(20)  NOT NULL,
    SUBCATEGORY_CODE      VARCHAR2(20)  NOT NULL,
    SERVICE_PROVIDER_CODE VARCHAR2(50)  NOT NULL,
    RMS_ITEM_CODE         VARCHAR2(50)  NOT NULL,
    FIELD_ID              VARCHAR2(100) NOT NULL,
    LABEL                 VARCHAR2(200) NOT NULL,
    FIELD_TYPE            VARCHAR2(20)  NOT NULL,  -- STRING | DOUBLE | INTEGER | BOOLEAN
    CAPABILITY            VARCHAR2(50)  NOT NULL,  -- PRECHECK | EXECUTE | VERIFY | REVERSE
    IS_REQUIRED           NUMBER(1)     DEFAULT 1 NOT NULL,
    FIELD_GROUP           VARCHAR2(50),
    CONDITIONAL_OPERATOR  VARCHAR2(200),
    FIELD_ORDER           NUMBER(3)     DEFAULT 0 NOT NULL,
    ENABLED               CHAR(1)       DEFAULT 'S' NOT NULL
);

-- Comentarios de columnas
COMMENT ON TABLE  IN_OMNI_INPUT_FIELDS IS 'Campos de entrada del formulario POS por servicio y operacion';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.CATEGORY_CODE IS 'Codigo de categoria (CLASS de RMS)';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.SUBCATEGORY_CODE IS 'Codigo de subcategoria (SUBCLASS de RMS)';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.SERVICE_PROVIDER_CODE IS 'Codigo del proveedor (TERCERO de AD_SERVICIO_PARAMETROS)';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.RMS_ITEM_CODE IS 'Codigo de item RMS (CODIGO_ITEM_RMS de AD_SERVICIO_PARAMETROS)';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.FIELD_ID IS 'Identificador del campo (camelCase, coincide con el campo del request)';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.LABEL IS 'Etiqueta para mostrar en el POS';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.FIELD_TYPE IS 'Tipo de dato: STRING, DOUBLE, INTEGER, BOOLEAN';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.CAPABILITY IS 'Operacion para la que se requiere este campo';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.IS_REQUIRED IS '1=obligatorio, 0=opcional';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.FIELD_GROUP IS 'Agrupacion visual en el POS (ID, PHONE, AMOUNT, PASS, etc.)';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.CONDITIONAL_OPERATOR IS 'Condicion para mostrar el campo (null = siempre visible)';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.FIELD_ORDER IS 'Orden de presentacion en el formulario';
COMMENT ON COLUMN IN_OMNI_INPUT_FIELDS.ENABLED IS 'S=activo, N=inactivo';

-- Indice por rms_item_code para el filtro de la query del catalogo
CREATE INDEX IDX_INOMNI_INPFLD_ITEM ON IN_OMNI_INPUT_FIELDS (RMS_ITEM_CODE, ENABLED);

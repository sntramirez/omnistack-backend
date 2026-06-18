-- ============================================================
-- Ejecutar como: TUKUNAFUNC
-- Requiere: script 14 ejecutado previamente.
--
-- A) Registros de HOMOLOGACION para CLARO:
--    VALOR_ORIGEN = valor que envía el POS (chain)
--    CONFIG_VALOR = valor que espera CLARO
--
-- B) Registros de CONFIG FIJA para CLARO:
--    Campos que faltan en IN_OMNI_PROVEEDOR_CONFIG y que
--    ClaroXmlAdapter necesita (estaban vacíos en el request).
--    VALOR_ORIGEN = NULL (sin homologación, valor único por proveedor)
-- ============================================================

-- ============================================================
-- A) HOMOLOGACION: company_id por cadena
-- ============================================================
-- chain = valor que el POS envía en el request
-- CONFIG_VALOR = COMPANYID que CLARO espera según el contrato

INSERT INTO TUKUNAFUNC.IN_OMNI_PROVEEDOR_CONFIG
  (ID_CONFIG, PROVEEDOR_KEY, CONFIG_KEY, TIPO_CONFIG, CONFIG_VALOR, VALOR_ORIGEN)
VALUES (SEQ_IN_OMNI_PROVEEDOR_CONFIG.NEXTVAL,
  'claro', 'company_id', 'MAPEO', '2', '1');
-- chain=1 (FYBECA) → CLARO COMPANYID=2

INSERT INTO TUKUNAFUNC.IN_OMNI_PROVEEDOR_CONFIG
  (ID_CONFIG, PROVEEDOR_KEY, CONFIG_KEY, TIPO_CONFIG, CONFIG_VALOR, VALOR_ORIGEN)
VALUES (SEQ_IN_OMNI_PROVEEDOR_CONFIG.NEXTVAL,
  'claro', 'company_id', 'MAPEO', '7', '8');
-- chain=8 (SANA SANA) → CLARO COMPANYID=7

-- ⚠ Agregar más cadenas según acuerdo con CLARO antes de go-live

-- ============================================================
-- B) CONFIG FIJA: campos sin homologación que faltaban
-- ============================================================

INSERT INTO TUKUNAFUNC.IN_OMNI_PROVEEDOR_CONFIG
  (ID_CONFIG, PROVEEDOR_KEY, CONFIG_KEY, TIPO_CONFIG, CONFIG_VALOR, VALOR_ORIGEN)
VALUES (SEQ_IN_OMNI_PROVEEDOR_CONFIG.NEXTVAL,
  'claro', 'media_id', 'TEXTO', 'RETA', NULL);

INSERT INTO TUKUNAFUNC.IN_OMNI_PROVEEDOR_CONFIG
  (ID_CONFIG, PROVEEDOR_KEY, CONFIG_KEY, TIPO_CONFIG, CONFIG_VALOR, VALOR_ORIGEN)
VALUES (SEQ_IN_OMNI_PROVEEDOR_CONFIG.NEXTVAL,
  'claro', 'cod_caja', 'TEXTO', 'DA00004', NULL);

INSERT INTO TUKUNAFUNC.IN_OMNI_PROVEEDOR_CONFIG
  (ID_CONFIG, PROVEEDOR_KEY, CONFIG_KEY, TIPO_CONFIG, CONFIG_VALOR, VALOR_ORIGEN)
VALUES (SEQ_IN_OMNI_PROVEEDOR_CONFIG.NEXTVAL,
  'claro', 'cod_site', 'TEXTO', '10000004', NULL);

COMMIT;

-- Verificar homologaciones:
-- SELECT CONFIG_KEY, CONFIG_VALOR, VALOR_ORIGEN, TIPO_CONFIG
--   FROM TUKUNAFUNC.IN_OMNI_PROVEEDOR_CONFIG
--  WHERE PROVEEDOR_KEY = 'claro'
--  ORDER BY CONFIG_KEY, VALOR_ORIGEN;

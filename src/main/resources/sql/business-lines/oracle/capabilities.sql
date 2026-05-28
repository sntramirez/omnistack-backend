-- Capabilities derivadas de IN_OMNI_PROVEEDOR_WS filtradas por WS_KEY valido (CAPABILITY.MOVEMENTTYPE).
-- Join via IN_OMNI_PROVEEDOR_CONFIG para correlacionar service_provider_code + subcategory_code del catalogo
-- con el proveedor_key de la tabla de WS, sin requerir una tabla dedicada de capabilities.
SELECT DISTINCT
    TO_CHAR(c.CLASS)        AS category_code,
    TO_CHAR(sc.SUBCLASS_ID) AS subcategory_code,
    TO_CHAR(sp.TERCERO)     AS service_provider_code,
    sp.CODIGO_ITEM_RMS      AS rms_item_code,
    REGEXP_SUBSTR(ws.WS_KEY, '^[^.]+') AS capability_code
FROM AD_SERVICIO_PARAMETROS sp
JOIN AD_CANAL_SERVICIO cs
    ON cs.ID_CONFIG     = sp.ID_CONFIG
    AND cs.CODIGO_CANAL = :canal_codigo
    AND cs.ACTIVO       = 'S'
JOIN ITEM_MASTER im ON TRIM(im.ITEM) = TRIM(sp.CODIGO_ITEM_RMS)
JOIN CLASS       c  ON c.CLASS = im.CLASS
JOIN SUBCLASS    sc ON sc.CLASS = im.CLASS AND sc.SUBCLASS_ID = im.SUBCLASS
JOIN IN_OMNI_PROVEEDOR_CONFIG cfg_spc
    ON cfg_spc.CONFIG_KEY   = 'service_provider_code'
    AND cfg_spc.CONFIG_VALOR = TO_CHAR(sp.TERCERO)
JOIN IN_OMNI_PROVEEDOR_CONFIG cfg_sub
    ON cfg_sub.PROVEEDOR_KEY = cfg_spc.PROVEEDOR_KEY
    AND cfg_sub.CONFIG_KEY   = 'subcategory_code'
    AND cfg_sub.CONFIG_VALOR  = TO_CHAR(sc.SUBCLASS_ID)
JOIN IN_OMNI_PROVEEDOR_WS ws
    ON ws.PROVEEDOR_KEY = cfg_spc.PROVEEDOR_KEY
    AND ws.ENABLED      = 'S'
WHERE REGEXP_SUBSTR(ws.WS_KEY, '^[^.]+')
      IN ('PRECHECK', 'CREATE_TICKET', 'EXECUTE', 'VERIFY', 'REVERSE')
ORDER BY TO_NUMBER(category_code),
         TO_NUMBER(subcategory_code),
         TO_NUMBER(service_provider_code),
         rms_item_code

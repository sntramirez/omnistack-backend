/* ============================================================
   INSERTS POR CADA WS (PLANTILLA)
   - Reemplaza 235689 por el CODIGO real de AD_BILLETERAS_DIGITALES
   - Los HEADERS se insertan 1 sola vez por CODIGO (y aplican a todos los WSs)
   - Los DEFAULTS se insertan SOLO para el WS que los tenga
   ============================================================ */

---------------------------------------------------------------
-- 0) HEADERS (UNA SOLA VEZ POR PASARELA / CODIGO)
---------------------------------------------------------------
INSERT INTO TUKUNAFUNC.IN_PASARELA_HEADERS (CODIGO_BILLETERA, HEADER_NOMBRE, HEADER_VALOR)
VALUES (235689, 'X-Api-Key', 'c14e0ba4e1845e09ba08a4be0fba95e5');

INSERT INTO TUKUNAFUNC.IN_PASARELA_HEADERS (CODIGO_BILLETERA, HEADER_NOMBRE, HEADER_VALOR)
VALUES (235689, 'X-Version', '20200803');

INSERT INTO TUKUNAFUNC.IN_PASARELA_HEADERS (CODIGO_BILLETERA, HEADER_NOMBRE, HEADER_VALOR)
VALUES (235689, 'Content-Type', 'application/json');

---------------------------------------------------------------
-- 1) WS: direct-online-payment-requests
---------------------------------------------------------------
INSERT INTO TUKUNAFUNC.IN_PASARELA_WS
  (CODIGO_BILLETERA, WS_KEY, ENABLED, TIPO_CONEXION, METODO_HTTP, TIPO_REQUEST, URL)
VALUES
  (235689, 'direct-online-payment-requests', 'S', 'REST', 'POST', 'JSON',
   'https://sandbox-mws.safetypay.com/mpi/api/v1/direct-online-payment-requests');

-- DEFAULTS (solo para este WS)
INSERT INTO TUKUNAFUNC.IN_PASARELA_WS_DEFS
  (ID_WS, DEFAULT_CLAVE, DEFAULT_VALOR_TEXTO)
SELECT
  e.ID_WS, 'payment_ok_url', 'https://www.safetypay.com/success.com'
FROM TUKUNAFUNC.IN_PASARELA_WS e
WHERE e.CODIGO_BILLETERA = 235689
  AND e.WS_KEY     = 'direct-online-payment-requests';

INSERT INTO TUKUNAFUNC.IN_PASARELA_WS_DEFS
  (ID_WS, DEFAULT_CLAVE, DEFAULT_VALOR_TEXTO)
SELECT
  e.ID_WS, 'payment_error_url', 'https://www.safetypay.com/error.com'
FROM TUKUNAFUNC.IN_PASARELA_WS e
WHERE e.CODIGO_BILLETERA = 235689
  AND e.WS_KEY     = 'direct-online-payment-requests';

INSERT INTO TUKUNAFUNC.IN_PASARELA_WS_DEFS
  (ID_WS, DEFAULT_CLAVE, DEFAULT_VALOR_NUM)
SELECT
  e.ID_WS, 'application_id', 7
FROM TUKUNAFUNC.IN_PASARELA_WS e
WHERE e.CODIGO_BILLETERA = 235689
  AND e.WS_KEY     = 'direct-online-payment-requests';

---------------------------------------------------------------
-- 2) WS: merchant-events
---------------------------------------------------------------
INSERT INTO TUKUNAFUNC.IN_PASARELA_WS
  (CODIGO_BILLETERA, WS_KEY, ENABLED, TIPO_CONEXION, METODO_HTTP, TIPO_REQUEST, URL)
VALUES
  (235689, 'merchant-events', 'S', 'REST', 'POST', 'JSON',
   'https://sandbox-mws.safetypay.com/mpi/api/v1/payments/notifications/merchant-events');

---------------------------------------------------------------
-- 3) WS: payments
---------------------------------------------------------------
INSERT INTO TUKUNAFUNC.IN_PASARELA_WS
  (CODIGO_BILLETERA, WS_KEY, ENABLED, TIPO_CONEXION, METODO_HTTP, TIPO_REQUEST, URL)
VALUES
  (235689, 'payments', 'S', 'REST', 'GET', 'PARAMETROS',
   'https://sandbox-mws.safetypay.com/mpi/api/v1/payments/');

---------------------------------------------------------------
-- 4) WS: getbanks
---------------------------------------------------------------
INSERT INTO TUKUNAFUNC.IN_PASARELA_WS
  (CODIGO_BILLETERA, WS_KEY, ENABLED, TIPO_CONEXION, METODO_HTTP, TIPO_REQUEST, URL)
VALUES
  (235689, 'getbanks', 'S', 'REST', 'GET', 'PARAMETROS',
   'https://sandbox-mws.safetypay.com/mpi/api/v1/banks');

COMMIT;

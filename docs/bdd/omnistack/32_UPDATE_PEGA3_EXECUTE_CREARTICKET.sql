-- ============================================================
-- Ejecutar como: TUKUNAFUNC
--
-- MOTIVO:
--   Pega3 no tiene un paso de "reserva" separado como Tradicionales
--   (RecuperarNumerosDisponiblesPorCombinacion). CrearTicket vende el
--   ticket por completo — su propia respuesta trae "status":"Purchased".
--   Por eso se elimino CREATE_TICKET para Pega3 (LoteriaPega3CreateTicketStrategy)
--   y CrearTicket ahora se llama desde EXECUTE (LoteriaPega3ExecuteStrategy).
--
--   El WS_KEY 'EXECUTE.CASHIN' de pega3 apuntaba a PagarTicket — endpoint
--   equivocado para esta operacion (PagarTicket es para COBRAR el premio de
--   un ticket YA vendido y ganador, se usa en CASH_OUT). Se reapunta a
--   CrearTicket, la misma URL que ya usaba CREATE_TICKET.CASHIN.
--
--   CREATE_TICKET.CASHIN se deja intacta pero inerte (no se usa) — no se
--   borra por si hace falta revertir este cambio.
-- ============================================================

UPDATE TUKUNAFUNC.IN_OMNI_PROVEEDOR_WS
   SET URL = 'https://www8.loteria.com.ec/APIVentasLoteria/api/Ventas/CrearTicket',
       NOMBRE_OPERACION = 'CREAR_TICKET_PEGA3_EXECUTE'
 WHERE PROVEEDOR_KEY = 'pega3'
   AND WS_KEY = 'EXECUTE.CASHIN';

COMMIT;

-- ============================================================
-- VERIFICACION
-- ============================================================
SELECT PROVEEDOR_KEY, WS_KEY, URL, NOMBRE_OPERACION
  FROM TUKUNAFUNC.IN_OMNI_PROVEEDOR_WS
 WHERE PROVEEDOR_KEY = 'pega3' AND WS_KEY = 'EXECUTE.CASHIN';
-- Esperado: URL = .../CrearTicket, NOMBRE_OPERACION = CREAR_TICKET_PEGA3_EXECUTE

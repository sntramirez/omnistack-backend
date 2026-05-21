-- Ajuste: sin IDENTITY, usando secuencia + trigger (Oracle)

CREATE TABLE TUKUNAFUNC.AD_MAPEO_SERVICIOS (
    ID_MAPEO_SERVICIO      NUMBER(19,0) NOT NULL,
    CODIGO_BILLETERA       NUMBER(10,0) NOT NULL,
    ID_WS                  NUMBER(19,0) NOT NULL,
    APP_SERVICE_KEY        VARCHAR2(100 CHAR) NOT NULL,
    APP_OPERATION          VARCHAR2(100 CHAR) DEFAULT 'DEFAULT' NOT NULL,
    DIRECCION              VARCHAR2(10 CHAR) NOT NULL,
    PROTOCOLO_EXT          VARCHAR2(10 CHAR) DEFAULT 'REST' NOT NULL,
    SOAP_ACTION            VARCHAR2(200 CHAR),
    NAMESPACE_XML          VARCHAR2(300 CHAR),
    ORIGEN_VALOR           VARCHAR2(15 CHAR) DEFAULT 'APP' NOT NULL,
    SECCION_APP            VARCHAR2(20 CHAR) NOT NULL,
    ATRIBUTO_APP           VARCHAR2(400 CHAR) NOT NULL,
    SECCION_EXT            VARCHAR2(20 CHAR) NOT NULL,
    ATRIBUTO_EXT           VARCHAR2(400 CHAR) NOT NULL,
    TIPO_DATO              VARCHAR2(20 CHAR) DEFAULT 'STRING' NOT NULL,
    FORMATO_FECHA          VARCHAR2(50 CHAR),
    TRANSFORMACION_EXPR    VARCHAR2(1000 CHAR),
    VALOR_FIJO             CLOB,
    ORDEN_APLICACION       NUMBER(6,0) DEFAULT 1 NOT NULL,
    OBLIGATORIO            CHAR(1) DEFAULT 'N' NOT NULL,
    ACTIVO                 CHAR(1) DEFAULT 'S' NOT NULL,
    FECHA_INICIO_VIGENCIA  TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    FECHA_FIN_VIGENCIA     TIMESTAMP,
    USUARIO_CREACION       VARCHAR2(50 CHAR) DEFAULT USER NOT NULL,
    FECHA_CREACION         TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    USUARIO_MODIFICACION   VARCHAR2(50 CHAR),
    FECHA_MODIFICACION     TIMESTAMP,
    OBSERVACION            VARCHAR2(500 CHAR),

    CONSTRAINT PK_AD_MAPEO_SERVICIOS PRIMARY KEY (ID_MAPEO_SERVICIO),
    CONSTRAINT FK_AD_MAPEO_SERV_BILL FOREIGN KEY (CODIGO_BILLETERA)
        REFERENCES TUKUNAFUNC.AD_BILLETERAS_DIGITALES (CODIGO),
    CONSTRAINT FK_AD_MAPEO_SERV_WS FOREIGN KEY (ID_WS)
        REFERENCES TUKUNAFUNC.IN_PASARELA_WS (ID_WS),
    CONSTRAINT CK_AD_MAPEO_DIR CHECK (DIRECCION IN ('REQUEST','RESPONSE','ERROR')),
    CONSTRAINT CK_AD_MAPEO_PROTO CHECK (PROTOCOLO_EXT IN ('REST','SOAP')),
    CONSTRAINT CK_AD_MAPEO_ORIGEN CHECK (ORIGEN_VALOR IN ('APP','FIJO','SISTEMA')),
    CONSTRAINT CK_AD_MAPEO_SECC_APP CHECK (SECCION_APP IN ('PATH_PARAM','QUERY_PARAM','HEADER','BODY','XML_NODE')),
    CONSTRAINT CK_AD_MAPEO_SECC_EXT CHECK (SECCION_EXT IN ('PATH_PARAM','QUERY_PARAM','HEADER','BODY','XML_NODE')),
    CONSTRAINT CK_AD_MAPEO_TIPO CHECK (TIPO_DATO IN ('STRING','NUMBER','BOOLEAN','DATE','DATETIME','OBJECT','ARRAY')),
    CONSTRAINT CK_AD_MAPEO_OBLIG CHECK (OBLIGATORIO IN ('S','N')),
    CONSTRAINT CK_AD_MAPEO_ACTIVO CHECK (ACTIVO IN ('S','N'))
);

CREATE SEQUENCE TUKUNAFUNC.SEQ_AD_MAPEO_SERVICIOS
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE OR REPLACE TRIGGER TUKUNAFUNC.TRG_BI_AD_MAPEO_SERVICIOS
BEFORE INSERT ON TUKUNAFUNC.AD_MAPEO_SERVICIOS
FOR EACH ROW
WHEN (NEW.ID_MAPEO_SERVICIO IS NULL)
BEGIN
    :NEW.ID_MAPEO_SERVICIO := TUKUNAFUNC.SEQ_AD_MAPEO_SERVICIOS.NEXTVAL;
END;
/

CREATE UNIQUE INDEX TUKUNAFUNC.UIX_AD_MAPEO_SERV_01
ON TUKUNAFUNC.AD_MAPEO_SERVICIOS (
    CODIGO_BILLETERA, APP_SERVICE_KEY, APP_OPERATION, DIRECCION,
    SECCION_APP, ATRIBUTO_APP, SECCION_EXT, ATRIBUTO_EXT
);

CREATE INDEX TUKUNAFUNC.IX_AD_MAPEO_SERV_01
ON TUKUNAFUNC.AD_MAPEO_SERVICIOS (CODIGO_BILLETERA, APP_SERVICE_KEY, ACTIVO);

CREATE INDEX TUKUNAFUNC.IX_AD_MAPEO_SERV_02
ON TUKUNAFUNC.AD_MAPEO_SERVICIOS (ID_WS, ACTIVO);


--------------------------------------------------------------------------------------------------

/* =====================================================================
   INSERT COMPLETO CORREGIDO (Oracle) - evita ORA-00928
   Formato correcto: INSERT ... WITH ... SELECT ...
   ===================================================================== */

INSERT INTO TUKUNAFUNC.AD_MAPEO_SERVICIOS (
    ID_MAPEO_SERVICIO,
    CODIGO_BILLETERA,
    ID_WS,
    APP_SERVICE_KEY,
    APP_OPERATION,
    DIRECCION,
    PROTOCOLO_EXT,
    ORIGEN_VALOR,
    SECCION_APP,
    ATRIBUTO_APP,
    SECCION_EXT,
    ATRIBUTO_EXT,
    TIPO_DATO,
    ORDEN_APLICACION,
    OBLIGATORIO,
    ACTIVO,
    USUARIO_CREACION
)
WITH MAP_ROWS AS (
    /* =========================
       direct-online-payment-requests / DEFAULT
       ========================= */
    SELECT 'ALL' PROVIDER_SCOPE, 'direct-online-payment-requests' APP_SERVICE_KEY, 'DEFAULT' APP_OPERATION, 'REQUEST' DIRECCION, 'REST' PROTOCOLO_EXT,
           'APP' ORIGEN_VALOR, 'BODY' SECCION_APP, 'sales_amount.value' ATRIBUTO_APP, 'BODY' SECCION_EXT, 'sales_amount.value' ATRIBUTO_EXT,
           'NUMBER' TIPO_DATO, 1 ORDEN_APLICACION, 'S' OBLIGATORIO FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','REQUEST','REST','APP','BODY','sales_amount.currency_code','BODY','sales_amount.currency_code','STRING',2,'S' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','REQUEST','REST','APP','BODY','sales_amount','BODY','sales_amount','OBJECT',3,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','REQUEST','REST','APP','BODY','country_code','BODY','country_code','STRING',4,'S' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','REQUEST','REST','APP','BODY','bank_id','BODY','bank_id','STRING',5,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','REQUEST','REST','APP','BODY','merchant_set_pay_amount','BODY','merchant_set_pay_amount','BOOLEAN',6,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','REQUEST','REST','APP','BODY','expiration_time_minutes','BODY','expiration_time_minutes','NUMBER',7,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','REQUEST','REST','APP','BODY','language_code','BODY','language_code','STRING',8,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','REQUEST','REST','APP','BODY','custom_merchant_name','BODY','custom_merchant_name','STRING',9,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','REQUEST','REST','APP','BODY','merchant_sales_id','BODY','merchant_sales_id','STRING',10,'S' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','REQUEST','REST','APP','BODY','requested_payment_type','BODY','requested_payment_type','STRING',11,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','REQUEST','REST','APP','BODY','transaction_email','BODY','transaction_email','STRING',12,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','REQUEST','REST','APP','BODY','send_email_shopper','BODY','send_email_shopper','BOOLEAN',13,'N' FROM DUAL

    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','responseDatetime','BODY','response_datetime','DATETIME',101,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','operationId','BODY','operation_id','STRING',102,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','bankRedirectUrl','BODY','bank_redirect_url','STRING',103,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','paymentExpirationDatetime','BODY','payment_expiration_datetime','DATETIME',104,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','paymentExpirationDatetimeUtc','BODY','payment_expiration_datetime_utc','DATETIME',105,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','transactionId','BODY','transaction_id','STRING',106,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','payableAmounts','BODY','payable_amounts','ARRAY',107,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','paymentLocations','BODY','payment_locations','ARRAY',108,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','payableAmountsItem.amount.value','BODY','amount.value','NUMBER',109,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','payableAmountsItem.amount.currency_code','BODY','amount.currency_code','STRING',110,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','payableAmountsItem.additional_info','BODY','additional_info','STRING',111,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','paymentLocationsItem.location_id','BODY','location_id','STRING',112,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','paymentLocationsItem.location_name','BODY','location_name','STRING',113,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','paymentLocationsItem.bank_subsidiary_code','BODY','bank_subsidiary_code','STRING',114,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','paymentLocationsItem.payment_instructions','BODY','payment_instructions','ARRAY',115,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','paymentLocationsItem.howto_pay_steps','BODY','howto_pay_steps','ARRAY',116,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','paymentLocationsItem.status','BODY','status','STRING',117,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','paymentInstructionsItem.name','BODY','name','STRING',118,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','paymentInstructionsItem.value','BODY','value','STRING',119,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','paymentInstructionsItem.display_label','BODY','display_label','STRING',120,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','howtoPayStepsItem.step_number','BODY','step_number','NUMBER',121,'N' FROM DUAL
    UNION ALL SELECT 'ALL','direct-online-payment-requests','DEFAULT','RESPONSE','REST','APP','BODY','howtoPayStepsItem.step_instruction','BODY','step_instruction','STRING',122,'N' FROM DUAL

    /* =========================
       direct-online-payment-requests / PAYSAFE
       ========================= */
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','merchant_set_pay_amount_data.merchant_currency_code','BODY','sales_amount.currency_code','STRING',1,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','merchant_set_pay_amount_data.country_code','BODY','country_code','STRING',2,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','sales_amount.value','BODY','sales_amount.value','NUMBER',3,'S' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','sales_amount.currency_code','BODY','sales_amount.currency_code','STRING',4,'S' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','sales_amount','BODY','sales_amount','OBJECT',5,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','country_code','BODY','country_code','STRING',6,'S' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','bank_id','BODY','bank_id','STRING',7,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','merchant_set_pay_amount','BODY','merchant_set_pay_amount','BOOLEAN',8,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','expiration_time_minutes','BODY','expiration_time_minutes','NUMBER',9,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','language_code','BODY','language_code','STRING',10,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','custom_merchant_name','BODY','custom_merchant_name','STRING',11,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','merchant_sales_id','BODY','merchant_sales_id','STRING',12,'S' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','requested_payment_type','BODY','requested_payment_type','STRING',13,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','transaction_email','BODY','transaction_email','STRING',14,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','REQUEST','REST','APP','BODY','send_email_shopper','BODY','send_email_shopper','BOOLEAN',15,'N' FROM DUAL

    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','responseDatetime','BODY','response_datetime','DATETIME',101,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','operationId','BODY','operation_id','STRING',102,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','bankRedirectUrl','BODY','bank_redirect_url','STRING',103,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','paymentExpirationDatetime','BODY','payment_expiration_datetime','DATETIME',104,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','paymentExpirationDatetimeUtc','BODY','payment_expiration_datetime_utc','DATETIME',105,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','transactionId','BODY','transaction_id','STRING',106,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','payableAmounts','BODY','payable_amounts','ARRAY',107,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','paymentLocations','BODY','payment_locations','ARRAY',108,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','payableAmountsItem.amount.value','BODY','amount.value','NUMBER',109,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','payableAmountsItem.amount.currency_code','BODY','amount.currency_code','STRING',110,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','payableAmountsItem.additional_info','BODY','additional_info','STRING',111,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','paymentLocationsItem.location_id','BODY','location_id','STRING',112,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','paymentLocationsItem.location_name','BODY','location_name','STRING',113,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','paymentLocationsItem.bank_subsidiary_code','BODY','bank_subsidiary_code','STRING',114,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','paymentLocationsItem.payment_instructions','BODY','payment_instructions','ARRAY',115,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','paymentLocationsItem.howto_pay_steps','BODY','howto_pay_steps','ARRAY',116,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','paymentLocationsItem.status','BODY','status','STRING',117,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','paymentInstructionsItem.name','BODY','name','STRING',118,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','paymentInstructionsItem.value','BODY','value','STRING',119,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','paymentInstructionsItem.display_label','BODY','display_label','STRING',120,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','howtoPayStepsItem.step_number','BODY','step_number','NUMBER',121,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','direct-online-payment-requests','PAYSAFE','RESPONSE','REST','APP','BODY','howtoPayStepsItem.step_instruction','BODY','step_instruction','STRING',122,'N' FROM DUAL

    /* merchant-events / DEFAULT + PAYSAFE */
    UNION ALL SELECT 'ALL','merchant-events','DEFAULT','REQUEST','REST','APP','BODY','merchant_events','BODY','merchant_events','ARRAY',1,'S' FROM DUAL
    UNION ALL SELECT 'ALL','merchant-events','DEFAULT','REQUEST','REST','APP','BODY','request_datetime','BODY','request_datetime','DATETIME',2,'N' FROM DUAL
    UNION ALL SELECT 'ALL','merchant-events','DEFAULT','RESPONSE','REST','APP','BODY','requestId','BODY','request_id','STRING',101,'N' FROM DUAL
    UNION ALL SELECT 'ALL','merchant-events','DEFAULT','RESPONSE','REST','APP','BODY','responseDatetime','BODY','response_datetime','DATETIME',102,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','merchant-events','PAYSAFE','REQUEST','REST','APP','BODY','merchant_events','BODY','merchant_events','ARRAY',1,'S' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','merchant-events','PAYSAFE','REQUEST','REST','APP','BODY','request_datetime','BODY','request_datetime','DATETIME',2,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','merchant-events','PAYSAFE','RESPONSE','REST','APP','BODY','requestId','BODY','request_id','STRING',101,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','merchant-events','PAYSAFE','RESPONSE','REST','APP','BODY','responseDatetime','BODY','response_datetime','DATETIME',102,'N' FROM DUAL

    /* payments / DEFAULT + PAYSAFE */
    UNION ALL SELECT 'ALL','payments','DEFAULT','RESPONSE','REST','APP','BODY','requestId','BODY','request_id','STRING',101,'N' FROM DUAL
    UNION ALL SELECT 'ALL','payments','DEFAULT','RESPONSE','REST','APP','BODY','responseDatetime','BODY','response_datetime','DATETIME',102,'N' FROM DUAL
    UNION ALL SELECT 'ALL','payments','DEFAULT','RESPONSE','REST','APP','BODY','paymentOperations','BODY','payment_operations','ARRAY',103,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','payments','PAYSAFE','RESPONSE','REST','APP','BODY','requestId','BODY','request_id','STRING',101,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','payments','PAYSAFE','RESPONSE','REST','APP','BODY','responseDatetime','BODY','response_datetime','DATETIME',102,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','payments','PAYSAFE','RESPONSE','REST','APP','BODY','paymentOperations','BODY','payment_operations','ARRAY',103,'N' FROM DUAL

    /* getbanks / DEFAULT */
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','requestId','BODY','request_id','STRING',101,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','responseDatetime','BODY','response_datetime','DATETIME',102,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','banks','BODY','banks','ARRAY',103,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.bank_id','BODY','bank_id','STRING',201,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.bank_name','BODY','bank_name','STRING',202,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.bank_commercial_name','BODY','bank_commercial_name','STRING',203,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.bank_country_code','BODY','bank_country_code','STRING',204,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.bank_type','BODY','bank_type','STRING',205,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.show_standalone','BODY','show_standalone','BOOLEAN',206,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.channel','BODY','channel','STRING',207,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.channel_tag','BODY','channel_tag','STRING',208,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.status','BODY','status','STRING',209,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.access_type','BODY','access_type','STRING',210,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.language_code','BODY','language_code','STRING',211,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.working_hours','BODY','working_hours','STRING',212,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.disclaimer','BODY','disclaimer','STRING',213,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.default_currency_code','BODY','default_currency_code','STRING',214,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.locations_url','BODY','locations_url','STRING',215,'N' FROM DUAL
    UNION ALL SELECT 'ALL','getbanks','DEFAULT','RESPONSE','REST','APP','BODY','bank.amount_limits','BODY','amount_limits','ARRAY',216,'N' FROM DUAL

    /* getbanks / PAYSAFE */
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','requestId','BODY','request_id','STRING',101,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','responseDatetime','BODY','response_datetime','DATETIME',102,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','banks','BODY','banks','ARRAY',103,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.bank_id','BODY','bank_id','STRING',201,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.bank_name','BODY','bank_name','STRING',202,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.bank_commercial_name','BODY','bank_commercial_name','STRING',203,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.bank_country_code','BODY','bank_country_code','STRING',204,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.bank_type','BODY','bank_type','STRING',205,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.show_standalone','BODY','show_standalone','BOOLEAN',206,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.channel','BODY','channel','STRING',207,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.channel_tag','BODY','channel_tag','STRING',208,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.status','BODY','status','STRING',209,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.access_type','BODY','access_type','STRING',210,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.language_code','BODY','language_code','STRING',211,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.working_hours','BODY','working_hours','STRING',212,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.disclaimer','BODY','disclaimer','STRING',213,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.default_currency_code','BODY','default_currency_code','STRING',214,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.locations_url','BODY','locations_url','STRING',215,'N' FROM DUAL
    UNION ALL SELECT 'PAYSAFE','getbanks','PAYSAFE','RESPONSE','REST','APP','BODY','bank.amount_limits','BODY','amount_limits','ARRAY',216,'N' FROM DUAL

    /* getbanks / PICHINCHA */
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','requestId','BODY','request_id','STRING',101,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','responseDatetime','BODY','response_datetime','DATETIME',102,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','banks','BODY','banks','ARRAY',103,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.bank_id','BODY','bank_id','STRING',201,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.bank_name','BODY','bank_name','STRING',202,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.bank_commercial_name','BODY','bank_commercial_name','STRING',203,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.bank_country_code','BODY','bank_country_code','STRING',204,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.bank_type','BODY','bank_type','STRING',205,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.show_standalone','BODY','show_standalone','BOOLEAN',206,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.channel','BODY','channel','STRING',207,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.channel_tag','BODY','channel_tag','STRING',208,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.status','BODY','status','STRING',209,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.access_type','BODY','access_type','STRING',210,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.language_code','BODY','language_code','STRING',211,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.working_hours','BODY','working_hours','STRING',212,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.disclaimer','BODY','disclaimer','STRING',213,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.default_currency_code','BODY','default_currency_code','STRING',214,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.locations_url','BODY','locations_url','STRING',215,'N' FROM DUAL
    UNION ALL SELECT 'PICHINCHA','getbanks','PICHINCHA','RESPONSE','REST','APP','BODY','bank.amount_limits','BODY','amount_limits','ARRAY',216,'N' FROM DUAL
),
WS_BASE AS (
    SELECT
        WS.ID_WS,
        WS.CODIGO_BILLETERA,
        WS.WS_KEY,
        UPPER(NVL(B.NOMBRE_BILLETERA_DIGITAL, '')) AS PROVIDER_NAME
    FROM TUKUNAFUNC.IN_PASARELA_WS WS
    LEFT JOIN TUKUNAFUNC.AD_BILLETERAS_DIGITALES B
      ON B.CODIGO = WS.CODIGO_BILLETERA
    WHERE WS.ENABLED = 'S'
)
SELECT
    TUKUNAFUNC.SEQ_AD_MAPEO_SERVICIOS.NEXTVAL,
    W.CODIGO_BILLETERA,
    W.ID_WS,
    M.APP_SERVICE_KEY,
    M.APP_OPERATION,
    M.DIRECCION,
    M.PROTOCOLO_EXT,
    M.ORIGEN_VALOR,
    M.SECCION_APP,
    M.ATRIBUTO_APP,
    M.SECCION_EXT,
    M.ATRIBUTO_EXT,
    M.TIPO_DATO,
    M.ORDEN_APLICACION,
    M.OBLIGATORIO,
    'S',
    USER
FROM MAP_ROWS M
JOIN WS_BASE W
  ON W.WS_KEY = M.APP_SERVICE_KEY
WHERE
    (
        M.PROVIDER_SCOPE = 'ALL'
        OR (M.PROVIDER_SCOPE = 'PAYSAFE' AND W.PROVIDER_NAME LIKE '%PAYSAFE%')
        OR (M.PROVIDER_SCOPE = 'PICHINCHA' AND W.PROVIDER_NAME LIKE '%PICHINCHA%')
    )
    AND NOT EXISTS (
        SELECT 1
        FROM TUKUNAFUNC.AD_MAPEO_SERVICIOS X
        WHERE X.CODIGO_BILLETERA = W.CODIGO_BILLETERA
          AND X.APP_SERVICE_KEY = M.APP_SERVICE_KEY
          AND X.APP_OPERATION = M.APP_OPERATION
          AND X.DIRECCION = M.DIRECCION
          AND X.SECCION_APP = M.SECCION_APP
          AND X.ATRIBUTO_APP = M.ATRIBUTO_APP
          AND X.SECCION_EXT = M.SECCION_EXT
          AND X.ATRIBUTO_EXT = M.ATRIBUTO_EXT
    );

COMMIT;

/* ============================================================
   ERROR MAPPING en AD_MAPEO_SERVICIOS
   Requiere: SEQ_AD_MAPEO_SERVICIOS
   ============================================================ */

INSERT INTO TUKUNAFUNC.AD_MAPEO_SERVICIOS (
    ID_MAPEO_SERVICIO,
    CODIGO_BILLETERA,
    ID_WS,
    APP_SERVICE_KEY,
    APP_OPERATION,
    DIRECCION,
    PROTOCOLO_EXT,
    ORIGEN_VALOR,
    SECCION_APP,
    ATRIBUTO_APP,
    SECCION_EXT,
    ATRIBUTO_EXT,
    TIPO_DATO,
    ORDEN_APLICACION,
    OBLIGATORIO,
    ACTIVO,
    USUARIO_CREACION
)
WITH ERROR_ROWS AS (
    SELECT 'direct-online-payment-requests' APP_SERVICE_KEY, 'DEFAULT' APP_OPERATION, 'error' APP_ATTR, 'error' EXT_PATH FROM DUAL
    UNION ALL SELECT 'merchant-events',               'DEFAULT', 'error', 'error' FROM DUAL
    UNION ALL SELECT 'payments',                      'DEFAULT', 'error', 'error' FROM DUAL
    UNION ALL SELECT 'getbanks',                      'DEFAULT', 'error', 'error' FROM DUAL

    /* Ejemplos provider-specific (descomenta si aplica)
    UNION ALL SELECT 'payments', 'PICHINCHA', 'error', 'response.error' FROM DUAL
    UNION ALL SELECT 'getbanks', 'PICHINCHA', 'error', 'response.error' FROM DUAL
    */
)
SELECT
    TUKUNAFUNC.SEQ_AD_MAPEO_SERVICIOS.NEXTVAL,
    WS.CODIGO_BILLETERA,
    WS.ID_WS,
    E.APP_SERVICE_KEY,
    E.APP_OPERATION,
    'ERROR',
    NVL(WS.TIPO_CONEXION, 'REST'),
    'APP',
    'BODY',
    E.APP_ATTR,
    'BODY',
    E.EXT_PATH,
    'STRING',
    1,
    'N',
    'S',
    USER
FROM ERROR_ROWS E
JOIN TUKUNAFUNC.IN_PASARELA_WS WS
  ON LOWER(WS.WS_KEY) = LOWER(E.APP_SERVICE_KEY)
WHERE WS.ENABLED = 'S'
  AND NOT EXISTS (
      SELECT 1
      FROM TUKUNAFUNC.AD_MAPEO_SERVICIOS X
      WHERE X.CODIGO_BILLETERA = WS.CODIGO_BILLETERA
        AND X.APP_SERVICE_KEY = E.APP_SERVICE_KEY
        AND X.APP_OPERATION = E.APP_OPERATION
        AND X.DIRECCION = 'ERROR'
        AND X.SECCION_APP = 'BODY'
        AND X.ATRIBUTO_APP = E.APP_ATTR
        AND X.SECCION_EXT = 'BODY'
        AND X.ATRIBUTO_EXT = E.EXT_PATH
  );

COMMIT;



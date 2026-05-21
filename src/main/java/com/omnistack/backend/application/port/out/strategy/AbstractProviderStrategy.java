package com.omnistack.backend.application.port.out.strategy;

import com.omnistack.backend.application.service.ProviderWsService;
import com.omnistack.backend.config.properties.AppProperties;
import com.omnistack.backend.domain.enums.Capability;
import com.omnistack.backend.domain.enums.MovementType;
import com.omnistack.backend.domain.model.ServiceDefinition;
import com.omnistack.backend.shared.exception.IntegrationException;
import java.math.BigDecimal;
import java.util.Map;

/**
 * Base comun para strategies de proveedor externo.
 *
 * <p>Centraliza los helpers de resolucion de configuracion, validacion de valores
 * y extraccion de payload que se repiten en todas las implementaciones concretas.
 * Las subclases inyectan {@code AppProperties} via constructor y lo pasan como
 * parametro en cada llamada al helper correspondiente.</p>
 */
public abstract class AbstractProviderStrategy implements TransactionFlowStrategy {

    /**
     * Devuelve la configuracion del proveedor identificado por {@code key}, o {@code null} si no existe.
     *
     * @param appProperties propiedades de la aplicacion
     * @param key clave del proveedor en el mapa de integraciones
     * @return configuracion del proveedor, o null
     */
    protected AppProperties.ProviderProperties findProviderProperties(AppProperties appProperties, String key) {
        return appProperties.getIntegration().getProviders().get(key);
    }

    /**
     * Devuelve la configuracion del proveedor o lanza excepcion si no existe.
     *
     * @param appProperties propiedades de la aplicacion
     * @param key clave del proveedor
     * @param providerName nombre legible para el mensaje de error
     * @return configuracion del proveedor
     * @throws IntegrationException si no existe configuracion para el proveedor
     */
    protected AppProperties.ProviderProperties getProviderProperties(
            AppProperties appProperties,
            String key,
            String providerName) {
        AppProperties.ProviderProperties provider = findProviderProperties(appProperties, key);
        if (provider == null) {
            throw new IntegrationException("No existe configuracion para el proveedor " + providerName);
        }
        return provider;
    }

    /**
     * Indica si el proveedor tiene el item configurado y la URL en DB para la operacion dada.
     * La URL se verifica contra IN_OMNI_PROVEEDOR_WS via ProviderWsService.
     *
     * @param provider          configuracion del proveedor
     * @param providerWsService servicio de URLs desde DB
     * @param providerKey       clave del proveedor en el mapa de integraciones
     * @param capability        capacidad transaccional
     * @param serviceDefinition definicion comercial del servicio
     * @return true si item coincide con rms_item_code y existe URL en DB
     */
    protected boolean hasConfiguredOperation(
            AppProperties.ProviderProperties provider,
            ProviderWsService providerWsService,
            String providerKey,
            Capability capability,
            ServiceDefinition serviceDefinition) {
        AppProperties.ProviderOperationProperties operation =
                findOperation(provider, capability.name(), serviceDefinition.getMovementType());
        String wsKey = toWsKey(capability.name(), serviceDefinition.getMovementType());
        return operation != null
                && operation.getItem() != null
                && operation.getItem().equalsIgnoreCase(serviceDefinition.getRmsItemCode())
                && providerWsService.hasUrl(providerKey, wsKey);
    }

    /**
     * Valida que el item coincida y retorna la URL completa desde DB para la operacion.
     *
     * @param provider          configuracion del proveedor
     * @param providerWsService servicio de URLs desde DB
     * @param providerKey       clave del proveedor
     * @param capability        capacidad transaccional
     * @param serviceDefinition definicion comercial del servicio
     * @param providerName      nombre legible para mensajes de error
     * @return URL completa del endpoint externo
     * @throws IntegrationException si el item no coincide o no existe URL en DB
     */
    protected String getRequiredOperationUrl(
            AppProperties.ProviderProperties provider,
            ProviderWsService providerWsService,
            String providerKey,
            Capability capability,
            ServiceDefinition serviceDefinition,
            String providerName) {
        AppProperties.ProviderOperationProperties operation =
                findOperation(provider, capability.name(), serviceDefinition.getMovementType());
        if (operation == null || operation.getItem() == null
                || !operation.getItem().equalsIgnoreCase(serviceDefinition.getRmsItemCode())) {
            throw new IntegrationException(providerName + " no tiene item configurado para rms_item_code="
                    + serviceDefinition.getRmsItemCode() + ", capability=" + capability.name()
                    + " y movement_type=" + serviceDefinition.getMovementType());
        }
        String wsKey = toWsKey(capability.name(), serviceDefinition.getMovementType());
        return providerWsService.requireUrl(providerKey, wsKey, providerName);
    }

    /**
     * Construye la clave WS para buscar en IN_OMNI_PROVEEDOR_WS.
     * Formato: CAPABILITY.CASHIN o CAPABILITY.CASHOUT
     *
     * @param capabilityKey clave de la capacidad (ej: "PRECHECK", "PRECHECK_SORTEO")
     * @param movementType  tipo de movimiento
     * @return clave WS (ej: "PRECHECK.CASHIN")
     */
    protected static String toWsKey(String capabilityKey, MovementType movementType) {
        return capabilityKey + "." + (movementType == MovementType.CASH_IN ? "CASHIN" : "CASHOUT");
    }

    /**
     * Valida que el valor actual coincida con el valor esperado de la configuracion del proveedor.
     *
     * @param fieldName nombre del campo para el mensaje de error
     * @param currentValue valor recibido en el request
     * @param expectedValue valor esperado segun la configuracion
     * @param providerName nombre legible del proveedor para el mensaje de error
     * @throws IntegrationException si el valor no coincide o la configuracion esta incompleta
     */
    protected void validateValue(
            String fieldName,
            String currentValue,
            String expectedValue,
            String providerName) {
        if (expectedValue == null || expectedValue.isBlank()) {
            throw new IntegrationException(
                    "La configuracion de " + providerName + " no define el valor requerido para " + fieldName);
        }
        if (!expectedValue.equalsIgnoreCase(currentValue)) {
            throw new IntegrationException(
                    "La solicitud no coincide con la configuracion esperada de " + providerName + " para " + fieldName);
        }
    }

    /**
     * Extrae un valor del payload como String.
     *
     * @param payload mapa de datos del proveedor
     * @param key clave del campo
     * @return valor como String, o null si no existe
     */
    protected String stringValue(Map<String, Object> payload, String key) {
        if (payload == null) {
            return null;
        }
        Object value = payload.get(key);
        return value == null ? null : String.valueOf(value);
    }

    /**
     * Extrae un valor del payload o retorna un fallback si es null o vacio.
     *
     * @param payload mapa de datos del proveedor
     * @param key clave del campo
     * @param fallback valor de respaldo
     * @return valor encontrado o fallback
     */
    protected String resolveValue(Map<String, Object> payload, String key, String fallback) {
        String value = stringValue(payload, key);
        return value == null || value.isBlank() ? fallback : value;
    }

    /**
     * Extrae un valor del payload como Integer.
     *
     * @param payload mapa de datos del proveedor
     * @param key clave del campo
     * @return valor como Integer, o null si no existe
     */
    protected Integer integerValue(Map<String, Object> payload, String key) {
        String value = stringValue(payload, key);
        return value == null || value.isBlank() ? null : Integer.valueOf(value);
    }

    /**
     * Extrae un valor del payload como BigDecimal.
     *
     * @param payload mapa de datos del proveedor
     * @param key clave del campo
     * @return valor como BigDecimal, o null si no existe
     */
    protected BigDecimal decimalValue(Map<String, Object> payload, String key) {
        String value = stringValue(payload, key);
        return value == null || value.isBlank() ? null : new BigDecimal(value);
    }

    private AppProperties.ProviderOperationProperties findOperation(
            AppProperties.ProviderProperties provider,
            String capabilityKey,
            MovementType movementType) {
        if (provider.getServices() == null || movementType == null) {
            return null;
        }
        AppProperties.ProviderCapabilityProperties capabilityProperties =
                provider.getServices().get(capabilityKey);
        if (capabilityProperties == null) {
            return null;
        }
        return movementType == MovementType.CASH_IN
                ? capabilityProperties.getCashin()
                : capabilityProperties.getCashout();
    }
}

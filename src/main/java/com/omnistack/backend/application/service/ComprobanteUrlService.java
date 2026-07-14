package com.omnistack.backend.application.service;

import com.omnistack.backend.application.port.out.ComprobanteStoragePort;
import com.omnistack.backend.config.properties.AppProperties;
import com.omnistack.backend.shared.constants.ApiPaths;
import com.omnistack.backend.shared.exception.IntegrationException;
import java.util.Base64;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * Decodifica el comprobante en base64 devuelto por los proveedores (Tradicionales/Pega3),
 * lo guarda via {@link ComprobanteStoragePort} y arma la URL publica para servirlo,
 * en vez de exponer el base64 directamente al front.
 */
@Service
@RequiredArgsConstructor
public class ComprobanteUrlService {

    private static final String CONTENT_TYPE_PDF = "application/pdf";
    private static final String CONTENT_TYPE_PNG = "image/png";
    private static final String CONTENT_TYPE_JPEG = "image/jpeg";
    private static final String CONTENT_TYPE_OCTET_STREAM = "application/octet-stream";

    private static final byte[] PDF_MAGIC = {0x25, 0x50, 0x44, 0x46}; // %PDF
    private static final byte[] PNG_MAGIC = {(byte) 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
    private static final byte[] JPEG_MAGIC = {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF};

    private final ComprobanteStoragePort comprobanteStoragePort;
    private final AppProperties appProperties;

    /**
     * @return la URL del comprobante almacenado, o null si no habia contenido que guardar.
     */
    public String storeAndBuildUrl(String base64Content) {
        if (base64Content == null || base64Content.isBlank()) {
            return null;
        }
        byte[] content;
        try {
            content = Base64.getDecoder().decode(base64Content);
        } catch (IllegalArgumentException e) {
            throw new IntegrationException("El comprobante recibido del proveedor no es base64 valido");
        }
        String id = comprobanteStoragePort.store(content, detectContentType(content));
        String baseUrl = appProperties.getComprobantes().getPublicBaseUrl();
        return baseUrl + ApiPaths.V1_COMPROBANTES + "/" + id;
    }

    /**
     * El spec de Loteria Nacional documenta el comprobante como PDF, pero no hay garantia de
     * que el proveedor siempre lo entregue asi (ej. podria devolver PNG) — se detecta el tipo
     * real por los primeros bytes del archivo en vez de asumir uno fijo.
     */
    private String detectContentType(byte[] content) {
        if (startsWith(content, PDF_MAGIC)) {
            return CONTENT_TYPE_PDF;
        }
        if (startsWith(content, PNG_MAGIC)) {
            return CONTENT_TYPE_PNG;
        }
        if (startsWith(content, JPEG_MAGIC)) {
            return CONTENT_TYPE_JPEG;
        }
        return CONTENT_TYPE_OCTET_STREAM;
    }

    private boolean startsWith(byte[] content, byte[] magic) {
        if (content.length < magic.length) {
            return false;
        }
        for (int i = 0; i < magic.length; i++) {
            if (content[i] != magic[i]) {
                return false;
            }
        }
        return true;
    }
}

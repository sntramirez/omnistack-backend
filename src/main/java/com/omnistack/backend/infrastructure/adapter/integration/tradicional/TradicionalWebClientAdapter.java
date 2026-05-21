package com.omnistack.backend.infrastructure.adapter.integration.tradicional;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.omnistack.backend.application.port.in.ProviderTokenResolverUseCase;
import com.omnistack.backend.application.port.out.TradicionalAnularVentaPort;
import com.omnistack.backend.application.port.out.TradicionalFigurasQueryPort;
import com.omnistack.backend.application.port.out.TradicionalJuegoQueryPort;
import com.omnistack.backend.application.port.out.TradicionalNumerosQueryPort;
import com.omnistack.backend.application.port.out.TradicionalSorteosQueryPort;
import com.omnistack.backend.application.port.out.TradicionalVentaBoletosPort;
import com.omnistack.backend.application.port.out.TradicionalVerifyPort;
import com.omnistack.backend.config.properties.AppProperties;
import com.omnistack.backend.domain.model.ExternalTransactionResponse;
import com.omnistack.backend.domain.model.TradicionalAnularVentaCommand;
import com.omnistack.backend.domain.model.TradicionalFigurasQueryCommand;
import com.omnistack.backend.domain.model.TradicionalJuegoQueryCommand;
import com.omnistack.backend.domain.model.TradicionalNumerosQueryCommand;
import com.omnistack.backend.domain.model.TradicionalSorteosQueryCommand;
import com.omnistack.backend.domain.model.TradicionalVentaBoletosCommand;
import com.omnistack.backend.domain.model.TradicionalVerifyCommand;
import com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto.TradicionalAnularVentaRequest;
import com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto.TradicionalAnularVentaResponse;
import com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto.TradicionalFigurasQueryRequest;
import com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto.TradicionalFigurasQueryResponse;
import com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto.TradicionalJuegoQueryRequest;
import com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto.TradicionalJuegoQueryResponse;
import com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto.TradicionalNumerosQueryRequest;
import com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto.TradicionalNumerosQueryResponse;
import com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto.TradicionalSorteosQueryRequest;
import com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto.TradicionalSorteosQueryResponse;
import com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto.TradicionalVentaBoletosRequest;
import com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto.TradicionalVentaBoletosResponse;
import com.omnistack.backend.shared.exception.IntegrationException;
import com.omnistack.backend.shared.util.JsonUtil;
import java.util.Base64;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientRequestException;
import reactor.core.publisher.Mono;

/**
 * Adapter HTTP para todas las operaciones del proveedor LN Tradicionales.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class TradicionalWebClientAdapter implements
        TradicionalJuegoQueryPort,
        TradicionalSorteosQueryPort,
        TradicionalFigurasQueryPort,
        TradicionalNumerosQueryPort,
        TradicionalVentaBoletosPort,
        TradicionalAnularVentaPort,
        TradicionalVerifyPort {

    private static final String PROVIDER_KEY = "tradicional";

    private final WebClient omnistackWebClient;
    private final AppProperties appProperties;
    private final ObjectMapper objectMapper;
    private final ProviderTokenResolverUseCase providerTokenResolverUseCase;

    @Override
    public ExternalTransactionResponse queryJuegos(TradicionalJuegoQueryCommand command, String operationPath) {
        AppProperties.ProviderProperties provider = getProviderProperties();
        String token = resolveToken(command.getCategoryCode(), command.getSubcategoryCode(), provider);

        TradicionalJuegoQueryRequest request = TradicionalJuegoQueryRequest.builder()
                .userName(resolveUserName(provider))
                .token(token)
                .medioId(provider.getMedioId())
                .build();

        String body = invokePost(operationPath, provider, request, "queryJuegos", "consulta juegos Tradicionales");

        List<TradicionalJuegoQueryResponse> juegos;
        try {
            juegos = objectMapper.readValue(body, new TypeReference<List<TradicionalJuegoQueryResponse>>() {});
        } catch (JsonProcessingException e) {
            throw new IntegrationException("Tradicionales queryJuegos retorno un body no parseable");
        }

        Map<String, Object> payload = new LinkedHashMap<>();
        boolean isError = juegos == null || juegos.isEmpty();
        payload.put("juegos", juegos != null ? juegos : Collections.emptyList());

        return ExternalTransactionResponse.builder()
                .approved(!isError)
                .externalCode(isError ? "ERROR" : "0")
                .externalMessage(isError ? "No se obtuvieron juegos disponibles" : "")
                .payload(payload)
                .build();
    }

    @Override
    public ExternalTransactionResponse querySorteos(TradicionalSorteosQueryCommand command, String operationPath) {
        AppProperties.ProviderProperties provider = getProviderProperties();
        String token = resolveToken(command.getCategoryCode(), command.getSubcategoryCode(), provider);

        TradicionalSorteosQueryRequest request = TradicionalSorteosQueryRequest.builder()
                .userName(resolveUserName(provider))
                .token(token)
                .medioId(provider.getMedioId())
                .juegoId(command.getJuegoId())
                .build();

        TradicionalSorteosQueryResponse response = invokePost(
                operationPath, provider, request, TradicionalSorteosQueryResponse.class,
                "querySorteos", "consulta sorteos Tradicionales");

        Map<String, Object> payload = new LinkedHashMap<>();
        boolean isError = !isSuccess(response.getCodError());
        payload.put("listaSorteos", response.getListaSorteos());
        payload.put("codError", response.getCodError());
        payload.put("msgError", response.getMsgError());

        return ExternalTransactionResponse.builder()
                .approved(!isError)
                .externalCode(String.valueOf(response.getCodError()))
                .externalMessage(response.getMsgError() != null ? response.getMsgError() : "")
                .payload(payload)
                .build();
    }

    @Override
    public ExternalTransactionResponse queryFiguras(TradicionalFigurasQueryCommand command, String operationPath) {
        AppProperties.ProviderProperties provider = getProviderProperties();
        String token = resolveToken(command.getCategoryCode(), command.getSubcategoryCode(), provider);

        TradicionalFigurasQueryRequest request = TradicionalFigurasQueryRequest.builder()
                .userName(resolveUserName(provider))
                .token(token)
                .medioId(provider.getMedioId())
                .juegoId(command.getJuegoId())
                .build();

        TradicionalFigurasQueryResponse response = invokePost(
                operationPath, provider, request, TradicionalFigurasQueryResponse.class,
                "queryFiguras", "consulta figuras Tradicionales");

        Map<String, Object> payload = new LinkedHashMap<>();
        boolean isError = !isSuccess(response.getCodError());
        payload.put("listaFiguras", response.getListaFiguras());
        payload.put("codError", response.getCodError());
        payload.put("msgError", response.getMsgError());

        return ExternalTransactionResponse.builder()
                .approved(!isError)
                .externalCode(String.valueOf(response.getCodError()))
                .externalMessage(response.getMsgError() != null ? response.getMsgError() : "")
                .payload(payload)
                .build();
    }

    @Override
    public ExternalTransactionResponse queryNumeros(TradicionalNumerosQueryCommand command, String operationPath) {
        AppProperties.ProviderProperties provider = getProviderProperties();
        String token = resolveToken(command.getCategoryCode(), command.getSubcategoryCode(), provider);

        TradicionalNumerosQueryRequest request = TradicionalNumerosQueryRequest.builder()
                .userName(resolveUserName(provider))
                .token(token)
                .medioId(provider.getMedioId())
                .juegoId(command.getJuegoId())
                .sorteoId(command.getSorteoId())
                .combinacion(command.getCombinacion())
                .combinacionFigura(command.getCombinacionFigura())
                .sugerir(command.getSugerir())
                .cantidad(command.getCantidad())
                .registros(command.getRegistros())
                .build();

        TradicionalNumerosQueryResponse response = invokePost(
                operationPath, provider, request, TradicionalNumerosQueryResponse.class,
                "queryNumeros", "consulta numeros Tradicionales");

        Map<String, Object> payload = new LinkedHashMap<>();
        boolean isError = !isSuccess(response.getCodError());
        payload.put("listaNumeros", response.getListaNumeros());
        payload.put("totalResults", response.getTotalResults());
        payload.put("codError", response.getCodError());
        payload.put("msgError", response.getMsgError());

        return ExternalTransactionResponse.builder()
                .approved(!isError)
                .externalCode(String.valueOf(response.getCodError()))
                .externalMessage(response.getMsgError() != null ? response.getMsgError() : "")
                .payload(payload)
                .build();
    }

    @Override
    public ExternalTransactionResponse ventaBoletos(TradicionalVentaBoletosCommand command, String operationPath) {
        AppProperties.ProviderProperties provider = getProviderProperties();
        String token = resolveToken(command.getCategoryCode(), command.getSubcategoryCode(), provider);

        TradicionalVentaBoletosRequest request = TradicionalVentaBoletosRequest.builder()
                .userName(resolveUserName(provider))
                .token(token)
                .medioId(provider.getMedioId())
                .reservaId(command.getReservaId())
                .cliente(command.getCliente())
                .totalVenta(command.getTotalVenta())
                .numeroIdentificacion(command.getNumeroIdentificacion())
                .nombreComprador(command.getNombreComprador())
                .numeroCelularComprador(command.getNumeroCelularComprador())
                .correoElectronicoComprador(command.getCorreoElectronicoComprador())
                .listaOrdenCompra(List.of(
                        TradicionalVentaBoletosRequest.OrdenCompra.builder()
                                .ordenCompra(command.getOrdenCompra())
                                .listaFormaCobro(List.of(
                                        TradicionalVentaBoletosRequest.FormaCobro.builder()
                                                .formaCobro(command.getFormaCobro())
                                                .total(command.getTotalVenta())
                                                .build()))
                                .build()))
                .listaJuegos(List.of(
                        TradicionalVentaBoletosRequest.JuegoEntry.builder()
                                .juegoId(command.getJuegoId())
                                .listaSorteos(List.of(
                                        TradicionalVentaBoletosRequest.SorteoEntry.builder()
                                                .sorteoId(command.getSorteoId())
                                                .numero(command.getNumero())
                                                .cantidadBoletos(command.getCantidadBoletos())
                                                .build()))
                                .build()))
                .build();

        TradicionalVentaBoletosResponse response = invokePost(
                operationPath, provider, request, TradicionalVentaBoletosResponse.class,
                "ventaBoletos", "venta boletos Tradicionales");

        Map<String, Object> payload = new LinkedHashMap<>();
        boolean isError = !response.isSuccess();
        payload.put("codError", response.getCodError());
        payload.put("msgError", response.getMsgError());
        payload.put("authorization", response.getVentaId());
        payload.put("ventaId", response.getVentaId());
        payload.put("fechaVenta", response.getFechaVenta());
        payload.put("transaccion", response.getTransaccion());

        return ExternalTransactionResponse.builder()
                .approved(!isError)
                .externalCode(String.valueOf(response.getCodError()))
                .externalMessage(response.getMsgError() != null ? response.getMsgError() : "")
                .payload(payload)
                .build();
    }

    @Override
    public ExternalTransactionResponse anularVenta(TradicionalAnularVentaCommand command, String operationPath) {
        AppProperties.ProviderProperties provider = getProviderProperties();
        String token = resolveToken(command.getCategoryCode(), command.getSubcategoryCode(), provider);

        TradicionalAnularVentaRequest request = TradicionalAnularVentaRequest.builder()
                .userName(resolveUserName(provider))
                .token(token)
                .medioId(provider.getMedioId())
                .clienteId(command.getClienteId())
                .ordenCompra(command.getOrdenCompra())
                .motivo(command.getMotivo())
                .build();

        TradicionalAnularVentaResponse response = invokePost(
                operationPath, provider, request, TradicionalAnularVentaResponse.class,
                "anularVenta", "anulacion venta Tradicionales");

        Map<String, Object> payload = new LinkedHashMap<>();
        boolean isError = !response.isSuccess();
        payload.put("codError", response.getCodError());
        payload.put("msgError", response.getMsgError());
        payload.put("transaccion", response.getTransaccion());

        return ExternalTransactionResponse.builder()
                .approved(!isError)
                .externalCode(String.valueOf(response.getCodError()))
                .externalMessage(response.getMsgError() != null ? response.getMsgError() : "")
                .payload(payload)
                .build();
    }

    @Override
    public ExternalTransactionResponse generateComprobante(TradicionalVerifyCommand command, String operationPath) {
        AppProperties.ProviderProperties provider = getProviderProperties();
        String url = operationPath;
        String fullUrl = url + "?ventaId=" + command.getVentaId()
                + "&idUsuario=" + encodeParam(command.getIdUsuario())
                + "&puntoDeVenta=" + encodeParam(command.getPuntoDeVenta());

        log.info("Tradicionales generateComprobante GET url={}", fullUrl);
        System.out.println("Tradicionales generateComprobante GET url=" + fullUrl);

        byte[] bytes;
        try {
            bytes = omnistackWebClient.get()
                    .uri(fullUrl)
                    .retrieve()
                    .onStatus(HttpStatusCode::isError, clientResponse -> clientResponse.bodyToMono(String.class)
                            .defaultIfEmpty("")
                            .flatMap(body -> {
                                log.error("Tradicionales generateComprobante error url={} body={}", fullUrl, body);
                                return Mono.error(new IntegrationException(
                                        "Error HTTP al invocar GenerarComprobanteVenta: " + body));
                            }))
                    .bodyToMono(byte[].class)
                    .block();
        } catch (WebClientRequestException exception) {
            throw new IntegrationException(
                    "Error de conexion al invocar GenerarComprobanteVenta: " + rootCauseMessage(exception), exception);
        }

        Map<String, Object> payload = new LinkedHashMap<>();
        boolean isError = bytes == null || bytes.length == 0;
        if (!isError) {
            payload.put("comprobante_b64", Base64.getEncoder().encodeToString(bytes));
        }
        payload.put("ventaId", command.getVentaId());

        return ExternalTransactionResponse.builder()
                .approved(!isError)
                .externalCode(isError ? "ERROR" : "0")
                .externalMessage(isError ? "GenerarComprobanteVenta no retorno contenido" : "")
                .payload(payload)
                .build();
    }

    private String invokePost(
            String operationPath,
            AppProperties.ProviderProperties provider,
            Object request,
            String logOperation,
            String errorOperation) {
        String url = operationPath;
        log.info("Tradicionales {} request url={} body={}", logOperation, url, JsonUtil.toJsonSilently(request));
        System.out.println("Tradicionales " + logOperation + " request url=" + url
                + " body=" + JsonUtil.toJsonSilently(request));

        String body;
        try {
            body = omnistackWebClient.post()
                    .uri(url)
                    .contentType(MediaType.APPLICATION_JSON)
                    .bodyValue(request)
                    .retrieve()
                    .onStatus(HttpStatusCode::isError, clientResponse -> clientResponse.bodyToMono(String.class)
                            .defaultIfEmpty("")
                            .flatMap(b -> {
                                log.error("Tradicionales {} error url={} body={}", logOperation, url, b);
                                return Mono.error(new IntegrationException(
                                        "Error HTTP al invocar " + errorOperation + ": " + b));
                            }))
                    .bodyToMono(String.class)
                    .block();
        } catch (WebClientRequestException exception) {
            throw new IntegrationException(
                    "Error de conexion al invocar " + errorOperation + ": " + rootCauseMessage(exception), exception);
        }

        if (body == null || body.isBlank()) {
            throw new IntegrationException("Tradicionales no retorno contenido para " + errorOperation);
        }
        log.info("Tradicionales {} response url={} body={}", logOperation, url, body);
        System.out.println("Tradicionales " + logOperation + " response url=" + url + " body=" + body);
        return body;
    }

    private <T> T invokePost(
            String operationPath,
            AppProperties.ProviderProperties provider,
            Object request,
            Class<T> responseType,
            String logOperation,
            String errorOperation) {
        String body = invokePost(operationPath, provider, request, logOperation, errorOperation);
        try {
            return objectMapper.readValue(body, responseType);
        } catch (JsonProcessingException e) {
            throw new IntegrationException("Tradicionales " + errorOperation + " retorno un body no parseable");
        }
    }

    private AppProperties.ProviderProperties getProviderProperties() {
        AppProperties.ProviderProperties provider = appProperties.getIntegration().getProviders().get(PROVIDER_KEY);
        if (provider == null) {
            throw new IntegrationException("No existe configuracion para el proveedor Tradicionales");
        }
        return provider;
    }

    private String resolveToken(String categoryCode, String subcategoryCode, AppProperties.ProviderProperties provider) {
        return providerTokenResolverUseCase.getToken(categoryCode, subcategoryCode, provider.getServiceProviderCode());
    }

    private String resolveUserName(AppProperties.ProviderProperties provider) {
        if (provider.getAuth() == null || provider.getAuth().getLogin() == null
                || provider.getAuth().getLogin().getUsername() == null
                || provider.getAuth().getLogin().getUsername().isBlank()) {
            throw new IntegrationException("Tradicionales requiere auth.login.username configurado");
        }
        return provider.getAuth().getLogin().getUsername();
    }

    private boolean isSuccess(Object codError) {
        return codError != null && "0".equals(String.valueOf(codError));
    }


    private String encodeParam(String value) {
        return value != null ? java.net.URLEncoder.encode(value, java.nio.charset.StandardCharsets.UTF_8) : "";
    }

    private String rootCauseMessage(Throwable exception) {
        Throwable current = exception;
        while (current.getCause() != null) {
            current = current.getCause();
        }
        String message = current.getMessage();
        return message == null || message.isBlank()
                ? current.getClass().getSimpleName()
                : current.getClass().getSimpleName() + ": " + message;
    }
}

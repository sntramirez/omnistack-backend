package com.omnistack.backend.infrastructure.adapter.oracle;

import com.omnistack.backend.application.port.out.WsExtLogPort;
import com.omnistack.backend.domain.model.ProviderCallLog;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(name = "app.datasource.hprod.url")
public class OracleWsExtLogAdapter implements WsExtLogPort {

    private static final String INSERT_SQL =
            "INSERT INTO IN_OMNI_LOGS_WS_EXT "
            + "(UUID, PROVEEDOR, WS_KEY, URL, REQUEST, RESPONSE, DURACION_MS, HTTP_STATUS, ES_ERROR, CP_VAR1) "
            + "VALUES "
            + "(:uuid, :proveedor, :wsKey, :url, :request, :response, :duracionMs, :httpStatus, :esError, :cpVar1)";

    @Qualifier("omniOracleJdbcTemplate")
    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Override
    public void log(ProviderCallLog entry) {
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("uuid", entry.getUuid())
                .addValue("proveedor", entry.getProviderKey())
                .addValue("wsKey", entry.getWsKey())
                .addValue("url", truncate(entry.getUrl(), 500))
                .addValue("request", entry.getRequestJson())
                .addValue("response", entry.getResponseJson())
                .addValue("duracionMs", entry.getDurationMs())
                .addValue("httpStatus", entry.getHttpStatus())
                .addValue("esError", entry.isError() ? "S" : "N")
                .addValue("cpVar1", truncate(entry.getErrorMessage(), 1500));
        jdbcTemplate.update(INSERT_SQL, params);
    }

    private String truncate(String value, int max) {
        if (value == null || value.length() <= max) {
            return value;
        }
        return value.substring(0, max);
    }
}

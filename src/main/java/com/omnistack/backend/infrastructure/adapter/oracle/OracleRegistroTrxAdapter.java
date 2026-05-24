package com.omnistack.backend.infrastructure.adapter.oracle;

import com.omnistack.backend.application.port.out.RegistroTrxPort;
import com.omnistack.backend.domain.model.RegistroTrx;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(name = "app.datasource.hprod.url")
public class OracleRegistroTrxAdapter implements RegistroTrxPort {

    private static final String INSERT_SQL =
            "INSERT INTO IN_OMNI_REGISTRO_TRX "
            + "(UUID, CADENA, FARMACIA, NOMBRE_FARMACIA, POS, CANAL, "
            + " PROVEEDOR, CATEGORY_CODE, SUBCATEGORY_CODE, SERVICE_PROVIDER_CODE, RMS_ITEM_CODE, "
            + " CAPABILITY, AUTHORIZATION, MONTO, MONEDA, COD_ESTADO, ES_ERROR) "
            + "VALUES "
            + "(:uuid, :cadena, :farmacia, :nombreFarmacia, :pos, :canal, "
            + " :proveedor, :categoryCode, :subcategoryCode, :serviceProviderCode, :rmsItemCode, "
            + " :capability, :authorization, :monto, :moneda, :codEstado, 'N')";

    @Qualifier("omniOracleJdbcTemplate")
    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Override
    @Async("loggingExecutor")
    public void save(RegistroTrx entry) {
        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("uuid", entry.getUuid())
                    .addValue("cadena", parseNumber(entry.getChain()))
                    .addValue("farmacia", parseNumber(entry.getStore()))
                    .addValue("nombreFarmacia", entry.getStoreName())
                    .addValue("pos", entry.getPos())
                    .addValue("canal", entry.getCanal())
                    .addValue("proveedor", entry.getProveedor())
                    .addValue("categoryCode", entry.getCategoryCode())
                    .addValue("subcategoryCode", entry.getSubcategoryCode())
                    .addValue("serviceProviderCode", entry.getServiceProviderCode())
                    .addValue("rmsItemCode", entry.getRmsItemCode())
                    .addValue("capability", entry.getCapability())
                    .addValue("authorization", entry.getAuthorization())
                    .addValue("monto", entry.getMonto())
                    .addValue("moneda", entry.getMoneda() != null ? entry.getMoneda() : "USD")
                    .addValue("codEstado", entry.getCodEstado());
            jdbcTemplate.update(INSERT_SQL, params);
        } catch (Exception ex) {
            log.warn("Error al registrar REGISTRO_TRX uuid={}: {}", entry.getUuid(), ex.getMessage());
        }
    }

    private Long parseNumber(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Long.parseLong(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}

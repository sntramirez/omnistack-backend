package com.omnistack.backend.infrastructure.adapter.catalog;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

import com.omnistack.backend.application.dto.BusinessLinesRequest;
import com.omnistack.backend.config.properties.AppProperties;
import com.omnistack.backend.domain.enums.ChannelPos;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;

@SuppressWarnings("unchecked")
class OracleBusinessLinesCatalogSourceAdapterTest {

    @Test
    void shouldAssembleCatalogSnapshotFromMultiSourceOracle() {
        NamedParameterJdbcTemplate adTemplate = Mockito.mock(NamedParameterJdbcTemplate.class);
        NamedParameterJdbcTemplate omniTemplate = Mockito.mock(NamedParameterJdbcTemplate.class);
        NamedParameterJdbcTemplate rmsTemplate = Mockito.mock(NamedParameterJdbcTemplate.class);
        OracleBusinessLinesSqlProvider sqlProvider = Mockito.mock(OracleBusinessLinesSqlProvider.class);
        AppProperties appProperties = new AppProperties();

        OracleBusinessLinesCatalogSourceAdapter adapter = new OracleBusinessLinesCatalogSourceAdapter(
                adTemplate, omniTemplate, rmsTemplate, sqlProvider, appProperties);

        BusinessLinesRequest request = BusinessLinesRequest.builder()
                .chain("1")
                .store("148")
                .storeName("FYBECA AMAZONAS")
                .pos("1")
                .channelPos(ChannelPos.POS)
                .build();

        when(sqlProvider.getAdServicesSql()).thenReturn("ad-services");
        when(sqlProvider.getRmsItemsSql()).thenReturn("rms-items");
        when(sqlProvider.getRmsSuppliersSql()).thenReturn("rms-suppliers");
        when(sqlProvider.getAdPaymentMethodsSql()).thenReturn("ad-pm");
        when(sqlProvider.getAdCapabilitiesSql()).thenReturn("omni-cap");
        when(sqlProvider.getInputFieldsSql()).thenReturn("input-fields");

        // AD: parametros de servicio
        when(adTemplate.query(eq("ad-services"), any(SqlParameterSource.class), any(RowMapper.class))).thenReturn(List.of(
                new OracleBusinessLinesCatalogSourceAdapter.AdServiceRow(
                        "1", "100713841", true, false, "RECA", false,
                        "1", "200", "10000", "3", "3", true, "<html>consent</html>")));

        // RMS: metadata del item (CLASS/SUBCLASS, desc, tipo)
        when(rmsTemplate.query(eq("rms-items"), any(SqlParameterSource.class), any(RowMapper.class))).thenReturn(List.of(
                new OracleBusinessLinesCatalogSourceAdapter.RmsItemRow(
                        "100713841", "1", "ENTRETENIMIENTO", "1", "APUESTAS", "ECUABET CASH IN", "CASH_IN")));

        // RMS: supplier (nombre y RUC del proveedor)
        when(rmsTemplate.query(eq("rms-suppliers"), any(SqlParameterSource.class), any(RowMapper.class))).thenReturn(List.of(
                new OracleBusinessLinesCatalogSourceAdapter.RmsSupplierRow(
                        "100713841", "1", "ECUABET", "9999999999001")));

        // AD: formas de pago
        when(adTemplate.query(eq("ad-pm"), any(SqlParameterSource.class), any(RowMapper.class))).thenReturn(List.of(
                new OracleBusinessLinesCatalogSourceAdapter.AdPaymentMethodRow(
                        "1", "100713841", 2, "TARJETA_CREDITO", true)));

        // OMNI: capabilities por service_provider_code
        when(omniTemplate.query(eq("omni-cap"), any(SqlParameterSource.class), any(RowMapper.class))).thenReturn(List.of(
                new OracleBusinessLinesCatalogSourceAdapter.OmniCapabilityRow("1", "PRECHECK"),
                new OracleBusinessLinesCatalogSourceAdapter.OmniCapabilityRow("1", "CREATE_TICKET")));

        // AD: campos de entrada (stub vacio)
        when(adTemplate.query(eq("input-fields"), any(SqlParameterSource.class), any(RowMapper.class))).thenReturn(List.of());

        var snapshot = adapter.loadCatalogSnapshot(request);

        assertEquals(1, snapshot.getCategories().size());
        assertEquals("ENTRETENIMIENTO", snapshot.getCategories().get(0).getCategoryName());
        assertEquals(1, snapshot.getCategories().get(0).getSubcategories().size());
        assertEquals(1, snapshot.getCategories().get(0).getSubcategories().get(0).getProviders().size());
        assertEquals("9999999999001", snapshot.getCategories().get(0).getSubcategories().get(0).getProviders().get(0).getRucProvider());
        assertEquals(1, snapshot.getServices().size());
        assertEquals(2, snapshot.getServices().get(0).getCapabilities().size());
        assertEquals("10000", snapshot.getServices().get(0).getTimeoutWsMax());
        assertEquals("3", snapshot.getServices().get(0).getRetriesWsMax());
        assertEquals("3", snapshot.getServices().get(0).getNumTickets());
        assertTrue(snapshot.getServices().get(0).getInputFields().isEmpty());
        assertEquals("TARJETA_CREDITO", snapshot.getServices().get(0).getPaymentMethods().get(0).getPaymentMethodCode().name());
        assertTrue(snapshot.getServices().get(0).isRequiresConsent());
    }
}

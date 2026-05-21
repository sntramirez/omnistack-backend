package com.omnistack.backend.config;

import com.omnistack.backend.config.properties.AppProperties;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

/**
 * Configuracion del datasource HPROD (schema weblink, PRS6.UIO).
 * Solo se activa cuando app.datasource.hprod.url esta definido.
 * Expone los beans omniOracleDataSource y omniOracleJdbcTemplate
 * para su uso en repositorios de logs y registro de transacciones.
 */
@Configuration
@ConditionalOnProperty(name = "app.datasource.hprod.url")
public class OmniOracleConfig {

    @Bean(name = "omniOracleDataSource")
    public DataSource omniOracleDataSource(AppProperties appProperties) {
        AppProperties.Datasource.HprodDatasource ds = appProperties.getDatasource().getHprod();
        return DataSourceBuilder.create()
                .url(ds.getUrl())
                .username(ds.getUsername())
                .password(ds.getPassword())
                .driverClassName(ds.getDriverClassName())
                .build();
    }

    @Bean(name = "omniOracleJdbcTemplate")
    public NamedParameterJdbcTemplate omniOracleJdbcTemplate(
            @Qualifier("omniOracleDataSource") DataSource omniOracleDataSource) {
        return new NamedParameterJdbcTemplate(omniOracleDataSource);
    }
}

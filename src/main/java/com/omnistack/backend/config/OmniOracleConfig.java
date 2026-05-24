package com.omnistack.backend.config;

import com.omnistack.backend.config.properties.AppProperties;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
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
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(ds.getUrl());
        config.setUsername(ds.getUsername());
        config.setPassword(ds.getPassword());
        config.setDriverClassName(ds.getDriverClassName());
        config.setPoolName("omni-oracle-pool");
        config.setMaximumPoolSize(20);
        config.setMinimumIdle(5);
        config.setConnectionTimeout(10_000);
        config.setIdleTimeout(600_000);
        config.setMaxLifetime(1_800_000);
        config.setLeakDetectionThreshold(30_000);
        return new HikariDataSource(config);
    }

    @Bean(name = "omniOracleJdbcTemplate")
    public NamedParameterJdbcTemplate omniOracleJdbcTemplate(
            @Qualifier("omniOracleDataSource") DataSource omniOracleDataSource) {
        return new NamedParameterJdbcTemplate(omniOracleDataSource);
    }
}

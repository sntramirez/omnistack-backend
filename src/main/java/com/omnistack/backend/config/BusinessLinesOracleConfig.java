package com.omnistack.backend.config;

import com.omnistack.backend.config.properties.AppProperties;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.time.Clock;
import javax.sql.DataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

/**
 * Configuracion de conectividad Oracle para business-lines.
 */
@Configuration
public class BusinessLinesOracleConfig {

    /**
     * Registra una fuente de tiempo injectable para caches y pruebas.
     *
     * @return reloj del sistema
     */
    @Bean
    public Clock systemClock() {
        return Clock.systemDefaultZone();
    }

    /**
     * Construye el datasource Oracle definido para business-lines.
     *
     * @param appProperties propiedades de aplicacion
     * @return datasource configurado
     */
    @Bean(name = "businessLinesOracleDataSource")
    public DataSource businessLinesOracleDataSource(AppProperties appProperties) {
        AppProperties.BusinessLines.Oracle.Datasource datasource = appProperties.getBusinessLines().getOracle().getDatasource1();
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(datasource.getUrl());
        config.setUsername(datasource.getUsername());
        config.setPassword(datasource.getPassword());
        config.setDriverClassName(datasource.getDriverClassName());
        config.setPoolName("omni-catalog-pool");
        config.setMaximumPoolSize(10);
        config.setMinimumIdle(2);
        config.setConnectionTimeout(10_000);
        config.setIdleTimeout(600_000);
        config.setMaxLifetime(1_800_000);
        return new HikariDataSource(config);
    }

    /**
     * Expone el JDBC template con parametros nombrados para la lectura de catalogos.
     *
     * @param businessLinesOracleDataSource datasource Oracle del endpoint
     * @return jdbc template nombrado
     */
    @Bean(name = "businessLinesOracleNamedParameterJdbcTemplate")
    @Primary
    public NamedParameterJdbcTemplate businessLinesOracleNamedParameterJdbcTemplate(
            @org.springframework.beans.factory.annotation.Qualifier("businessLinesOracleDataSource")
            DataSource businessLinesOracleDataSource) {
        return new NamedParameterJdbcTemplate(businessLinesOracleDataSource);
    }
}

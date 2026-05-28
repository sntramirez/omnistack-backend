package com.omnistack.backend.config;

import com.omnistack.backend.config.properties.AppProperties;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.time.Clock;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

/**
 * Datasource Oracle TUKUNAFUNC — catalogo compartido (AD_*).
 * Se activa cuando app.datasource.prod.url esta definido.
 */
@Configuration
@ConditionalOnProperty(name = "app.datasource.prod.url")
public class BusinessLinesOracleConfig {

    @Bean
    public Clock systemClock() {
        return Clock.systemDefaultZone();
    }

    @Bean(name = "businessLinesOracleDataSource")
    public DataSource businessLinesOracleDataSource(AppProperties appProperties) {
        AppProperties.Datasource.OracleDatasource ds = appProperties.getDatasource().getProd();
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(ds.getUrl());
        config.setUsername(ds.getUsername());
        config.setPassword(ds.getPassword());
        config.setDriverClassName(ds.getDriverClassName());
        config.setPoolName("omni-catalog-pool");
        config.setMaximumPoolSize(10);
        config.setMinimumIdle(2);
        config.setConnectionTimeout(10_000);
        config.setIdleTimeout(600_000);
        config.setMaxLifetime(1_800_000);
        config.setLeakDetectionThreshold(30_000);
        return new HikariDataSource(config);
    }

    @Bean(name = "businessLinesOracleNamedParameterJdbcTemplate")
    @Primary
    public NamedParameterJdbcTemplate businessLinesOracleNamedParameterJdbcTemplate(
            @Qualifier("businessLinesOracleDataSource") DataSource businessLinesOracleDataSource) {
        return new NamedParameterJdbcTemplate(businessLinesOracleDataSource);
    }
}

package com.omnistack.backend.infrastructure.adapter.integration.tradicional.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@JsonIgnoreProperties(ignoreUnknown = true)
public class TradicionalFigurasQueryResponse {
    private Object codError;
    private String msgError;

    @JsonProperty("listaDetalle")
    private List<Figura> listaFiguras;

    @Getter
    @Setter
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Figura {
        private String figuraId;
        private String nombre;
        private String descripcion;
    }
}

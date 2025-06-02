package ru.zadachok.dto.AI;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class GenerationResponse {
    @JsonProperty("generated_text")
    private String generatedText;
    @JsonProperty("status")
    private String status;
}

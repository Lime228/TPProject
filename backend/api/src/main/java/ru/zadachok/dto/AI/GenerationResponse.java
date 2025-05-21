package ru.zadachok.dto.AI;

import lombok.Data;

@Data
public class GenerationResponse {
    private String generatedText;
    private String status;
}

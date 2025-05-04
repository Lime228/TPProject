package ru.zadachok.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "DTO для представления лобби",
        example = """
        {
            "lobbyId": 1,
            "shopId": 42,
            "taskId": [101, 102, 103],
            "customerId": [7, 13, 22]
        }""")
public class LobbyDto {
    @Schema(description = "Уникальный ID лобби",
            example = "1",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Long lobbyId;

    @Schema(description = "ID связанного магазина",
            example = "42",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer shopId;

    @Schema(description = "Массив ID задач в лобби",
            example = "[101, 102, 103]",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer[] taskId;

    @Schema(description = "Массив ID участников лобби",
            example = "[7, 13, 22]",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer[] customerId;
}
package ru.zadachok.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "DTO для представления кошелька пользователя",
        example = """
        {
            "id": 1,
            "customerId": 123,
            "lobbyId": 456,
            "balance": 1000
        }""")
public class WalletDto {
    @Schema(description = "Уникальный ID кошелька",
            example = "1",
            minimum = "1",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer id;

    @Schema(description = "ID владельца кошелька",
            example = "123",
            minimum = "1",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer customerId;

    @Schema(description = "ID лобби, к которому привязан кошелек",
            example = "456",
            minimum = "1",
            requiredMode = Schema.RequiredMode.NOT_REQUIRED)
    private Integer lobbyId;

    @Schema(description = "Текущий баланс кошелька в звёздочках",
            example = "1000",
            minimum = "0",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer balance;
}
package ru.zadachok.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "DTO для представления магазина с товарами",
        example = """
        {
            "shopId": 1,
            "productId": [101, 102, 103]
        }""")
public class ShopDto {
    @Schema(description = "Уникальный ID магазина",
            example = "1",
            minimum = "1",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Long shopId;

    @Schema(description = "Массив ID товаров в магазине",
            example = "[101, 102, 103]",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer[] productId;
}
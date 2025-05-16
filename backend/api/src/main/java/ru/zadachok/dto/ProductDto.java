package ru.zadachok.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "DTO для представления товара в магазине",
        example = """
        {
            "id": 1,
            "name": "Смартфон",
            "description": "Флагманский смартфон с OLED-экраном",
            "state": false,
            "price": 99999,
            "photo": "dGVzdF9pbWFnZV9kYXRh",
            "customerId": 123
        }""")
public class ProductDto {
    @Schema(description = "Уникальный ID товара",
            example = "1",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer id;

    @Schema(description = "Название товара",
            example = "Смартфон",
            minLength = 2,
            maxLength = 100,
            requiredMode = Schema.RequiredMode.REQUIRED)
    private String name;

    @Schema(description = "Подробное описание товара",
            example = "Флагманский смартфон с OLED-экраном",
            maxLength = 1000,
            requiredMode = Schema.RequiredMode.NOT_REQUIRED)
    private String description;

    @Schema(description = "Статус выполненности товара (true - администратор подтвердил покупку, false - еще не купил)",
            example = "false",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private boolean state;

    @Schema(description = "Цена товара в звёздочках",
            example = "99999",
            minimum = "0",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer price;

    @Schema(description = "Фотография товара в формате Base64",
            example = "dGVzdF9pbWFnZV9kYXRh",
            requiredMode = Schema.RequiredMode.NOT_REQUIRED)
    private byte[] photo;

    @Schema(description = "ID покупателя товара",
            example = "123",
            requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer customerId;

//    @Schema(description = "Ссылка на товар",
//            example = "https://tochno.magaz.ru/bike",
//            requiredMode = Schema.RequiredMode.REQUIRED)
//    private String link;
}
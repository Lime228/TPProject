package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Запрос на создание нового товара")
public class ProductCreateRequest {
    @JsonProperty("name")
    @NotBlank
    @Schema(description = "Название товара", example = "Смартфон", requiredMode = Schema.RequiredMode.REQUIRED)
    private String name;

    @JsonProperty("description")
    @NotBlank
    @Schema(description = "Описание товара", example = "Флагманский смартфон", requiredMode = Schema.RequiredMode.REQUIRED)
    private String description;

    @JsonProperty("photo")
    @NotBlank
    @Schema(description = "Фото товара в Base64", example = "dGVzdF9pbWFnZV9kYXRh", requiredMode = Schema.RequiredMode.REQUIRED)
    private byte[] photo;

    @JsonProperty("state")
    @NotBlank
    @Schema(description = "Статус выполненности (куплен в реальности или нет)", example = "true", requiredMode = Schema.RequiredMode.REQUIRED)
    private boolean state;

    @JsonProperty("price")
    @NotBlank
    @Schema(description = "Цена в звёздочках", example = "99900", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer price;

    @JsonProperty("shopid")
    @NotBlank
    @Schema(description = "ID магазина", example = "3", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer shopId;

    @JsonProperty("link")
    @NotBlank
    @Schema(description = "Ссылка на товар", example = "https://tochno.magaz.ru/bike", requiredMode = Schema.RequiredMode.REQUIRED)
    private String link;
}

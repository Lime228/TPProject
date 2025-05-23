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
@Schema(description = "Запрос на обновление информации о товаре")
public class UpdateProductRequest {
    @JsonProperty("productid")
    @NotBlank
    @Schema(description = "ID обновляемого товара", example = "15", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer productId;

    @JsonProperty("name")
    @NotBlank
    @Schema(description = "Новое название товара", example = "Смартфон POCO", requiredMode = Schema.RequiredMode.REQUIRED)
    private String name;

    @JsonProperty("description")
    @NotBlank
    @Schema(description = "Новое описание товара", example = "Флагманский смартфон 2023", requiredMode = Schema.RequiredMode.REQUIRED)
    private String description;

    @JsonProperty("photo")
    @NotBlank
    @Schema(description = "Новое фото товара в Base64", example = "dGVzdF9pbWFnZV9kYXRh", requiredMode = Schema.RequiredMode.REQUIRED)
    private byte[] photo;

    @JsonProperty("state")
    @NotBlank
    @Schema(description = "Новый статус доступности", example = "true", requiredMode = Schema.RequiredMode.REQUIRED)
    private Boolean state;

    @JsonProperty("price")
    @NotBlank
    @Schema(description = "Новая цена в копейках", example = "109900", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer price;

    @JsonProperty("link")
    @NotBlank
    @Schema(description = "Ссылка на товар", example = "https://tochno.magaz.ru/bike", requiredMode = Schema.RequiredMode.REQUIRED)
    private String link;
}

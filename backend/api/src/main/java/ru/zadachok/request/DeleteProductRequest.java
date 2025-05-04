// request/DeleteProductRequest.java
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
@AllArgsConstructor
@NoArgsConstructor
@Schema(description = "Запрос на удаление товара")
public class DeleteProductRequest {
    @JsonProperty("shopid")
    @NotBlank
    @Schema(description = "ID магазина", example = "2", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer shopId;

    @JsonProperty("productid")
    @NotBlank
    @Schema(description = "ID удаляемого товара", example = "15", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer productId;
}

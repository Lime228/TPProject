// request/DeleteProductRequest.java
package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class DeleteProductRequest {
    @JsonProperty("shopid")  // Входящее поле в JSON будет "shopid"
    @NotBlank
    private Integer shopId;
    @JsonProperty("productid")  // Входящее поле в JSON будет "productid"
    @NotBlank
    private Integer productId;
}

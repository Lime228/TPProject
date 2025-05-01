// request/UpdateProductRequest.java
package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateProductRequest {
    @JsonProperty("productid")  // Входящее поле в JSON будет "productid" (id продукта)
    @NotBlank
    private Integer productId;
    @JsonProperty("name")  // Входящее поле в JSON будет "name" (продукта)
    @NotBlank
    private String name;
    @JsonProperty("description")  // Входящее поле в JSON будет "description" (описание продукта)
    @NotBlank
    private String description;
    @JsonProperty("photo")  // Входящее поле в JSON будет "photo" (фото продукта)
    @NotBlank
    private byte[] photo;
    @JsonProperty("state")  // Входящее поле в JSON будет "state" (состояние продукта(работает или нет))
    @NotBlank
    private boolean state;
    @JsonProperty("price")  // Входящее поле в JSON будет "price" (цена продукта)
    @NotBlank
    private Integer price;
}

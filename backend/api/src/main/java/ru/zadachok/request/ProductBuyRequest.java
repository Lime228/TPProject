// request/ProductBuyRequest.java
package ru.zadachok.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductBuyRequest {

    @JsonProperty("customerId")
    @NotNull
    private Integer customerId;

    @JsonProperty("productId")
    @NotNull
    private Integer productId;
}

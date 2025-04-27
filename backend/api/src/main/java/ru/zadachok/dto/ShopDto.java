// dto/ShopDto.java
package ru.zadachok.dto;

import lombok.*;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ShopDto {
    private Long shopId;
    private Integer[] productId;
}

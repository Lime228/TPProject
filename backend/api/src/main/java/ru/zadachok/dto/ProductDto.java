package ru.zadachok.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductDto {
    private Integer id;
    private String name;
    private String description;
    private boolean state;
    private Integer price;
    private byte[] photo;
    private Integer customerId;
}
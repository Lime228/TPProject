// model/Shop.java
package ru.zadachok.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.*;
import ru.zadachok.utils.IntegerArrayConverter;

@Entity
@Table(name = "\"shop\"", schema = "\"tp\"")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Модель магазина")
public class Shop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"shop_id\"")
    @Schema(description = "Уникальный идентификатор магазина", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Integer shopId;

    @Convert(converter = IntegerArrayConverter.class)
    @Column(name = "\"product_id\"", columnDefinition = "integer[]")
    @Schema(description = "Массив ID товаров в магазине", example = "[1, 2, 3]")
    private Integer[] productId;
}
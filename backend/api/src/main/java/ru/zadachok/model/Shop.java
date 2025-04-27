// model/Shop.java
package ru.zadachok.model;

import jakarta.persistence.*;
import lombok.*;
import ru.zadachok.utils.IntegerArrayConverter;

@Entity
@Table(name = "\"shop\"", schema = "\"tp\"")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Shop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"shop_id\"")
    private Integer shopId;

    @Convert(converter = IntegerArrayConverter.class)
    @Column(name = "\"product_id\"", columnDefinition = "integer[]")
    private Integer[] productId;
}

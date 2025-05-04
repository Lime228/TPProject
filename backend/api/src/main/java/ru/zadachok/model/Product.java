// model/Product.java
package ru.zadachok.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "\"product\"", schema = "\"tp\"")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"product_id\"")
    private Integer id;

    @Column(name = "\"product_name\"")
    private String name;

    @Column(name = "\"description\"")
    private String description;

    @Column(name = "\"photo\"")
    private byte[] photo;

    @Column(name = "\"product_state\"", nullable = false)
    private Boolean state;

    @Column(name = "\"price\"", nullable = false)
    private Integer price;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "\"customer_id\"", referencedColumnName = "\"customer_id\"")
    @JsonIgnore  // Спрячем customer из JSON-ответа, чтобы не было ошибки
    private Customer customer;
}
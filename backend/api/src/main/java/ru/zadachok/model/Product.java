// model/Product.java
package ru.zadachok.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "\"product\"", schema = "\"tp\"")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Модель товара в магазине")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"product_id\"")
    @Schema(description = "Уникальный идентификатор товара", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Integer id;

    @Column(name = "\"product_name\"")
    @Schema(description = "Название товара", example = "Игровая мышь", requiredMode = Schema.RequiredMode.REQUIRED)
    private String name;

    @Column(name = "\"description\"")
    @Schema(description = "Описание товара", example = "Беспроводная игровая мышь с 6 кнопками")
    private String description;

    @Column(name = "\"photo\"")
    @Schema(description = "Фото товара в формате Base64", format = "byte")
    private byte[] photo;

    @Column(name = "\"product_state\"", nullable = false)
    @Schema(description = "Статус доступности товара", example = "true", defaultValue = "true")
    private Boolean state;

    @Column(name = "\"price\"", nullable = false)
    @Schema(description = "Цена товара в копейках", example = "19900", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer price;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "\"customer_id\"", referencedColumnName = "\"customer_id\"")
    @JsonIgnore
    @Schema(hidden = true)
    private Customer customer;
}
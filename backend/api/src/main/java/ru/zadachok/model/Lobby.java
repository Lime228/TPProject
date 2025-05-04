// model/Lobby.java
package ru.zadachok.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.*;
import lombok.*;
import ru.zadachok.utils.IntegerArrayConverter;

@Entity
@Table(name = "\"lobby\"", schema = "\"tp\"")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Модель лобби")
public class Lobby {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"lobby_id\"")
    @Schema(description = "Уникальный ID лобби", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Integer lobbyId;

    @Column(name = "\"shop_id\"", nullable = false)
    @Schema(description = "ID связанного магазина", example = "5", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer shopId;

    @Convert(converter = IntegerArrayConverter.class)
    @Column(name = "\"task_id\"", columnDefinition = "integer[]")
    @Schema(description = "Массив ID задач в лобби", example = "[1, 2, 3]")
    private Integer[] taskId;

    @Convert(converter = IntegerArrayConverter.class)
    @Column(name = "\"customer_id\"", columnDefinition = "integer[]")
    @Schema(description = "Массив ID участников лобби", example = "[10, 20, 30]")
    private Integer[] customerId;
}

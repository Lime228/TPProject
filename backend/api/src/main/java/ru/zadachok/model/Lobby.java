// model/Lobby.java
package ru.zadachok.model;

import jakarta.persistence.*;
import lombok.*;
import ru.zadachok.utils.IntegerArrayConverter;

@Entity
@Table(name = "\"lobby\"", schema = "\"tp\"")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Lobby {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "\"lobby_id\"")
    private Integer lobbyId;

    @Column(name = "\"shop_id\"", nullable = false)
    private Integer shopId;

    @Convert(converter = IntegerArrayConverter.class)
    @Column(name = "\"task_id\"", columnDefinition = "integer[]")
    private Integer[] taskId;

    @Convert(converter = IntegerArrayConverter.class)
    @Column(name = "\"customer_id\"", columnDefinition = "integer[]")
    private Integer[] customerId;
}
